package map;

import scx.Match;
import map.AABB;
import nme.geom.Point;
import nme.geom.Matrix;
import nme.display.Graphics;

import map.HLlr;
import map.HLex;

//assert: Path contains at most 1 moveTo.
//pre: from map.svg, a path must contain only complex paths (allowing more than one) <-- aka no holes allowed
//pre: these paths do not overlap!! <-- means we can optimise the search of point containment and exit at first result rather than continuing to search and using precedences
typedef Path = Array<PathCommand>;

enum PathCommand {
	pMoveTo(x:Float,y:Float);
	pLineTo(x:Float,y:Float);
	pCurveTo(x:Float,y:Float,cx:Float,cy:Float);
	pCubicTo(x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float);
}

typedef Polygon = Array<Point>;

class Range {
	public var min:Float;
	public var max:Float;

	public function new(min=0.0,max=0.0) { this.min = min; this.max = max; }
}

class PathUtils {
	//take the raw output from parser
	//and produce a (badly named) un-verbose version (which is actually 'more' verbose)
	//consisting of only absolute moveTo, (quadratic) curveTo and lineTo, and a (cubic) cubicTo
	public static function parse(data:String, ?xform:Matrix):Array<Path> {
		var tokens = HLex.lexify(data);
		var verbose = HLlr.parse(tokens);
		var rets = [];
		var ret = null;

		//turtle
		var tx:Float = 0; var ty:Float = 0;
		var sx:Float = 0; var sy:Float = 0;
		var px:Float = 0; var py:Float = 0;

		function relx(rel:Bool, x:Float) return rel ? tx+x : x;
		function rely(rel:Bool, y:Float) return rel ? ty+y : y;

		var pre = null;
		for(v in verbose) {
			switch(v) {
				case vpMoveTo(r, x,y):
					ret = new Path(); rets.push(ret);
					ret.push(pMoveTo(sx=tx = relx(r,x), sy=ty = rely(r,y)));
				case vpLineTo(r, x,y):
					ret.push(pLineTo(tx = relx(r,x), ty = rely(r,y)));
				case vpHLineTo(r, x):
					ret.push(pLineTo(tx = relx(r,x), ty));
				case vpVLineTo(r, y):
					ret.push(pLineTo(tx, ty = rely(r,y)));
				case vpCurveTo(r, x,y,cx,cy):
					var rx = relx(r,cx);
					var ry = rely(r,cy);
					ret.push(pCurveTo(tx = relx(r,x), ty = rely(r,y), px = rx, py = ry));
				case vpCubicTo(r,x,y,cx1,cy1,cx2,cy2):
					var rx1 = relx(r,cx1);
					var ry1 = rely(r,cy1);
					var rx2 = relx(r,cx2);
					var ry2 = rely(r,cy2);
					ret.push(pCubicTo(tx = relx(r,x), ty = rely(r,y), rx1, ry1, px = rx2, py = ry2));
				case vpSmoothQTo(r,x,y):
				 	switch(pre) { case vpCurveTo(_,_,_,_,_): case vpSmoothQTo(_,_,_): default: px = tx; py = ty; }
					var rx = 2*tx - px;
					var ry = 2*ty - py;
					ret.push(pCurveTo(tx = relx(r,x), ty = rely(r,y), px = rx, py = ry));
				case vpSmoothTo(r,x,y,cx2,cy2):
					switch(pre) { case vpCubicTo(_,_,_,_,_,_,_): case vpSmoothTo(_,_,_,_,_): default: px = tx; py = ty; }
					var rx1 = 2*tx - px;
					var ry1 = 2*ty - py;
					var rx2 = relx(r,cx2);
					var ry2 = rely(r,cy2);
					ret.push(pCubicTo(tx = relx(r,x), ty = rely(r,y), rx1, ry1, px = rx2, py = ry2));
				case vpClose:
					ret.push(pLineTo(tx=sx,ty=sy));
			}
			pre = v;
		}

		if(xform!=null) {
			function xf(x:Float,y:Float):Point {
				return new Point(x*xform.a+y*xform.b+xform.tx,
								 x*xform.c+y*xform.d+xform.ty);
			}

			for(ret in rets) {
				var rl = ret.length;
				for(i in 0...rl) {
					ret[i] = Match.match(ret[i],
						pMoveTo(x,y) = { var xy = xf(x,y); pMoveTo(xy.x,xy.y); },
						pLineTo(x,y) = { var xy = xf(x,y); pLineTo(xy.x,xy.y); },
						pCurveTo(x,y,cx,cy) = { var xy = xf(x,y); var cy = xf(cx,cy); pCurveTo(xy.x,xy.y,cy.x,cy.y); },
						pCubicTo(x,y,cx1,cy1,cx2,cy2) = { var xy = xf(x,y); var cy1 = xf(cx1,cy1); var cy2 = xf(cx2,cy2); pCubicTo(xy.x,xy.y,cy1.x,cy1.y,cy2.x,cy2.y); }
					);
				}
			}
		}

		return rets;
	}	

