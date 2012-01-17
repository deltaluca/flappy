package map;

import nme.geom.Point;

//a more useful structure than nme.geom.Rectangle
//for use in DynAABB tree and Path methods.

class AABB {
	public var minx:Float; public var miny:Float;
	public var maxx:Float; public var maxy:Float;

	public function new(minx=0.0,miny=0.0,maxx=0.0,maxy=0.0) {
		this.minx = minx; this.miny = miny;
		this.maxx = maxx; this.maxy = maxy;
	}

	public inline function width () return maxx-minx
	public inline function height() return maxy-miny

	public inline function perimeter() return width()+height()

	//------------------------------------------------------------------------

	public inline function set_combine(a:AABB,b:AABB) {
		minx = a.minx < b.minx ? a.minx : b.minx;
		miny = a.miny < b.miny ? a.miny : b.miny;
		maxx = a.maxx > b.maxx ? a.maxx : b.maxx;
		maxy = a.maxy > b.maxy ? a.maxy : b.maxy;
	}

	public inline function merge(a:AABB) {
		if(a.minx<minx) minx = a.minx;
		if(a.maxx>maxx) maxx = a.maxx;
		if(a.miny<miny) miny = a.miny;
		if(a.maxy>maxy) maxy = a.maxy;
	}

	public inline function expand(xy:Point) {
		if(xy.x<minx) minx = xy.x;
		if(xy.x>maxx) maxx = xy.x;
		if(xy.y<miny) miny = xy.y;
		if(xy.y>maxy) maxy = xy.y;
	}

	public inline function contains(xy:Point) {
		return (minx <= xy.x && xy.x <= maxx)
			&& (miny <= xy.y && xy.y <= maxy);
	}
}
