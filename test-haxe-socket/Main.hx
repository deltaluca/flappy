package;

import Socket;

import nme.display.Sprite;
import nme.Lib;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.events.Event;

import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;

import nme.Assets;
class Gui extends Sprite {
	var map:Bitmap;
	var terminal:TextField;

	public function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}
	function init(_) {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		map = new Bitmap(Assets.getBitmapData("Assets/map_c.png"));
		addChild(map);

		terminal = new TextField();
		terminal.background = true;
		terminal.backgroundColor = 0xdedede;
		terminal.selectable = true;
		terminal.type = TextFieldType.INPUT;
		terminal.height = 20;
		addChild(terminal);

		var format = new TextFormat();
		format.size = 16;
		format.font = "Courier New";
		terminal.defaultTextFormat = format;

		stage.addEventListener(Event.RESIZE, resize);
		resize(null);
	}

	function resize(_) {
		map.x = (stage.stageWidth - map.width)/2;
		
		terminal.width = stage.stageWidth;
		terminal.y = stage.stageHeight - terminal.height;
	}
}

class Main extends Sprite {
	public static function main() {
		Lib.current.addChild(new Main());
	}
	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	var gui:Gui;
	var sock:Socket;

	function init(_) {
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;

		removeEventListener(Event.ADDED_TO_STAGE, init);

		gui = new Gui();
		addChild(gui);

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
