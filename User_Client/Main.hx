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

	var txt:TextField;
	public function log(msg:String) {
		txt.text += "log >> "+msg+"\n";
	}

	function init(_) {
		removeEventListener(Event.ADDED_TO_STAGE, init);

		var font = Assets.getFont("Assets/Courier.ttf");

		txt = new TextField();
		txt.multiline = true;
		txt.defaultTextFormat = new TextFormat(font.fontName,12,0);
		txt.width = stage.stageWidth;
		txt.height = stage.stageHeight-20;
		addChild(txt);

		var term = new TextField();
		term.type = TextFieldType.INPUT;
		term.width = stage.stageWidth;
		term.height = 16;
		term.y = stage.stageHeight-20;
		term.background = true;
		term.backgroundColor = 0xdfdfdf;
		addChild(term);

		// -- 

		var sock = new Socket();
		sock.logger = log;

		try {
			sock.connect("localhost",4567);
		}catch(e:Dynamic) {
			log(e);
		}
	}
}
