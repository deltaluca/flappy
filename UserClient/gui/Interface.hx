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

class GuiInterface {
	public var ggui:Gui;
	public var cli:Cli;

	public function log(x:Dynamic) cli.log(x)
	public function daide(x:Message) cli.daide(x)
	public function daidestr(x:String) cli.cmd("daide "+x)
	
	public function new(ggui:Gui, cli:Cli) {
		this.ggui = ggui;
		this.cli = cli;
		cli.bind(this);
		//ggui.bind(this);

		queue = new Mut<Array<{msg:Message,stamp:Float}>>([]);
		lasttime = -1;
		(new haxe.Timer(30)).run = main;
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
	//includes receive time for delayed processing
	var queue:Mut<Array<{msg:Message, stamp:Float}>>;
	var lasttime:Float;

	public function receiver(msg:Message) {
	queue.with(function (xs) {
		if(lasttime==-1) lasttime = cpp.Sys.cpuTime();

		//dont' delay order results
		if(switch(msg) { case mOrderResult(_,_,_): false; default: true; })
			lasttime += cli.socketdelay;

		if(lasttime<cpp.Sys.cpuTime()) lasttime = cpp.Sys.cpuTime();
		xs.push({msg:msg, stamp:lasttime});
	});
	}

	function main() {
		while(queue.with(function (xs) return if(xs.length==0) Math.POSITIVE_INFINITY else xs[0].stamp) < cpp.Sys.cpuTime()) {
			var msg = queue.with(function (xs) return xs.shift());
			switch(msg.msg) {
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
	}

}
