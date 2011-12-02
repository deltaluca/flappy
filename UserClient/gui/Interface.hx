package gui;

import daide.Language;
import gui.Gui;
import Terminal;

/**

	Provide a higher-level interface to the low level CLI for the GUI.
	And most importantly, handling of daide messages from the socket,
	forwarding actions to either CLI or GUI.

**/

class GuiInterface {
	var ggui:Gui;
	var terminal:Terminal;
	public function log(x:Dynamic) terminal.log(x)
	public function daide(x:Message) terminal.daide(x)
	public function daidestr(x:String) terminal.cmd("daide "+x)
	
	public function new(ggui:Gui, term:Terminal) {
		this.ggui = ggui;
		terminal = term;
		terminal.bind(this);
		//ggui.bind(this);
	}

	//---------------------------------------------------------------------------

	public function join(host:String, port:Int, name:String) {
		terminal.connect(host,port);
		daide(mName(name,"Flappy GUI 1.0a"));
		refresh();
	}
	public function observer(host:String, port:Int) {
		terminal.connect(host,port);
		daide(mObserver);
		refresh();
	}
	public function rejoin(host:String, port:Int, power:Int, passcode:Int) {
		terminal.connect(host,port);
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

	public function receiver(msg:Message) {
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
