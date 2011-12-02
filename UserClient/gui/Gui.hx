package gui;

import gui.Menu;
import gui.Button;
import gui.Map;

import map.MapDef;

import cpp.Sys;

import nme.display.BitmapData;
import nme.display.Bitmap;
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
		var m2 = new Matrix(1,0,0,1, x,y);
		if(m!=null) m2.concat(m);

		var ret = new Rectangle(m2.tx,m2.ty,width,height);
		for(c in 0...numChildren) {
			var ch = getChildAt(c);
			if(Std.is(ch, GuiElem)) {
				var t = cast(ch,GuiElem).getBounds(m2);
				ret = ret.union(t);
			}else {
				var t = new Rectangle(m2.tx+x,m2.ty+y,ch.width,ch.height);
				ret = ret.union(t);
			}
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

	//mapg is placed on display list by default so that initial map load can swap it's place.
	var map:Map; var mapg:Sprite;

	var negmenu :Menu; //negotiations
	var statmenu:Menu; //status
	var mainmenu:Menu; //main

	var stageWidth:Int; var stageHeight:Int; var scaleMode:ScaleMode;

	function build() {
		addChild(mapg = new Sprite());
		
		addChild(negmenu  = new Menu());
		addChild(statmenu = new Menu());
		addChild(mainmenu = new Menu());

		var close = new RoundButton(30);
		var ex = new MipMap([Assets.getBitmapData("Assets/x_marks_the_spot.png")]);
		close.addChild(ex);
		close.onResize = function(w,_,_) {
			var ws = Std.int(w*40/50);
			ex.resize(ws,ws);
			ex.x = ex.y = (w-ws)/2;
		}
		close.onClick = function() {
			Sys.exit(0);
		}

		mainmenu.insert(close);
	}

	var currentMap:String;
	public function load(mapname:String) {
		mapname = mapname.toLowerCase();
		if(mapname==currentMap) return;

		currentMap = mapname;
		var mapdef = MapDef.lookup(mapname);
		var nmap = new Map(mapdef);
		addChild(nmap);

		if(map==null) {
			swapChildren(nmap,mapg);
			removeChild(mapg);
			mapg = null;
		}else {
			swapChildren(nmap,map);
			removeChild(map);
			map.dispose();
		}
		
		map = nmap;

		if(scaleMode!=null) resize(stageWidth,stageHeight,scaleMode);
	}

	public function IAm(power:Null<Int>, passcode:Int) {
		if(power==null) {
			//observer
		}else {
		}
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		stageWidth = width;
		stageHeight = height;
		scaleMode = scale;

		if(map!=null)
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
		mainmenu.x += width-bnds.width-bnds.x;
		mainmenu.y += -bnds.y;
	}
}

