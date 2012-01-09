package gui;

import gui.Gui;
import gui.MipMap;

import nme.display.Sprite;
import nme.geom.Matrix;
import nme.display.Bitmap;
import nme.display.GradientType;
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
		alpha = 0.8;
		/*up.visible =*/ down.visible = false;
		over.visible = true;
	}
	override function mouseDown() {
		alpha = 1.0;
		/*up.visible =*/ over.visible = false;
		down.visible = true;
	}
	override function mouseUp() {
		alpha = 1.0;
		down.visible = over.visible = false;
		//up.visible = true;
	}

	var up  :Sprite;
	var over:Sprite;
	var down:Sprite;

	var xwidth:Int;

	public function new(width:Int) {
		super();
		up = new Sprite();
		over = new Sprite();
		down = new Sprite();

		var m = new Matrix();

		//---------------------
		var g = up.graphics;
		m.createGradientBox(width,width);
		g.beginGradientFill(GradientType.LINEAR,[0,0],[0.35,0],[0,0x80],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();

		m.createGradientBox(width,width);
		g.beginGradientFill(GradientType.LINEAR,[0,0],[0,0.35],[0x80,0xff],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();
		//---------------------
		var g = over.graphics;
		m.createGradientBox(width,width,Math.PI/2);
		g.beginGradientFill(GradientType.LINEAR,[0xffffff,0xffffff],[0.5,0],[0,0x80],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();

		m.createGradientBox(width,width,Math.PI/2);
		g.beginGradientFill(GradientType.LINEAR,[0xffffff,0xffffff],[0,0.5],[0x80,0xff],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();
		//---------------------
		var g = down.graphics;
		m.createGradientBox(width,width,Math.PI/2);
		g.beginGradientFill(GradientType.LINEAR,[0,0],[0.25,0],[0,0x80],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();

		m.createGradientBox(width,width,Math.PI/2);
		g.beginGradientFill(GradientType.LINEAR,[0,0],[0,0.25],[0x80,0xff],m);
		g.drawCircle(width/2,width/2,width/2);
		g.endFill();
		//---------------------

		xwidth = width;
		display(width);

		addChild(up);
		addChild(over);
		addChild(down);

		over.visible = down.visible = false;
	}

	function display(width:Int) {
		up.width = down.width = over.width = width;
		up.height = down.height = over.height = width;
	}

	override public function resize(w:Int,h:Int,scale:ScaleMode) {
		var sx = Std.int(xwidth*Match.match(scale, sSmall = 0.5, sDefault = 1.0, sLarge = 2.0));
		display(sx);

		super.resize(sx,sx,scale);
	}

}
