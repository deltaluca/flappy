package gui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.DisplayObject;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

class GObjContainer {
	public var children:Array<GObj>;

	public function new() {
		children = new Array<GObj>();
	}

	public function addChild(x:GObj) {
		if(x.parent!=null) x.parent.removeChild(x);
		children.push(x);
		x.parent = this;
	}
	public function removeChild(x:GObj) {
		if(x.parent!=this) throw "Error: x is not a child of GObj";

		var pull = false;
		for(i in 0...children.length-1) {
			if(children[i] == x) pull = true;
			if(pull) children[i] = children[i+1];
		}

		children.pop();
		x.parent = null;
	}
}

class GObj extends GObjContainer {
	public var parent:GObjContainer;

	public var xform:Matrix;

	public var width (getwidth, setwidth ):Float;
	public var height(getheight,setheight):Float;

		function getwidth () return nmeobj.width *xform.a
		function getheight() return nmeobj.height*xform.d

		function setwidth(width:Float) {
			xform.a = width/nmeobj.width;
			return width;
		}
		function setheight(height:Float) {
			xform.d = height/nmeobj.height;
			return height;
		}

	public var x(getx,setx):Float;
	public var y(gety,sety):Float;

		function getx() return xform.tx
		function gety() return xform.ty
		function setx(x:Float) return xform.tx = x
		function sety(y:Float) return xform.ty = y
	
	public var nmeobj:DisplayObject;
	public function new(?obj:DisplayObject) {
		super();
		nmeobj = obj;
		parent = null;
		xform = new Matrix();
	}
}

class GStage extends GObjContainer {

	public var display:Bitmap;
	var slab:BitmapData;
	var slabrect:Rectangle;
	var slabmat:Matrix;
	var slabpoint:Point;

	public function new() {
		super();
		display = new Bitmap();
		slab = new BitmapData(2048,2048,true,0);
		slabrect = new Rectangle();
		slabmat = new Matrix();
		slabpoint = new Point();
	}

	public function resize(width:Int,height:Int) {
		display.bitmapData = new BitmapData(width,height);
		render();
	}

	public function render() {
		for(c in children)
			__render(c, new Matrix());
	}
	function __render(x:GObj, m:Matrix) {
		var m2 = x.xform.clone();
		m2.concat(m);

		if(x.nmeobj!=null) {
			slabrect.x = slabrect.y = 0;
			slabrect.width = x.nmeobj.width;
			slabrect.height = x.nmeobj.height;

			slab.fillRect(slabrect,0);
			
			slabmat.a = m2.a;
			slabmat.d = m2.d;
			slab.draw(x.nmeobj, slabmat);
		
			slabrect.width  *= m2.a;
			slabrect.height *= m2.d;
			slabpoint.x = -m2.tx;
			slabpoint.y = -m2.ty;
			display.bitmapData.copyPixels(slab, slabrect, slabpoint);
		}

		for(c in x.children)
			__render(c, m2);
	}

}
