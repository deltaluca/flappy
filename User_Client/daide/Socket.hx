package daide;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.Bytes;

import daide.Tokens;
import daide.Language;

typedef Sock = cpp.net.Socket;
class Socket {
	var sock:Sock;
	public function new() {
		sock = new Sock();
		connected = false;
	}

	public var logger:String->Void;
	inline function log(msg:String) {
		if(logger!=null) logger(msg);
	}

	public var connected:Bool;
	public var reader:cpp.vm.Thread;

	public function disconnect() {
		if(!connected) throw "derp";
	
		//send FM
		write_message({type:3,data:null});
		sock.shutdown(true,true);
		sock.close();
		sock = new Sock();
	
		connected = false;
	}

	public function send_im() {
		//send IM message
		log("Sending IM message");
		var im = new BytesOutput(); im.bigEndian = true;
		im.writeUInt16(1);
		im.writeUInt16(0xDA10);
		write_message({type:0,data:im.getBytes()});
	}

	public function connect(ip:String, port:Int) {
		if(connected) throw "herpaderp";

		try {
			log("Connecting on "+ip+":"+port);
			sock = new Sock();
			sock.connect(new cpp.net.Host(ip), port);
		}catch(e:Dynamic) {
			log("Failed to connect");
			throw "connection failure";
		}

		connected = true;

		sock.output.bigEndian = true;
		sock.input.bigEndian = true;
	
		//wait for RM message
		var wait_rm = true;

		reader = cpp.vm.Thread.create(function () {
			while(true) {
				//wait for message
				var msg:ProtoMessage;
				try {
					msg = read_message();
				}catch(e:Dynamic) {
					//socket closed
					return;
				}

				switch(msg.type) {
				case 0:
					//IM sent by server
					if(wait_rm) {
						log("RM was not first message from server");
						write_message(error_message(msg.type==2?0x0A:0x0B));
						break;
					}
					log("IM sent by server??");
					write_message(error_message(0x07));	
					break;
				case 1:
					if(wait_rm) {
						log("RM received from server");
						wait_rm = false;
					} else {
						//RM sent more than once
						log("RM sent more than once by server??");
						write_message(error_message(0x0C));
						break;
					}
				case 2:
					//DM
					if(wait_rm) {
						log("RM was not first message from server");
						write_message(error_message(msg.type==2?0x0A:0x0B));
					}
					log("DM received from server");
					log("let's try parsing it!");
					var tokens = TokenUtils.deserialise(msg.data);
					try {
						var message = HLlr.parse(tokens);
						log(Std.string(message));
					}catch(e:Dynamic) {
						log("Failed to parse message D:");
						//send a fucking error message to the bloody server
					}
				case 3:
					//FM
					if(wait_rm) {
						log("RM was not first message from server");
						write_message(error_message(msg.type==2?0x0A:0x0B));
						break;
					}
					log("FM received from server");
					break;
				case 4:
					//EM
					log("EM received from server");
					var data = new BytesInput(msg.data);
					data.bigEndian = true;
					switch(data.readUInt16()) {
					case 0x01: log(" @ IM timer popped");
					case 0x02: log(" @ IM was not first message");
					case 0x03: log(" @ IM indicated the wrong endian");
					case 0x04: log(" @ IM had incorrect magic number");
					case 0x05: log(" @ Version incompatability");
					case 0x06: log(" @ More than 1 IM sent");
					case 0x07: log(" @ IM sent by server");
					case 0x08: log(" @ Unknown message received");
					case 0x09: log(" @ Message shorter than expected");
					case 0x0A: log(" @ DM sent before RM");
					case 0x0B: log(" @ RM was not first message from server");
					case 0x0C: log(" @ More than 1 RM sent");
					case 0x0D: log(" @ RM sent by client");
					case 0x0E: log(" @ Invalid token in DM");
					default:
					}
					break;
				default:
				}
			}

			log("Connection closed");
			sock.shutdown(true,true);
			sock.close();
			connected = false;
		});
	}

	public function error_message(code:Int) {
		var buf = new BytesOutput(); buf.bigEndian = true;
		buf.writeUInt16(code);
		return {type:4,data:buf.getBytes()};
	}

	public function daide_message(tokens:Array<Token>) {
		return {type:2,data:TokenUtils.serialise(tokens)};
	}

	public function write_message(msg:ProtoMessage) {
		var out = sock.output;

		out.writeByte(msg.type);
		out.writeByte(0); //pad
		if(msg.data!=null) {
			out.writeUInt16(msg.data.length);
			out.write(msg.data);
		}else
			out.writeUInt16(0);

		log("write_message :: "+msg.type+"x"+(msg.data==null?0:msg.data.length));
	}

	public function read_message() : ProtoMessage {
		var inp = sock.input;

		var type:Int = inp.readByte();
		inp.readByte(); //pad
		var length = inp.readUInt16();
		var data = if(length==0) null else inp.read(length);

		log("read_message :: "+type+"x"+length);

		return { type:type, data: data };
	}
}

typedef ProtoMessage = { type:Int, data:Bytes };
