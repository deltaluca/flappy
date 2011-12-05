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

import gui.Interface;

using StringTools;
import Mut;

class Cli {
	var sock:Socket;
	var socketdelay:Float;

	public var logger:Dynamic->Void;
	public inline function log(x:Dynamic) {
		if(logger!=null) logger(x);
	}

	public function new() {
		socketdelay = -1.0;
		sock = new Socket();
		sock.logger = log;
	}

	var gint:GuiInterface;
	public function bind(gint:GuiInterface) {
		this.gint = gint;
		if(sock!=null) sock.bind(gint.receiver);
	}

	//------------------------------------------------------------------

	public function daide(msg:Message) {
		try {
			var tokens = Unparser.unparse(msg);
			sock.write_message(sock.daide_message(tokens));
		}catch(e:Dynamic) {
			log(e);
		}
	} 
	public function disconnect() {
		if(!sock.connected) throw "no connectione exists!";
		sock.disconnect();
	}
	public function connect(host:String,port:Int) {
		if(sock.connected) sock.disconnect();
		sock.connect(host,port);
		sock.send_im();
		sock.delay = socketdelay;
		if(gint!=null) sock.bind(gint.receiver);
	}

	//------------------------------------------------------------------

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

	public function completion(cmd:String) {
		var matches = [];
		for(c in commands) {
			if(c.name.startsWith(cmd)) matches.push(c);
		}
		if(matches.length==1) return matches[0].name;
		else if(matches.length==0) return cmd;
		else {
			var txt = "";
			for(c in matches) txt += "  "+c.name;
			log(txt);

			return cmd;
		}
	}

	//------------------------------------------------------------------

	public function cmd(arg:String) {
		if(arg.length==0) return;
	
		log("cmd >> "+arg);
		var cmdargs = (~/[ \t]+/g).replace(StringTools.trim(arg)," ").split(" ");
		cmdarg(cmdargs);
	}
	function cmdarg(cmdargs:Array<String>) {
	switch(cmdargs[0]) {
		case "delay":
			if(cmdargs.length!=2) log("delay time");
			else {
				var snd = Std.parseFloat(cmdargs[1]);
				socketdelay = snd;
				if(sock!=null) sock.delay = socketdelay;
			}
		case "run":
			if(cmdargs.length!=2) log("run file");
			else {
				var conts = "";
				try {
					conts = cpp.io.File.getContent(cmdargs[1]);
				}catch(e:Dynamic) {
					log(e);
				}
				for(cc in conts.split("\n")) cmd(cc);
			}
		case "test":
			cmdargs.shift();
			try {
				HLexLog.logger = log;
				var tokens = HLex.lexify(cmdargs.join(" "));
				log(tokens);
				var message = HLlr.parse(tokens);
				log(message);
				tokens = Unparser.unparse(message);
				log(tokens);
			}catch(e:Dynamic) {
				log(e);
			}
		case "daide":
			if(!sock.connected) log("Error! no connection exists!");
			else {
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
			log(null);
		case "exit":
			if(sock.connected) cmd("disconnect");
			cpp.Sys.exit(0);
		case "disconnect":
			try {
				disconnect();
			}catch(e:Dynamic) {
				log(e);
			}
		case "connect":
			if(cmdargs.length!=2) log("connect hostname:port");
			else {
				var hostport = cmdargs[1].split(":");
				if(hostport.length!=2) log("connect hostname:port");
				else {
					try {
						connect(hostport[0],Std.parseInt(hostport[1]));
					}catch(e:Dynamic) {
						log(e);
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
