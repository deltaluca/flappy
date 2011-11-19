package gui;

import gui.GStage;

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

typedef Rect = {x0:Float,y0:Float,x1:Float,y1:Float};
typedef RelBounds = {x:Float,y:Float,w:Float,h:Float};
class GuiElem extends Sprite {
	public function new() {
		super();
		cacheAsBitmap = false;
	}

	public function resize(width:Int,height:Int,scale:ScaleMode) {
	}
	
	public function bounds() {
		var ret = boundsOf(this);
		return {x:ret.x0-x,y:ret.y0-y,w:ret.x1-ret.x0,h:ret.y1-ret.y0};
	}
	public static function boundsOf(me:DisplayObject) {
		var ret = {x0:me.x,y0:me.y,x1:me.x+me.width,y1:me.y+me.height};
		if(Std.is(me,DisplayObjectContainer)) {
			var me2 = cast(me,DisplayObjectContainer);
			for(i in 0...me2.numChildren) {
				var sub = boundsOf(me2.getChildAt(i));
				if(sub.x0<ret.x0) ret.x0 = sub.x0;
				if(sub.y0<ret.y0) ret.y0 = sub.y0;
				if(sub.x1>ret.x1) ret.x1 = sub.x1;
				if(sub.y1>ret.y1) ret.y1 = sub.y1;
			}
		}

		return ret;
	}
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

		new GStage();
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		var bnds:RelBounds;

		map.resize(width,height,scale);

		negmenu .resize(-1,-1,scale);
		statmenu.resize(-1,-1,scale);
		mainmenu.resize(-1,-1,scale);

		bnds = negmenu.bounds();
		negmenu.x = -bnds.x;
		negmenu.y = height-bnds.h+bnds.y;

		bnds = statmenu.bounds();
		statmenu.y = height-bnds.h+bnds.y;
		statmenu.x = width-bnds.w+bnds.x;
		
		bnds = mainmenu.bounds();
		mainmenu.x = width-bnds.w+bnds.x;
		mainmenu.y = -bnds.y;
	}
}

