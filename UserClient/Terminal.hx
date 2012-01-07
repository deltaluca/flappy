package;

import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.events.KeyboardEvent;
import nme.events.Event;

import daide.Socket;
import daide.HLex;
import daide.HLlr;
import daide.Language;
import daide.Tokens;
import daide.Unparser;

import gui.Interface;

using StringTools;
import Mut;

import haxe.Timer;

class Log {
	public var text:String;
	public var lines:Int;
	
	public function new() {
		text = "";
		lines = 0;
	}
}

class Terminal {
	public var display:Sprite;

	var logger:TextField;
	var inp   :TextField;
	//background for darkening of background when terminal is displayed
	var backg :Sprite;

	//----------------------------------------------------------------
	//logger value locked as used from more than one thread
	var mlog:Mut<Log>;

	var maxlines:Int;
	var maxwidth:Int;

	function crop() {
	mlog.with(function(x:Log) {
		while(x.lines>=maxlines) {
			x.text = x.text.substr(x.text.indexOf("\n")+1);
			x.lines--;
		}
	});
	}

	function log(value:Dynamic) {
	mlog.with(function(x:Log) {
		if(value==null) { x.text = ""; x.lines = 0; return; }

		var xs = Std.string(value);
		function log(xs:String) {
			var split = xs.split("\n");
			if(split.length>1) {
				for(s in split) log(s);
				return;
			}
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

	//----------------------------------------------------------------
	
	public var visible(default, setvisible):Bool;
	function setvisible(visible:Bool) {
		display.visible = visible;
		if(this.visible==visible) return visible;
		this.visible = visible;

		if(visible) logger.addEventListener   (Event.ENTER_FRAME, update);
		else        logger.removeEventListener(Event.ENTER_FRAME, update);
		
		inp.text = "";
		return visible;
	}
	function update(_) {
	mlog.with(function (x:Log) {
		logger.text = x.text;
		return null;
	});
	}

	//----------------------------------------------------------------

	var cli:Cli;
	public function bind(cli:Cli) {
		this.cli = cli;
		cli.logger = log;
	}

	public function new() {
		display = new Sprite();
		var font = Assets.getFont("Assets/Courier.ttf");
	
		mlog = new Mut<Log>(new Log());
		maxlines = maxwidth = 1;
	
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

		var history = new Array<String>();
		var histcnt = 0;
		inp.addEventListener(KeyboardEvent.KEY_DOWN, function(ev) {
			if(ev.keyCode == Keyboard.ENTER) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				if((~/[ \t]+/g).replace(inp.text,"").length>0) {
					history.push(inp.text);
					histcnt = 0;
					cli.cmd(inp.text);
					inp.text = "";
				}
			}else if(ev.keyCode == Keyboard.UP) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				if(histcnt<history.length)
					inp.text = history[history.length-(++histcnt)];
			}else if(ev.keyCode == Keyboard.DOWN) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				if(histcnt>0)
					inp.text = history[history.length-(--histcnt)];
			}else if(ev.keyCode == Keyboard.TAB) {
				inp.text = cli.completion(inp.text);
			}
		});	
	}

	//----------------------------------------------------------------

	public function resize(width:Int,height:Int) {
		logger.width = inp.width = width;
		logger.height = height - inp.height;
		inp.y = logger.height;

		maxlines = Std.int(logger.height/10.02);
		maxwidth = Std.int(logger.width/6);
		mlog.with(function (x:Log) {
			x.lines--; crop(); x.lines++;
		});

		backg.width = logger.width;
		backg.height = logger.height;
	}
}
/*
class Terminal extends Sprite {
	var logger:TextField;
	var inp:TextField;
	var backg:Sprite;

	public var logging:Bool;
	public function daide(msg:Message) {
		try {
			var tokens = Unparser.unparse(msg);
			sock.write_message(sock.daide_message(tokens));
		}catch(e:Dynamic) {
			log(e);
		}
	}

	var gint:GuiInterface;
	public function bind(gint:GuiInterface) {
		this.gint = gint;
		if(sock!=null) sock.bind(gint.receiver);
	}

	var logcnt:Int;
	var logsize:Int;
	public function crop() {
		while(logcnt>=logsize) {
			logger.text = logger.text.substr(logger.text.indexOf("\n")+1);
			logcnt--;
		}
	}
	public function log(x:Dynamic) {
		if(!logging) return;

		var xs = Std.string(x);
		var split = xs.split("\n");
		if(split.length>1) {
			for(s in split)
				log(s);
			return;
		}
		var cnt = Math.ceil(xs.length/160);
		if(cnt>1) {
			for(i in 0...cnt)
				log(xs.substr(i*160,160));
			return;
		}
		crop();
		logcnt++;
		logger.text = logger.text+xs+"\n";
	}

	public function new(width:Int,height:Int) {
		super();
		
		socketdelay = -1.0;
		
		logging = true;
		var font = Assets.getFont("Assets/Courier.ttf");

		inp = new TextField();
		inp.type = TextFieldType.INPUT;
		inp.defaultTextFormat = new TextFormat(font.fontName,10,0);
		inp.backgroundColor = 0xaeaeae;
		inp.background = true;
		inp.height = 16;
		addChild(inp);
		
		backg = new Sprite();
		backg.graphics.beginFill(0,0.75);
		backg.graphics.drawRect(0,0,100,100);
		addChild(backg);

		logger = new TextField();
		logger.multiline = true;
		logger.defaultTextFormat = new TextFormat(font.fontName,10,0xffffff);
		addChild(logger);

		resize(width,height);

		inp.addEventListener(KeyboardEvent.KEY_DOWN, function(ev) {
			if(ev.keyCode == Keyboard.ENTER) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				cmd(inp.text);
				inp.text = "";
			}else if(ev.keyCode == Keyboard.UP) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				if(histcnt<history.length)
					inp.text = history[history.length-(++histcnt)];
			}else if(ev.keyCode == Keyboard.DOWN) {
				if(histcnt!=0) history[history.length-histcnt] = inp.text;
				if(histcnt>0)
					inp.text = history[history.length-(--histcnt)];
			}else if(ev.keyCode == Keyboard.TAB) {
				var matches = [];
				for(c in commands) {
					if(c.name.startsWith(inp.text)) matches.push(c);
				}
				if(matches.length==1) inp.text = matches[0].name;
				else if(matches.length>1) {
					var txt = "";
					for(c in matches) txt += "  "+c.name;
					log(txt);
				}
			}
		});

		history = new Array<String>();
		histcnt = 0;
		sock = new Socket();
		sock.logger = log;
	}

	public function resize(width:Int, height:Int) {
		logger.width = inp.width = width;
		logger.height = height-inp.height;
		inp.y = logger.height;

		logsize = Std.int(logger.height/10.02);
		logcnt--; crop(); logcnt++;

		backg.width = logger.width;
		backg.height = logger.height;
	}

	var sock:Socket;

	static var commands = [
		{name:"clear",help:"clear screen"},
		{name:"exit", help:"exit flaplomacy"},
		{name:"disconnect",help:"disconnect from server"},
		{name:"connect",help:"connect hostname:port - connect to server"},
		{name:"sys",help:"execute system command :)"},
		{name:"help",help:"list available commands"},
		{name:"daide",help:"submit daide message"},
		{name:"test",help:"test daide message"},
	#if cpp	{name:"run",help:"run file - run file consisting of terminal commands"}, #end
		{name:"send_im",help:"send im message to server"},
		{name:"delay",help:"set delay on socket (seconds)"}
	];

	public var histcnt:Int;
	public var history:Array<String>;

	public var socketdelay:Float;

	public function cmd(arg:String) {
		if(arg.length==0) return;

		history.push(arg);
		histcnt = 0;
		log("cmd >> "+arg);
		var cmdargs = arg.split(" ");
		switch(cmdargs[0]) {
			case "delay":
				if(cmdargs.length!=2) log("delay time");
				else {
					var snd = Std.parseFloat(StringTools.trim(cmdargs[1]));
					socketdelay = snd;
					if(sock!=null) sock.delay = socketdelay;
				}
	#if cpp
			case "run":
				if(cmdargs.length!=2) {
					log("run file");
				}else {
					var conts = "";
					try {
						conts = cpp.io.File.getContent(cmdargs[1]);
					}catch(e:Dynamic) {
						log(e);
					}
					for(cc in conts.split("\n")) cmd(cc);
				}
	#end
			case "test":
				cmdargs.shift();
				try {
					HLexLog.logger = log;
					var tokens = HLex.lexify(cmdargs.join(" "));
					log(Std.string(tokens));
					//test syntax locally
					var message = HLlr.parse(tokens);
					log(Std.string(message));
					//test unparser
					var tokens2 = Unparser.unparse(message);
					log(Std.string(tokens2));
				}catch(e:Dynamic) {
					log(e);
				}
			case "daide":
				if(!sock.connected) {
					log("Error! no connection exists!");
				}else {
					cmdargs.shift();
					try {
						HLexLog.logger = log;
						var tokens = HLex.lexify(cmdargs.join(" "));
						sock.write_message(sock.daide_message(tokens));
					}catch(e:Dynamic) {
						log(e);
					}
				}			
			case "help":
				for(c in commands)
					log("  "+c.name+" :: "+c.help);	
			case "clear":
				logger.text = "";
				logcnt = 0;
			case "exit":
				if(sock.connected) cmd("disconnect");
				cpp.Sys.exit(0);
			case "disconnect":
				try {
					disconnect();
				}catch(e:Dynamic) { log(e); }
			case "connect":
				if(cmdargs.length!=2)
					log(" connect hostname:port");
				else {
					var hostport = cmdargs[1].split(":");
					if(hostport.length!=2)
						log(" connect hostname:port");
					else {
						try {	
							connect(hostport[0],Std.parseInt(hostport[1]));
						}catch(e:Dynamic) { log(e); }
					}
				}
			case "sys":
				var scmd = cmdargs[1];
				cmdargs.shift(); cmdargs.shift();
				cmdargs.push(">"); cmdargs.push(".out");
				cpp.Sys.command(scmd,cmdargs);
				log(cpp.io.File.getContent(".out"));
			default:
				log("Error! unknown command");
				log("use help to list available commands");
		}
	}

	public function disconnect() {
		if(!sock.connected) throw "No connection exists";
		sock.disconnect();
	}
	public function connect(host:String, port:Int) {
		if(sock.connected) disconnect();
		sock.connect(host,port);
		sock.send_im();
		sock.delay = socketdelay;
		if(gint!=null) sock.bind(gint.receiver);
	}
}*/