	//produce Polygon for flattened path.
	//faster to test containment in polygon than bezier path
	public static function flatten(path:Path, ?threshold:Float=1):Polygon {
		var ret:Polygon = null;

		//turtle (bezier)
		var tx:Float = 0; var ty:Float = 0;

		for(p in path) {
			switch(p) {
				case pMoveTo(x,y): tx = x; ty = y; if(ret!=null) throw "More than one path defined for flatten"; ret = new Polygon();
				case pLineTo(x,y): ret.push(new Point(x,y)); tx = x; ty = y;
				//quadratic bezier is promoted to a cubic for flattening.
				//cubic curve flattens more effeciently in terms of segment counts.
				case pCurveTo(x,y,cx,cy): cubicpolygon(ret,tx,ty, (2*cx+tx)/3,(2*cy+ty)/3, (2*cx+x)/3,(2*cy+y)/3 ,x,y, threshold); tx = x; ty = y;
				case pCubicTo(x,y,cx1,cy1,cx2,cy2): cubicpolygon(ret,tx,ty,cx1,cy1,cx2,cy2,x,y, threshold); tx = x; ty = y;
			}
		}

		return ret;
	}

	static function cubicpolygon(ret:Polygon, p0x:Float,p0y:Float,p1x:Float,p1y:Float,p2x:Float,p2y:Float,p3x:Float,p3y:Float, threshold:Float) {
		var stack = [[p0x,p0y,p1x,p1y,p2x,p2y,p3x,p3y]];
		while(stack.length>0) {
			var elt = stack.shift();
			var p0x = elt[0]; var p0y = elt[1];
			var p1x = elt[2]; var p1y = elt[3];
			var p2x = elt[4]; var p2y = elt[5];
			var p3x = elt[6]; var p3y = elt[7];
			
			var cx1 = cubic_t(p0x,p1x,p2x,p3x,0.333); var cy1 = cubic_t(p0y,p1y,p2y,p3y,0.333);
			var lx1 = p0x+0.333*(p3x-p3x); var ly1 = p0y+0.333*(p3y-p3y);
			var dx1 = cx1-lx1; var dy1 = cy1-ly1;

			var cx2 = cubic_t(p0x,p1x,p2x,p3x,0.666); var cy2 = cubic_t(p0y,p1y,p2y,p3y,0.666);
			var lx2 = p0x+0.666*(p3x-p3x); var ly2 = p0y+0.666*(p3y-p0y);
			var dx2 = cx2-lx2; var dy2 = cy2-ly2;

			if(dx1*dx1+dy1*dy1 + dx2*dx2+dy2*dy2 < threshold)
				ret.push(new Point(p3x,p3y));
			else {
				//sad face :(
				//split cubic in half
				var p12x = 0.5*(p1x+p2x); var p12y = 0.5*(p1y+p2y);
				var p01x = 0.5*(p0x+p1x); var p01y = 0.5*(p0y+p1y);
				var p23x = 0.5*(p2x+p3x); var p23y = 0.5*(p2y+p3y);
				var pax = 0.5*(p01x+p12x); var pay = 0.5*(p01y+p12y);
				var pbx = 0.5*(p23x+p12x); var pby = 0.5*(p23y+p12y);
				var pcx = 0.5*(pax+pbx); var pcy = 0.5*(pay+pby);
		
				stack.unshift([pcx,pcy,pbx,pby,p23x,p23y,p3x,p3y]);
				stack.unshift([p0x,p0y,p01x,p01y,pax,pay,pcx,pcy]);
			}
		}
	}

