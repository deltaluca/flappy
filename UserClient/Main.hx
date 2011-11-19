package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageScaleMode;
import nme.display.StageAlign;

import nme.Assets;
import nme.display.Bitmap;

import Terminal;
import gui.Gui;
import gui.GStage;

class Main extends Sprite {
	public static function main() {
		Lib.current.addChild(new Main());
	}
	function new() {
		super();
		cacheAsBitmap = false;
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(_) {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

//		var bit = new Bitmap(Assets.getBitmapData("Assets/map-std.png"));
//		addChild(bit);

/*		var terminal = new Terminal(stage.stageWidth,stage.stageHeight);
		addChild(terminal);

		stage.addEventListener(Event.RESIZE, function(_) {
			terminal.resize(stage.stageWidth,stage.stageHeight);
		});*/

/*		var ggui = new Gui();
		addChild(ggui);
		ggui.resize(stage.stageWidth,stage.stageHeight,sDefault);

		stage.addEventListener(Event.RESIZE, function(_) {
			ggui.resize(stage.stageWidth,stage.stageHeight,sDefault);
		});*/

		var gstage = new GStage();	
		addChild(gstage.display);

		var map = new GObj(new Bitmap(Assets.getBitmapData("Assets/map-std.png")));
		gstage.addChild(map);

		function size() {
			map.width = stage.stageWidth;
			map.height = stage.stageHeight;
			gstage.resize(stage.stageWidth,stage.stageHeight);
		}
		stage.addEventListener(Event.RESIZE,function (_) size());
		size();
	}
}
