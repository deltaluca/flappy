package gui;

import nme.display.BitmapData;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;

enum ScaleMode {
	sSmall;
	sDefault;
	sLarge;
}

class GuiElem extends Sprite {
	
	public function getBounds(?m:Matrix) {
		var m2 = transform.matrix.clone();
		if(m!=null) m2.concat(m);

		var ret = new Rectangle(m2.tx,m2.ty,width*m2.a,height*m2.b);
		for(c in 0...numChildren) {
			var t = cast(getChildAt(c),GuiElem).getBounds(m2);
			ret = ret.union(t);
		}

		return ret;
	}

	public function new() {
		super();
	}

	public function resize(width:Int,height:Int,scale:ScaleMode) {}
}

class Gui extends GuiElem {
	public function new() {
		super();
		build();
	}

	var map:Map;

	var negmenu :Menu; //negotiations
	var statmenu:Menu; //status
	var mainmenu:Menu; //main

	function build() {
		addChild(map = new Map());
		
		addChild(negmenu  = new Menu());
		addChild(statmenu = new Menu());
		addChild(mainmenu = new Menu());
	}

	public function load(mapdata:String, graphics:Array<BitmapData>) map.load(mapdata, graphics)

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		map.resize(width,height,scale);

		negmenu .resize(-1,-1,scale);
		statmenu.resize(-1,-1,scale);
		mainmenu.resize(-1,-1,scale);

		var bnds = negmenu.getBounds();
		negmenu.x = -bnds.x;
		negmenu.y = height-bnds.height+bnds.y;

		bnds = statmenu.getBounds();
		statmenu.y = height-bnds.height+bnds.y;
		statmenu.x = width-bnds.width+bnds.x;
		
		bnds = mainmenu.getBounds();
		mainmenu.x = width-bnds.width+bnds.x;
		mainmenu.y = -bnds.y;
	}
}

