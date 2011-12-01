package gui;

import daide.Language;
import gui.Gui;
import Terminal;

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
		daide(mMap(null)); //request map early
	}
	public function observer(host:String, port:Int) {
		terminal.connect(host,port);
		daide(mObserver);
		daide(mMap(null)); //request map early
	}
	public function rejoin(host:String, port:Int, power:Int, passcode:Int) {
		terminal.connect(host,port);
		daide(mIAm(power,passcode));

		//request these as server assumes we already know them... I don't.
		daide(mMap(null));
		daide(mSupplyOwnership(null));
		daide(mCurrentLocation(null,null));
	}

	//---------------------------------------------------------------------------
	//---------------------------------------------------------------------------

	public function receiver(msg:Message) {
		switch(msg) {
			case mHello(power,x,v):
				log("you are power "+power+" passcode: "+x);
			case mMap(name):
				try {
					ggui.load(name);
					log("map accepted");
					daide(mAccept(mMap(name)));
				}catch(e:Dynamic) {
					log("map rejected");
					daide(mReject(mMap(name)));
				}
			case mCurrentLocation(turn,unitlocs):
				log("should display this to ggui");
			case mSupplyOwnership(scos):
				log("should inform ggui of this");
			default:
				log("need to do anything for ggui with this?");
		}
	}

}
