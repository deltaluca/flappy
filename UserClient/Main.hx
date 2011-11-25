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
//		addChild(ggui);

		function size() {
			ggui.resize(stage.stageWidth,stage.stageHeight,sDefault);
		}
		stage.addEventListener(Event.RESIZE,function (_) size());
		size();

		// test map shiz
		var mapdata = Assets.getText("Assets/europe.svg");
		var provinces = MapReader.parse(mapdata);
	
		var sprite = new Sprite();
		var g = sprite.graphics;
		var cols = [0xff,0xff00,0xff0000,0xff00ff,0xffff00,0xffff]; var cnt = 0;
		for(p in provinces) {
			for(path in p.paths) {
				g.lineStyle(1,cols[cnt++],1);
				PathUtils.draw(path,g);
				var b = PathUtils.bounds(path);
				g.drawRect(b.x,b.y,b.width,b.height);
			}
		}

		addChild(new Bitmap(Assets.getBitmapData("Assets/europe.png")));

		addChild(sprite);
	}
}
