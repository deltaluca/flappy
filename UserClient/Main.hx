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

import map.MapReader;
import map.MapRender;
import map.Path;

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

		var ggui = new Gui();
		ggui.load(Assets.getText("Assets/europe_regions.svg"),
			[Assets.getBitmapData("Assets/europe-big2.png"),
			 Assets.getBitmapData("Assets/europe-big1.png"),
			 Assets.getBitmapData("Assets/europe.png"),
			 Assets.getBitmapData("Assets/europe-sm1.png")]
		);
		addChild(ggui);

		function size() {
			ggui.resize(stage.stageWidth,stage.stageHeight,sDefault);
		}
		stage.addEventListener(Event.RESIZE,function (_) size());
		size();
	}
}
