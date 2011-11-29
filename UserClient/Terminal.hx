package;

import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.events.KeyboardEvent;

import daide.Socket;
import daide.HLex;
import daide.HLlr;
import daide.Language;
import daide.Tokens;
import daide.Unparser;

using StringTools;

class Terminal extends Sprite {
	var logger:TextField;
	var inp:TextField;
	var backg:Sprite;

	var logcnt:Int;
	var logsize:Int;
	public function crop() {
		while(logcnt>=logsize) {
			logger.text = logger.text.substr(logger.text.indexOf("\n")+1);
			logcnt--;
		}
	}
	public function log(x:Dynamic) {
		var split = Std.string(x).split("\n");
		if(split.length>1) {
			for(s in split) log(s);
			return;
		}
		crop();
		logcnt++;
		logger.text = logger.text+Std.string(x)+"\n";
	}

	public function new(width:Int,height:Int) {
		super();

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
		{name:"send_im",help:"send im message to server"}
	];

	public var histcnt:Int;
	public var history:Array<String>;

	public function cmd(arg:String) {
		if(arg.length==0) return;

		history.push(arg);
		histcnt = 0;
		log("cmd >> "+arg);
		var cmdargs = arg.split(" ");
		switch(cmdargs[0]) {
			case "send_im":
				if(!sock.connected) log("Error! no connection exists!");
				else sock.send_im();
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
				if(!sock.connected) log("Error! no connection exists");
				else sock.disconnect();
			case "connect":
				if(cmdargs.length!=2)
					log(" connect hostname:port");
				else {
					var hostport = cmdargs[1].split(":");
					if(hostport.length!=2)
						log(" connect hostname:port");
					else {
						if(sock.connected)
							cmd("disconnect");

						try {
							sock.connect(hostport[0],Std.parseInt(hostport[1]));
						}catch(e:Dynamic) {
						}
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
}
