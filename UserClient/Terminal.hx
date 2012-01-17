package;

import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.events.KeyboardEvent;
import nme.events.Event;

import gui.Interface;
import Mut;

using StringTools;

//----------------------------------------------------------------------------

//state of the current log is encapsulated as logs are made from more than one
//thread, so we must synchronise on any modification to the log.
//
//encapsulating the log itself is the simplest way to achieve this.
class Log {
	public var text:String;
	public var lines:Int;
	
	public function new() {
		text = "";
		lines = 0;
	}
}

//----------------------------------------------------------------------------

//Terminal was written before GUI. Could be written to extend gui.GuiElem
class Terminal {
	//this display Sprite is used instead of Terminal extending Sprite
	//as we want a customised visible property.
	public var display:Sprite;

	//children of display
	var logger:TextField;
	var inp:TextField;
	var backg:Sprite; //background to darken screen when terminal is displayed

	//------------------------------------------------------------------------

	//log state and computed width/height in characters for cropping and
	//word-wrap
	var maxlines:Int;
	var maxwidth:Int;
	var mlog:Mut<Log>;

	//------------------------------------------------------------------------

	//cli for use in terminal.
	var cli:Cli;
	public function bind(cli:Cli) {
		this.cli = cli;
		cli.logger = log; //bind also the terminal log method to the cli.
	}

	//------------------------------------------------------------------------

	function crop() {
	mlog.with(function(x:Log) {
		while(x.lines>=maxlines) {
			x.text = x.text.substr(x.text.indexOf("\n")+1);
			x.lines--;
		}
	});
	}

	//null argument taken as a notification to clear the log.
	function log(value:Dynamic) {
	mlog.with(function(x:Log) {
		if(value==null) { x.text = ""; x.lines = 0; return; }

		var xs = Std.string(value);
		//handle word-wrapping of multiline strings.
		function log(xs:String) {
			//log each line seperately.
			var split = xs.split("\n");
			if(split.length>1) {
				for(s in split) log(s);
				return;
			}

			//log each word-wrapped segment seperately.
			var cnt = Math.ceil(xs.length/maxwidth);
			if(cnt>1) {
				for(i in 0...cnt) log(xs.substr(i*maxwidth,maxwidth));
				return;
			}

			x.text += xs+"\n";
			x.lines++;
		}
		log(xs);
		crop();
	});
	}

	//------------------------------------------------------------------------

	//setter on visible for added logic.	
	public var visible(default, setvisible):Bool;
	function setvisible(visible:Bool) {
		if(this.visible==visible) return visible;

		this.visible = display.visible = visible;

		if(visible) logger.addEventListener   (Event.ENTER_FRAME, update);
		else        logger.removeEventListener(Event.ENTER_FRAME, update);
	
		inp.text = ""; //clear input
		return visible;
	}

	//NME library is not thread safe
	//this update method is called on an event invoked via NME in main thread
	//to set the TextField value from the current log state.
	function update(_) {
		mlog.with(function (x:Log) {
			logger.text = x.text;
			return null; //bug in C++ backend of haXe
		});
	}

	//------------------------------------------------------------------------

	public function new() {
		mlog = new Mut<Log>(new Log());
		maxlines = maxwidth = 1;

		//graphical elements -------------------------------------------------
	
		display = new Sprite();
		var font = Assets.getFont("Assets/Courier.ttf");
	
		inp = new TextField();
		inp.type = TextFieldType.INPUT;
		inp.defaultTextFormat = new TextFormat(font.fontName,10,0);
		inp.backgroundColor = 0xaeaeae;
		inp.background = true;
		inp.height = 16;
		display.addChild(inp);

		backg = new Sprite();
		backg.graphics.beginFill(0,0.75);
		backg.graphics.drawRect(0,0,100,100);
		display.addChild(backg);

		logger = new TextField();
		logger.multiline = true;
		logger.defaultTextFormat = new TextFormat(font.fontName,10,0xffffff);
		display.addChild(logger);

		//command history, ----------------------------------------------------
		//command submission and tab completion.

		var history = new Array<String>();
		var cur_cmd = 0;
		inp.addEventListener(KeyboardEvent.KEY_DOWN, function(ev) {
			//command submission
			if(ev.keyCode == Keyboard.ENTER) {
				if(cur_cmd!=0) history[history.length-cur_cmd] = inp.text;
				//check for non-empty command string
				if((~/[ \t]+/g).replace(inp.text,"").length>0) {
					history.push(inp.text);
					cur_cmd = 0;

					if(cli==null) throw "No CLI bound to Terminal";
					cli.cmd(inp.text);
					inp.text = "";
				}
			}
			//tab completion
			else if(ev.keyCode == Keyboard.TAB) {

				if(cli==null) throw "No CLI bound to Terminal";
				inp.text = cli.completion(inp.text);
			}
			//navigation
			else if(ev.keyCode == Keyboard.UP) {
				if(cur_cmd!=0) history[history.length-cur_cmd] = inp.text;
				if(cur_cmd<history.length)
					inp.text = history[history.length-(++cur_cmd)];
			}else if(ev.keyCode == Keyboard.DOWN) {
				if(cur_cmd!=0) history[history.length-cur_cmd] = inp.text;
				if(cur_cmd>0)
					inp.text = history[history.length-(--cur_cmd)];
			}
		});	
	}

	//------------------------------------------------------------------------

	public function resize(width:Int,height:Int) {
		backg.width  = logger.width  = inp.width = width;
		backg.height = logger.height = inp.y     = height - inp.height;

		//NME library as of writing has no API for determining text metrics
		//so must approximate the width/height of the fixed-width font when
		//rendered.
		maxlines = Std.int(logger.height/10.02);
		maxwidth = Std.int(logger.width/(10*72/96));
		mlog.with(function (x:Log) {
			x.lines--; crop(); x.lines++;
		});
	}
}
