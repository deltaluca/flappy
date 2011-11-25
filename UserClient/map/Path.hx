package map;

import scx.Match;
import nme.geom.Rectangle;

import map.HLlr;
import map.HLex;

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

	//compute theoretical bounds of a path (actual rendering via approximate of cubic curves might be slightly off)
	public static function bounds(path:Path):Rectangle {
		var ret = null;
		for(p in path) {
			var cur = Match.match(p,
				pLineTo(
				_ = null						
			);
			ret = if(ret==null) cur else if(cur==null) ret else ret.toUnion(cur);
		}
	}

}
