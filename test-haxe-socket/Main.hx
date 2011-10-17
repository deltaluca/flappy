package;

import Socket;

import nme.display.Sprite;
import nme.Lib;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
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

	var bit:Bitmap;
	var stage_ratio:Float;
	function resize(_) {
		var a1 = stage.stageHeight*stage_ratio*stage.stageHeight;
		var a2 = stage.stageWidth*stage.stageWidth/stage_ratio;

		var w:Float, h:Float;
		if(a1<a2) {
			w = stage.stageHeight*stage_ratio;
			h = stage.stageHeight;
		}else {
			w = stage.stageWidth;
			h = stage.stageWidth/stage_ratio;
		}

		bit.width = w;
		bit.height = h;
		bit.x = (stage.stageWidth - bit.width)/2;
		bit.y = (stage.stageHeight - bit.height)/2;
	}

	var sock:Socket;
	function init(_) {
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;

		removeEventListener(Event.ADDED_TO_STAGE, init);

		bit = new Bitmap(Assets.getBitmapData("Assets/map_c.png"));
		addChild(bit);
		stage_ratio = bit.width/bit.height;

		//-----------------------------

		stage.addEventListener(Event.RESIZE, resize);
		resize(null);

		//-----------------------------

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
