package;

#if flash
	typedef Sock = flash.net.XMLSocket;
#elseif cpp
	typedef Sock = cpp.net.Socket;
#else
	#error lol
#end

class AsyncSocket {
	var sock:Sock;
	public function new() {
		sock = new Sock();
	}

	public function connect(ip:String,port:Int, cont:Void->Void) {
		#if flash
			var cb = null;
			cb = function(ev) {
				sock.removeEventListener(flash.events.Event.CONNECT, cb);
				cont();
			}
			sock.addEventListener(flash.events.Event.CONNECT, cb);
			sock.connect(ip,port);
		#elseif cpp
			sock.connect(new cpp.net.Host(ip), port);
			cont();
		#end
	}

	public var onClose:Void->Void;

	public var onReceive(default,set_onReceive):Dynamic->Void;
	function set_onReceive(cb:Dynamic->Void) {
		if(cb==null) {
			#if flash
				sock.removeEventListener(flash.events.DataEvent.DATA, onData);
			#elseif cpp
			#end
		}else if(onReceive==null) {
			#if flash
				sock.addEventListener(flash.events.DataEvent.DATA, onData);
			#elseif cpp
				cpp.vm.Thread.create(function () {
					while(true) {
						var res = Sock.select([sock],[],[],null);
						if(res.read.length>0) {
							trace(res.read);
							var raw:String = null;
							try {
								raw = sock.input.readUntil(0);
							}catch(e:Dynamic) {
								//socket closed
								break;
							}
							onData({data:raw});
						}
					}
					if(onClose!=null) onClose();
				});
			#end
		}
		return onReceive = cb;
	}
	function onData(ev) {
		var ser = ev.data;
		var dat = haxe.Unserializer.run(ser);
		onReceive(dat);
	}

	public function send(data:Dynamic) {
		var ser = haxe.Serializer.run(data);
		#if flash
			sock.send(ser);
		#elseif cpp
			sock.write(ser);
		#end
	}

}

class Socket {
	var sock:Sock;
	public function new() {
		sock = new Sock();
	}

	public function connect(ip:String,port:Int, cont:Void->Void) {
		#if flash
			var cb = null;
			cb = function(ev) {
				sock.removeEventListener(flash.events.Event.CONNECT, cb);
				cont();
			}
			sock.addEventListener(flash.events.Event.CONNECT, cb);
			sock.connect(ip,port);
		#elseif cpp
			sock.connect(new cpp.net.Host(ip), port);
			cont();
		#end
	}

	public function send(data:Dynamic) {
		var ser = haxe.Serializer.run(data);
		#if flash
			sock.send(ser);
		#elseif cpp
			sock.write(ser);
		#end
	}

	public function receive(cont:Dynamic->Void) {
		#if flash
			var cb = null;
			cb = function(ev) {
				sock.removeEventListener(flash.events.DataEvent.DATA, cb);			
				var ser = ev.data;
				var dat = haxe.Unserializer.run(ser);
				cont(dat);
			}
			sock.addEventListener(flash.events.DataEvent.DATA,cb);
		#elseif cpp
			var ser = sock.input.readUntil(0);
			var dat = haxe.Unserializer.run(ser);
			cont(dat);
		#end
	}
}
