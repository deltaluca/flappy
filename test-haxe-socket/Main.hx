package;

import Socket;

class Main extends flash.display.Sprite {
	static function main() {
		#if flash
			flash.Lib.current.addChild(new Main());
		#elseif cpp
			nme.Lib.create(function() { nme.Lib.current.addChild(new Main()); },
				400,300,60,0xffffff,
				nme.Lib.HARDWARE | nme.Lib.VSYNC
			);
		#end
	}

	var sock:Socket;
	function new() {
		super();

		sock = new Socket();
		sock.onReceive = function(dat:Dynamic) {
			trace("received message="+dat);
		}
		sock.onClose = function() {
			trace("socket connection closed");
		}
	
		sock.connect("localhost",4571, function() {
			trace("connected");

			trace("sending message");
			sock.send("Hello there!");
			sock.send(0);
			sock.send(12674);
		});
	}
}
