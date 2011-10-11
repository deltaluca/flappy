package;

import Socket;

class Main extends flash.display.Sprite {
	static function main() {
		#if flash
			flash.Lib.current.addChild(new Main());
		#elseif cpp
			nme.Lib.create(function() { nme.Lib.current.addChild(new Main()); },
				800,600,60,0xffffff,
				nme.Lib.HARDWARE | nme.Lib.VSYNC
			);
		#end
	}

	var sock:AsyncSocket;
	function new() {
		super();

		sock = new AsyncSocket();

		sock.connect("localhost",4569, function() {
			trace("sending message");
			sock.send("Hello there!");
		});

		sock.onReceive = function(dat:Dynamic) {
			trace("received message="+dat);
		}

		sock.onClose = function() {
			trace("socket connection closed");
		}
	}
}
