package;

import Socket;

import nme.display.Sprite;
import nme.Lib;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.Event;

import nme.Assets;
class Main extends Sprite {
	public static function main() {
		Lib.current.addChild(new Main());
	}
	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	var sock:Socket;
	function init(_) {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		var bit:BitmapData;
		addChild(new Bitmap(bit = Assets.getBitmapData("Assets/map_c.jpg")));
		trace([bit.width,bit.height,bit.getPixel(120,125)]);

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
