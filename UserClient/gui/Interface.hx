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
	var ggui:Gui;
	var cli:Cli;
	public function log(x:Dynamic) cli.log(x)
	public function daide(x:Message) cli.daide(x)
	public function daidestr(x:String) cli.cmd("daide "+x)
	
	public function new(ggui:Gui, cli:Cli) {
		this.ggui = ggui;
		this.cli = cli;
		cli.bind(this);
		//ggui.bind(this);

		queue = new Mut<Array<Message>>([]);
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
	var queue:Mut<Array<Message>>;

	public function receiver(msg:Message) {
	queue.with(function (xs:Array<Message>) {
		xs.push(msg);
	});
	}

	function main() {
		var msg:Message = null;
		while((msg = queue.with(function (xs) return if(xs.length==0) null else xs.shift())) != null) {
			switch(msg) {
				case mHello(power,x,v):
					ggui.inform_iam(power,x);
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
				default:
					log("need to do anything for ggui with this?");
			}
		}	
	}

}
