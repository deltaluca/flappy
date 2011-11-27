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

		// test map shit
		var mapdata = Assets.getText("Assets/europe.svg");
		var provinces = MapReader.parse(mapdata);
	
		var sprite = new Sprite();
		var g = sprite.graphics;
		for(p in provinces) {
			for(path in p.paths) {
				var polys = PathUtils.flatten(path);
				var c = Std.int(Math.random()*0xffffff);
				for(poly in polys) {
					g.lineStyle(1,c,1);
					g.beginFill(c,1);
					try {
						PathUtils.draw_filled(poly,g);
					}catch(e:Dynamic) {
						trace(e);
						trace(p.id);
					}
					g.endFill();

					g.lineStyle(1,0,1);
					PathUtils.draw(poly,g);
				}
			}
		}

		addChild(sprite);
		sprite.scaleX = sprite.scaleY = 2;
	}
}
