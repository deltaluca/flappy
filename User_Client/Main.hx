package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;
import nme.display.StageScaleMode;
import nme.display.StageAlign;

import Terminal;

class Main extends Sprite {
	public static function main() {
		Lib.current.addChild(new Main());
	}
	function new() {
		super();
		addEventListener(Event.ADDED_TO_STAGE, init);
	}

	function init(_) {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		var terminal = new Terminal(stage.stageWidth,stage.stageHeight);
		addChild(terminal);

		stage.addEventListener(Event.RESIZE, function(_) {
			terminal.resize(stage.stageWidth,stage.stageHeight);
		});
	}
}
