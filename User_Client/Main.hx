package;

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

import daide.Socket;

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
	}
}
