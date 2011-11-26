package map;

import scx.Match;
import nme.geom.Rectangle;
import nme.display.Graphics;

import map.HLlr;
import map.HLex;

import nape.geom.GeomPoly;
import nape.geom.Vec2;

typedef Path = Array<PathCommand>;
enum PathCommand {
	pMoveTo(x:Float,y:Float);
	pLineTo(x:Float,y:Float);
	pCurveTo(x:Float,y:Float,cx:Float,cy:Float);
	pCubicTo(x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float);
}

class PathUtils {
	//take the raw output from parser
	//and produce a (badly named) un-verbose version (which is actually 'more' verbose)
	//consisting of only absolute moveTo, (quadratic) curveTo and lineTo, and a (cubic) cubicTo
	//which is maintained so as to render appropriate approximations as curveTo' at run-time.
	public static function parse(data:String):Path {
		var verbose = HLlr.parse(HLex.lexify(data));
		var ret = [];

		//turtle
		var tx:Float = 0; var ty:Float = 0;
		var sx:Float = 0; var sy:Float = 0;
		var px:Float = 0; var py:Float = 0;

		function relx(rel:Bool, x:Float) return rel ? tx+x : x;
		function rely(rel:Bool, y:Float) return rel ? ty+y : y;

		var pre = null;
		for(v in verbose) {
			ret.push(Match.match(v,
				vpMoveTo(r, x,y) = pMoveTo(sx=tx = relx(r,x), sy=ty = rely(r,y)),
				vpLineTo(r, x,y) = pLineTo(tx = relx(r,x), ty = rely(r,y)),
				vpHLineTo(r, x) = pLineTo(tx = relx(r,x), ty),
				vpVLineTo(r, y) = pLineTo(tx, ty = rely(r,y)),
				vpCurveTo(r, x,y,cx,cy) = {
					var rx = relx(r,cx);
					var ry = rely(r,cy);
					pCurveTo(tx = relx(r,x), ty = rely(r,y), px = rx, py = ry);
				},
				vpCubicTo(r,x,y,cx1,cy1,cx2,cy2) = {
					var rx1 = relx(r,cx1);
					var ry1 = rely(r,cy1);
					var rx2 = relx(r,cx2);
					var ry2 = rely(r,cy2);
					pCubicTo(tx = relx(r,x), ty = rely(r,y), rx1, ry1, px = rx2, py = ry2);
				},
				vpSmoothQTo(r,x,y) = {
				 	switch(pre) { case vpCurveTo(_,_,_,_,_): case vpSmoothQTo(_,_,_): default: px = tx; py = ty; }
					var rx = 2*tx - px;
					var ry = 2*ty - py;
					pCurveTo(tx = relx(r,x), ty = rely(r,y), px = rx, py = ry);
				},
				vpSmoothTo(r,x,y,cx2,cy2) = {
					switch(pre) { case vpCubicTo(_,_,_,_,_,_,_): case vpSmoothTo(_,_,_,_,_): default: px = tx; py = ty; }
					var rx1 = 2*tx - px;
					var ry1 = 2*ty - py;
					var rx2 = relx(r,cx2);
					var ry2 = rely(r,cy2);
					pCubicTo(tx = relx(r,x), ty = rely(r,y), rx1, ry1, px = rx2, py = ry2);
				},
				vpClose = pLineTo(tx=sx,ty=sy)
			));
			pre = v;
		}
		return ret;
	}	

	//seperate method to draw filled paths due to NME bug.
	public static function draw_filled(poly:GeomPoly, g:Graphics) {
		var decomp = poly.convex_decomposition();
		for(gp in decomp) {
			var fst = gp.current();
			for(v in gp) {
				if(v==fst) g.moveTo(v.x,v.y);
				else       g.lineTo(v.x,v.y);
			}
			g.lineTo(fst.x,fst.y);
		}
	}
	public static function draw(poly:GeomPoly, g:Graphics) {
		var fst = poly.current();
		for(v in poly) {
			if(v==fst) g.moveTo(v.x,v.y);
			else       g.lineTo(v.x,v.y);
		}
		g.lineTo(fst.x,fst.y);
	}

	//produce GeomPoly for flattened path.
	//this is used to get around NME hardware Graphics bug todo with rendering non-convex paths.
	public static function flatten(path:Path, ?threshold:Float=1):GeomPoly {
		var ret = new GeomPoly();
		//turtle (bezier)
		var tx:Float = 0; var ty:Float = 0;

		for(p in path) {
			switch(p) {
				case pMoveTo(x,y): tx = x; ty = y;
				case pLineTo(x,y): ret.push(Vec2.weak(x,y)); tx = x; ty = y;
				//quadratic bezier is promoted to a cubic for flattening.
				//cubic curve flattens more effeciently in terms of segment counts.
				case pCurveTo(x,y,cx,cy): cubicpolygon(ret,tx,ty, (2*cx+tx)/3,(2*cy+ty)/3, (2*cx+x)/3,(2*cy+y)/3 ,x,y, threshold); tx = x; ty = y;
				case pCubicTo(x,y,cx1,cy1,cx2,cy2): cubicpolygon(ret,tx,ty,cx1,cy1,cx2,cy2,x,y, threshold); tx = x; ty = y;
			}
		}

		return ret;
	}

	static function cubicpolygon(ret:GeomPoly, p0x:Float,p0y:Float,p1x:Float,p1y:Float,p2x:Float,p2y:Float,p3x:Float,p3y:Float, threshold:Float) {
		var stack = [[p0x,p0y,p1x,p1y,p2x,p2y,p3x,p3y]];
		while(stack.length>0) {
			var elt = stack.shift();
			var p0x = elt[0]; var p0y = elt[1];
			var p1x = elt[2]; var p1y = elt[3];
			var p2x = elt[4]; var p2y = elt[5];
			var p3x = elt[6]; var p3y = elt[7];
			
			var cx = cubic_t(p0x,p1x,p2x,p3x,0.5); var cy = cubic_t(p0y,p1y,p2y,p3y,0.5);
			var lx = 0.5*(p0x+p3x); var ly = 0.5*(p0y+p3y);
			var dx = cx-lx; var dy = cy-ly;
			if(dx*dx+dy*dy<threshold)
				ret.push(Vec2.weak(p3x,p3y));
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

	//1d range
	static function range(?r:{x:Float,e:Float}, x:Float) {
		return if(r==null) {x:x,e:0.0}
		  else if(x < r.x) {x:x,e:r.e + r.x-x}
		  else if(x > r.x+r.e) {x:r.x,e:x-r.x};
		  else r;
	}
	static function fromrange(x:{x:Float,e:Float},y:{x:Float,e:Float}) {
		return new Rectangle(x.x,y.x,x.e,y.e);
	}

	//compute theoretical bounds of a path (actual rendering via approximate of cubic curves might be slightly off)
	public static function bounds(path:Path):Rectangle {
		var ret:Rectangle = null;

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
			else if(cur!=null) {
				var x0 = cur.x < ret.x ? cur.x : ret.x;
				var y0 = cur.y < ret.y ? cur.y : ret.y;
				var x1 = (cur.x+cur.width) > (ret.x+ret.width) ? (cur.x+cur.width) : (ret.x+ret.width);
				var y1 = (cur.y+cur.height) > (ret.y+ret.height) ? (cur.y+cur.height) : (ret.y+ret.height);
				ret.x = x0; ret.y = y0;
				ret.width = x1-x0; ret.height = y1-y0;
			}
		}
		return ret;
	}

}
