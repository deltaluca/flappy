package gui;

import nme.display.Sprite;
import nme.Assets;

import gui.Gui;

class Menu extends GuiElem {
	public var elts:Array<GuiElem>;	

	public function new() {
		super();
		elts = new Array<GuiElem>();
	}

	public function insert(x:GuiElem) {
		elts.push(x);
		addChild(x);
	}

	public override function resize(_:Int,_:Int,scale:ScaleMode) {
		var px = 0.0;
		for(e in elts) {
			e.resize(-1,-1,scale);
			var bnd = e.getBounds();
			e.y = -bnd.y;
			e.x = px-bnd.x;
			px = e.x+bnd.width;
		}
	}
}
