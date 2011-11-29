package gui;

import gui.Gui;
import gui.MipMap;

import nme.display.Sprite;
import nme.display.Bitmap;
import nme.Assets;

import nme.events.MouseEvent;

import scx.Match;

class Button extends GuiElem {

	//graphic transitions
	function mouseOver() {}
	function mouseDown() {}
	function mouseUp  () {}

	///event handlers
	var isdown:Bool;
	function mover(_) mouseOver()
	function mdown(_) { isdown = true; mouseDown(); }
	function mup  (_) { isdown = false; mouseOver(); if(onClick!=null) onClick(); }
	function mout (_) { isdown = false; mouseUp(); }

	public var onResize:Int->Int->ScaleMode->Void;
	public var onClick:Void->Void;

	public override function resize(w:Int,h:Int,s) {
		if(onResize!=null) onResize(w,h,s);
	}

	function new() {
		super();
		
		addEventListener(MouseEvent.ROLL_OVER, mover);
		addEventListener(MouseEvent.ROLL_OUT,  mout);
		addEventListener(MouseEvent.MOUSE_DOWN, mdown);
		addEventListener(MouseEvent.MOUSE_UP,   mup);
	}
}

class RoundButton extends Button {
	
	override function mouseOver() {
		up.visible = down.visible = false;
		over.visible = true;
	}
	override function mouseDown() {
		up.visible = over.visible = false;
		down.visible = true;
	}
	override function mouseUp() {
		down.visible = over.visible = false;
		up.visible = true;
	}

	var up  :MipMap;
	var over:MipMap;
	var down:MipMap;

	var radius:Int;

	public function new(radius:Int) {
		super();
		up   = new MipMap([Assets.getBitmapData("Assets/round_but_up.png")]);
		over = new MipMap([Assets.getBitmapData("Assets/round_but_over.png")]);
		down = new MipMap([Assets.getBitmapData("Assets/round_but_down.png")]);	

		this.radius = radius;
		display(radius);

		addChild(up);
		addChild(over);
		addChild(down);

		over.visible = down.visible = false;
	}

	function display(radius:Int) {
		up.resize(radius,radius);
		over.resize(radius,radius);
		down.resize(radius,radius);
	}

	override public function resize(w:Int,h:Int,scale:ScaleMode) {
		var sx = Std.int(radius*Match.match(scale, sSmall = 0.5, sDefault = 1.0, sLarge = 2.0));
		display(sx);

		super.resize(sx,sx,scale);
	}

}
