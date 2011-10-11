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

			sock.addEventListener(flash.events.DataEvent.DATA, onData);
			sock.addEventListener(flash.events.Event.CLOSE, function(_) {
				sock.close();

				if(onClose!=null) onClose();
			});

			sock.connect(ip,port);
		#elseif cpp
			sock.connect(new cpp.net.Host(ip), port);

			cpp.vm.Thread.create(function () {
				while(true) {
					var res = Sock.select([sock],[],[],null);
					if(res.read.length>0) {
						var raw:String = null;
						try {
							raw = sock.input.readUntil(0);
						}catch(e:Dynamic) {
							break;
						}
						onData({data:raw});
					}
				}

				sock.shutdown(true,true);
				sock.close();

				if(onClose!=null) onClose();
			});

			cont();
		#end
	}

	public var onClose:Void->Void;
	public var onReceive:Dynamic->Void;

	function onData(ev) {
		if(onReceive!=null) {
			var ser = ev.data;
			var dat = haxe.Unserializer.run(ser);
			onReceive(dat);
		}
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
