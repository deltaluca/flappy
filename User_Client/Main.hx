package;

import nme.Lib;
import nme.display.Sprite;
import nme.events.Event;

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

		var terminal = new Terminal(stage.stageWidth,stage.stageHeight);
		addChild(terminal);
	}
}