	static function intersect(p0x:Float,p0y:Float,p1x:Float,p1y:Float,p2x:Float,p2y:Float,p3x:Float,p3y:Float) {
		var ux = p1x-p0x; var uy = p1y-p0y;
		var vx = p2x-p3x; var vy = p2y-p3y;
		var denom = ux*vy - uy*vx;
		if(denom*denom < eps) return null;

		var t = ((p3x-p0x)*vy - (p3y-p0y)*vx)/denom;
		return {x:p0x + ux*t, y:p0y + uy*t};
	}

	//evaluate quadratic and cubic
	static function quad_t(p0:Float,p1:Float,p2:Float,t:Float) {
		var it = 1-t;
		return it*(it*p0 + 2*t*p1) + t*t*p2;
	}
	static function cubic_t(p0:Float,p1:Float,p2:Float,p3:Float,t:Float) {
		var it = 1-t;
		return it*it*(it*p0 + 3*t*p1) + t*t*(3*it*p2 + t*p3);
	}

	static function cap(x:Float):Float return x<0 ? 0 : x>1 ? 1 : x

	inline static var eps = 1e-6;
	//solve quadratic bezier derivative.
	static function quad(p0:Float,p1:Float,p2:Float):Array<Float> {
		var D = p0-2*p1+p2;

		if(D*D < eps) return []; //no root exists.
		else {
			var root = cap(p0-p1)/(p0-2*p1+p2);
			return [root];
		}
	}

	//solve cubic bezier derivative
	static function cubic(p0:Float,p1:Float,p2:Float,p3:Float):Array<Float> {
		var A = 3*(p1-p2) + p3-p0;
		if(A*A<eps) return []; //no root exists

		var B = 2*p0 - 4*p1 + 2*p2;
		var C = p1-p0;
		var D = B*B-4*A*C;

		if(D<0) return []; //no root exists
		else if(D*D < eps) return [-B/(2*A)];
		else {
			D = Math.sqrt(D); A = 1/(2*A);
			var r1 = cap(-(B+D)*A); var r2 = cap((D-B)*A);
			return [r1,r2];
		}
	}

	//range folded-point-combine
	static function range(r:Range=null, x:Float) {
		return if(r==null) new Range(x,x);
 		  else if(x<r.min) { r.min = x; r; }
 		  else if(x>r.max) { r.max = x; r; }
		  else r;
	}
	static function fromrange(x:Range, y:Range) {
		return new AABB(x.min,y.min,x.max,y.max);
	}

	//compute theoretical bounds of a path (actual rendering via approximate of cubic curves might be slightly off)
	public static function bounds(path:Path):AABB {
		var ret:AABB = null;

		//turtle
		var tx:Float = 0; var ty:Float = 0;

		for(p in path) {
			var cur = Match.match(p,
				pMoveTo(x,y) = { tx = x; ty = y; null; },
				pLineTo(x,y) = { 
					var ret = fromrange(range(range(tx),x),range(range(ty),y));
					tx = x; ty = y;
					ret;
				},
				pCurveTo(x,y,cx,cy) = {
					var rx = range(range(tx),x);

					var ry = range(range(ty),y);
					for(root in quad(tx,cx,x)) rx = range(rx, quad_t(tx,cx,x, root));
					for(root in quad(ty,cy,y)) ry = range(ry, quad_t(ty,cy,y, root));

					tx = x; ty = y;
					fromrange(rx,ry);
				},
				pCubicTo(x,y,cx1,cy1,cx2,cy2) = {
					var rx = range(range(tx),x);
					var ry = range(range(ty),y);
					for(root in cubic(tx,cx1,cx2,x)) rx = range(rx, cubic_t(tx,cx1,cx2,x, root));
					for(root in cubic(ty,cy1,cy2,y)) ry = range(ry, cubic_t(ty,cy1,cy2,y, root));

					tx = x; ty = y;
					fromrange(rx,ry);	
				}
			);
			if(ret==null) ret = cur;
			else if(cur!=null) ret.merge(cur);
		}
		return ret;
	}

}
