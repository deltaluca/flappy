package;

#if flash
	typedef Sock = flash.net.XMLSocket;
#elseif cpp
	typedef Sock = cpp.net.Socket;
#else
	#error lol
#end

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
