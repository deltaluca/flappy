package gui;

import daide.Language;
import gui.Gui;
import Cli;
import haxe.Timer;

/**

	Provide a higher-level interface to the low level CLI for the GUI.
	And most importantly, handling of daide messages from the socket,
	forwarding actions to either CLI or GUI.

**/

class GameTurn {
	//non-empty at start of turn
	public var results:Array<Message>; //assert each is of pattern mOrderResult(...)

	//non-null at end of turn
	public var curloc:Message; //mCurrentLocation
	public var scowners:Message; //mSupplyOwnership

	//non-null at end-game
	public var summary:Message; //mSummary
	public var winner:Message; //mSolo
	public var draw:Message; //mMDraw

	public function new() {
		results = [];
	}
}

class GuiInterface {
	public var ggui:Gui;
	public var cli:Cli;

	public var delay:Float;
	public function setDelay(delay:Float) {
		lasttime = cpp.Sys.cpuTime();
		this.delay = delay;
	}

	public function log(x:Dynamic) cli.log(x)
	public function daide(x:Message) cli.daide(x)
	public function daidestr(x:String) cli.cmd("daide "+x)
	
	public function new(ggui:Gui, cli:Cli) {
		this.ggui = ggui;
		this.cli = cli;
		cli.bind(this);
		ggui.bind(this);

		msgqueue = new Mut<Array<Message>>([]);
		turnqueue = new Mut<Array<GameTurn>>([]);
		lasttime = 0;
		delay = 0;

		(new haxe.Timer(10)).run = main;
	}

	//---------------------------------------------------------------------------

	public function join(host:String, port:Int, name:String) {
		cli.connect(host,port);
		daide(mName(name,"Flappy GUI 1.0a"));
		refresh();
	}
	public function observer(host:String, port:Int) {
		cli.connect(host,port);
		daide(mObserver);
		refresh();
	}
	public function rejoin(host:String, port:Int, power:Int, passcode:Int) {
		cli.connect(host,port);
		daide(mIAm(power,passcode));
		refresh();
	}

	//---------------------------------------------------------------------------

	public function refresh() {
		daide(mMap(null));
		daide(mSupplyOwnership(null));
		daide(mCurrentLocation(null,null));
	}

	//---------------------------------------------------------------------------
	//---------------------------------------------------------------------------

	//queued messages from socket for processing
	//queued turns for gui splay
	var msgqueue:Mut<Array<Message>>;
	var turnqueue:Mut<Array<GameTurn>>;
	var cturn:GameTurn;
	var ingame:Bool;

	/**

		start of a turn is recognised as the first mOrderResult
		end of turn is recognised as the mCurrentLocation message
		with a possible mSupplyOwnership beforehand.

	**/

	public function receiver(msg:Message) {
		switch(msg) {
			case mOrderResult(_,_,_):
				ingame = true;
				if(cturn==null) cturn = new GameTurn();
				cturn.results.push(msg);
			case mSupplyOwnership(_):
				if(ingame && cturn==null) cturn = new GameTurn();
				if(cturn!=null) cturn.scowners = msg;
				else {
					msgqueue.with(function (ms) ms.push(msg));
				}
			case mCurrentLocation(_,_):
				if(ingame && cturn==null) cturn = new GameTurn();
				if(cturn!=null) {
					if(cturn.summary==null) {
						//push order results first.
						var nturn = new GameTurn();
						nturn.scowners = cturn.scowners;
						cturn.scowners = null;
	
						turnqueue.with(function (ts) ts.push(cturn));
	
						nturn.curloc = msg;
						turnqueue.with(function (ts) ts.push(nturn));
					}else {
						cturn.curloc = msg;
						turnqueue.with(function (ts) ts.push(cturn));
						ingame = false;
					}

					cturn = null;
				}else {
					msgqueue.with(function (ms) ms.push(msg));
				}
			case mSummary(_,_):
				if(cturn==null) throw "Summary with no winner/draw declared?";
				cturn.summary = msg;
				cturn = null;
				//still waiting for one loast NOW message to signal end of game messages.
			case mSolo(_):
				cturn = new GameTurn();
				cturn.winner = msg;
			case mDraw(_):
				cturn = new GameTurn();
				cturn.draw = msg;
			default:
				msgqueue.with(function (ms) ms.push(msg));
		}

		//handle press-level 10 + cases where a draw message can be sent outside of end-game. yay.
		if(ingame && cturn!=null && cturn.draw!=null) {
			switch(msg) {
				case mDraw(_):
				case mSummary(_,_):
				default:
					msgqueue.with(function (ms) {
						//insert before last as though it was there all along!
						var m = if(ms.length>0) ms.pop() else null;
						ms.push(cturn.draw);
						if(m!=null) ms.push(m);
					});
					cturn.draw = null;
			}
		}
	}

	var lasttime:Float;
	function main() {
		while(msgqueue.with(function (xs) return xs.length!=0)) {
			var msg = msgqueue.with(function (xs) return xs.shift());
			switch(msg) {
				case mHello(power,x,v):
					ggui.inform_iam(power,x);
				case mMapDefinition(powers,provinces,adj):
					ggui.map.inform_defn(powers,provinces,adj);
				case mMap(name):
					try {
						ggui.load(name);
						log("map accepted");
						daide(mAccept(mMap(name)));
					}catch(e:Dynamic) {
						log("map rejected: why = "+Std.string(e));
						daide(mReject(mMap(name)));
					}
				case mCurrentLocation(turn,unitlocs):
					ggui.inform_locations(turn,unitlocs);
				case mSupplyOwnership(scos):
					ggui.map.inform_supplyOwnerships(scos);
				case mOrderResult(_,order,result):
					ggui.map.inform_result(order,result);
				default:
					log("need to do anything for ggui with this? "+Std.string(msg));
			}
		}

		//actully have two GameTurn objects per turn, one for moves, and one for changes to SCO ownerships and locations.
		while(turnqueue.with(function (ts) return ts.length!=0) && cpp.Sys.cpuTime() >= lasttime + delay/2) {
			var turn = turnqueue.with(function (ts) return ts.shift());
			lasttime += delay/2;

			//clear move information at start of turn/end-game
			if(turn.curloc==null || turn.summary!=null) {
				ggui.map.clear_results();
			}

			//display any move information.
			for(msg in turn.results) {
				switch(msg) {
				case mOrderResult(_,order,result):	
					log(msg);
					ggui.map.inform_result(order,result);
				default:
				}
			}

			//display possible SCO changes
			if(turn.scowners!=null) {
				switch(turn.scowners) {
				case mSupplyOwnership(scos):
					ggui.map.inform_supplyOwnerships(scos);
				default:
				}
			}

			if(turn.curloc!=null) {
				switch(turn.curloc) {
				case mCurrentLocation(turn,unitlocs):
					ggui.inform_locations(turn,unitlocs);
				default:
				}
			}

			if(turn.summary!=null) {
				//end-game!
			}

		}
	}

}
