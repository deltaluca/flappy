package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.display.StageScaleMode;
import nme.display.StageAlign;

import nme.Assets;
import nme.display.Bitmap;

import Terminal;
import gui.Gui;
import gui.Interface;
//import gui.Panel;

import map.MapReader;
import map.Path;
import map.MapDef;

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

		MapDef.register("standard",
			function () return Assets.getText("Assets/europe_regions.svg"),
			function () return Assets.getText("Assets/europe_names.dat"),
			function () return [Assets.getBitmapData("Assets/europe-big2.png"),
	  				   			Assets.getBitmapData("Assets/europe-big1.png"),
								Assets.getBitmapData("Assets/europe.png"),
								Assets.getBitmapData("Assets/europe-sm1.png")]
		);

		var ggui = new Gui();
		addChild(ggui);

		var cli = new Cli();

		var terminal = new Terminal();
		addChild(terminal.display);
		terminal.visible = false;
		terminal.bind(cli);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, function (ev) {
			if(ev.keyCode == 192) //`¬ key
				terminal.visible = !terminal.visible; 
		});

		var gint = new GuiInterface(ggui,cli);

		function size() {
			ggui.resize(stage.stageWidth,stage.stageHeight,sDefault);
			terminal.resize(stage.stageWidth,stage.stageHeight);
		}
		stage.addEventListener(Event.RESIZE,function (_) size());
		size();
	}
}
