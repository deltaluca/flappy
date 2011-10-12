package;

import Socket;

#if flash
@:bitmap("map_c.gif") class Map extends flash.display.BitmapData {}
#elseif cpp
import nme.Assets;
#end

class Main extends flash.display.Sprite {
	public static function main() {
		flash.Lib.current.addChild(new Main());
	}

	var sock:Socket;
	function new() {
		super();
		addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
	}
	function init(_) {
		#if flash
		addChild(new flash.display.Bitmap(new Map(800,600)));
		#elseif cpp
		addChild(new flash.display.Bitmap(Assets.getBitmapData("assets/map_c.gif")));
		#end

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
