package gui;

import gui.GStage;

import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.display.DisplayObject;

enum ScaleMode {
	sSmall;
	sDefault;
	sLarge;
}

class GuiElem extends GObj {
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

//	var negmenu :Menu; //negotiations
//	var statmenu:Menu; //status
//	var mainmenu:Menu; //main

	function build() {
		addChild(map = new Map());
		
//		addChild(negmenu  = new Menu());
//		addChild(statmenu = new Menu());
//		addChild(mainmenu = new Menu());
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		map.resize(width,height,scale);
/*
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
		mainmenu.y = -bnds.y;*/
	}
}

