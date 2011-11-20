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

	public function getBounds(?m:Matrix) {
		var m2 = xform.clone();
		if(m!=null) m2.concat(m);

		var ret:Rectangle = null;
		if(nmeobj!=null)
			ret = new Rectangle(m2.tx,m2.ty,nmeobj.width*m2.a,nmeobj.height*m2.b);
		
		for(c in children) {
			var t = c.getBounds(m2);
			ret = if(ret==null) t else if(t==null) ret else ret.union(t);
		}

		return ret;
	}

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
	public function new(?obj:DisplayObject=null) {
		super();
		nmeobj = obj;
		parent = null;
		xform = new Matrix();
		slabmat = new Matrix();
	}

	public var slab:BitmapData;
	var slabmat:Matrix;

	public function validate(nmat:Matrix) {
		if(nmat.a != slabmat.a || nmat.d != slabmat.d || slab==null) {
			slab = GStage.resizer(slab, Std.int(0.5+nmeobj.width*nmat.a),Std.int(0.5+nmeobj.height*nmat.d));

			slabmat.a = nmat.a;
			slabmat.d = nmat.d;
			slab.draw(nmeobj,slabmat);
		}
	}
}

class GStage extends GObjContainer {

	public var display:Bitmap;
	static var slabrect:Rectangle = new Rectangle();
	var slabpoint:Point;

	public function new() {
		super();
		display = new Bitmap();
		slabpoint = new Point();
	}

	public static function resizer(x:BitmapData, w:Int,h:Int) {
		if(x==null
		|| x.width < w
		|| x.height < h)
			return new BitmapData(w,h,true,0);
		else {
			slabrect.width = w;
			slabrect.height = h;
			x.fillRect(slabrect,0);
			return x;	
		}
	}

	public function resize(width:Int,height:Int) {
		display.bitmapData = resizer(display.bitmapData, width,height);

		for(c in children)
			__render(c, new Matrix());
	}

	function __render(x:GObj, m:Matrix) {
		var m2 = x.xform.clone();
		m2.concat(m);

		if(x.nmeobj!=null) {
			x.validate(m2);

			slabrect.width  = m2.a*x.nmeobj.width;
			slabrect.height = m2.d*x.nmeobj.height;
			slabpoint.x = m2.tx;
			slabpoint.y = m2.ty;
			display.bitmapData.copyPixels(x.slab, slabrect, slabpoint);
		}

		for(c in x.children)
			__render(c, m2);
	}

}
