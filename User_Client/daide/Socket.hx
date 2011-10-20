package daide;

import haxe.io.BytesOutput;
import haxe.io.BytesInput;
import haxe.io.Bytes;

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
	
		connected = false;
	}

	public function connect(ip:String, port:Int) {
		if(connected) throw "herpaderp";

		try {
			log("Connecting on "+ip+":"+port);
			sock.connect(new cpp.net.Host(ip), port);
		}catch(e:Dynamic) {
			log("Failed to connect");
			throw "connection failure";
		}

		connected = true;

		sock.output.bigEndian = true;
		sock.input.bigEndian = true;

		//send IM message
		log("Sending IM message");
		var im = new BytesOutput(); im.bigEndian = true;
		im.writeUInt16(1);
		im.writeUInt16(0xDA10);
		write_message({type:0,data:im.getBytes()});
		
		//wait for RM message
		log("Waiting for RM message");
		var rm = read_message();
		if(rm.type!=1) {
			//first message not RM
			write_message(error_message(rm.type==2 ? 0x0A : 0x0B));
			return;
		}
		if(rm.data!=null) {
			log("Error: RM additional tokens not handled yet!!");
			disconnect();
			return;
		}

		reader = cpp.vm.Thread.create(function () {
			while(true) {
				//wait for message
				var msg:Message;
				try {
					msg = read_message();
				}catch(e:Dynamic) {
					//socket closed
					return;
				}

				switch(msg.type) {
				case 0:
					//IM sent by server
					write_message(error_message(0x07));	
					break;
				case 1:
					//RM sent more than once
					write_message(error_message(0x0C));
					break;
				case 2:
					//DM
					
				case 3:
					//FM
					break;
				case 4:
					//EM
					var data = new BytesInput(msg.data);
					switch(data.readUInt16()) {
					case 0x01: //IM timer popped
					case 0x02: //IM was not first message
					case 0x03: //IM indicated the wrong endian
					case 0x04: //IM had incorrect magic number
					case 0x05: //Version incompatability
					case 0x06: //More than 1 IM sent
					case 0x07: //IM sent by server
					case 0x08: //Unknown message received
					case 0x09: //Message shorter than expected
					case 0x0A: //DM sent before RM
					case 0x0B: //RM was not first message from server
					case 0x0C: //More than 1 RM sent
					case 0x0D: //RM sent by client
					case 0x0E: //Invalid token in DM
					default:
					}
					break;
				default:
				}
			}

			sock.shutdown(true,true);
			sock.close();
		});
	}

	function error_message(code:Int) {
		var buf = new BytesOutput(); buf.bigEndian = true;
		buf.writeUInt16(code);
		return {type:4,data:buf.getBytes()};
	}

	function write_message(msg:Message) {
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

	function read_message() : Message {
		var inp = sock.input;

		var type:Int = inp.readByte();
		inp.readByte(); //pad
		var length = inp.readUInt16();
		var data = if(length==0) null else inp.read(length);

		log("read_message :: "+type+"x"+length);

		return { type:type, data: data };
	}
}

typedef Message = { type:Int, data:Bytes };
