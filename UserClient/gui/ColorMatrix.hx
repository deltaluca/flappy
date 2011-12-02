package gui;

import nme.filters.ColorMatrixFilter;

typedef HSL = {H:Float,S:Float,L:Float};

class ColorMatrix {

	var elts:Array<Float>;

	function new(xs) {
		if(xs==null)
			elts = [1.0,0,0,0, 0,1,0,0, 0,0,1,0];
		else
			elts = xs;
	}

	function mult(x:ColorMatrix) {
		var ret:Array<Float> = [];
		for(i in 0...3) {
			for(j in 0...4) {
				var v = 0.0;
				for(k in 0...3)
					v += elts[i*4+k]*x.elts[k*4+j];
				if(j==4)
					v += elts[i*4+4];
				ret.push(v);
			}
		}
		elts = ret;
	}

	static public function brightness(p:Float) {
		return new ColorMatrix([
			1,0,0, p,
			0,1,0, p,
			0,0,1, p
		]);
	}

	static public function saturation(p:Float) {
		var x = 1 + (p>0 ? 3*p : p);
		var lumr = 0.3086*(1-x);
		var lumg = 0.6094*(1-x);
		var lumb = 0.0820*(1-x);
		return new ColorMatrix([
			lumr + x, lumg, lumb, 0,
			lumr, lumg + x, lumb, 0,
			lumr, lumg, lumb + x, 0
		]);
	}

	static public function hue(p:Float) {
		var cos = Math.cos(p);
		var sin = Math.sin(p);
		var lumr = 0.213;
		var lumg = 0.715;
		var lumb = 0.072;
		return new ColorMatrix([
			lumr+cos*(1-lumr)+sin*(-lumr), lumg+cos*( -lumg)+sin*(-lumg), lumb+cos*( -lumb)+sin*(1-lumb),0,
			lumr+cos*( -lumr)+sin*(0.143), lumg+cos*(1-lumg)+sin*(0.140), lumb+cos*( -lumb)+sin*(-0.283),0,
			lumr+cos*( -lumr)+sin*(lumr-1),lumg+cos*( -lumg)+sin*( lumg), lumb+cos*(1-lumb)+sin*(  lumb),0
		]);
	}

	//convert rgb to hsl
	static public function hsl(rgb:Int) {
		var r:Float = ((rgb>>16)&0xff)/0xff;
		var g:Float = ((rgb>>8)&0xff)/0xff;
		var b:Float = (rgb&0xff)/0xff;

		var min = Math.min(Math.min(r,g),b);
		var max = Math.max(Math.max(r,g),b);

		var H = 0.0;
		var S = 0.0;
		var L = (max+min)/2;
		if(max!=min) {
			if(L<0.5) S = (max-min)/(max+min);
			else      S = (max-min)/(2-max-min);

			if(r==max) H = (g-b)/(max-min);
			else if(g==max) H = 2 + (b-r)/(max-min);
			else H = 4+(r-g)/(max-min);

			H *= Math.PI/3;
		}

		return {H:H,S:S,L:L};
	}

	//matrix to transform RED 0xff0000 into given RGB value
	static public function fromred(rgb:Int) {
		var col = hsl(rgb);
		var ret = brightness(col.L-0.5);
		ret.mult(saturation(col.S-1));
		ret.mult(hue(col.H));

		return ret;
	}

	public function filter() return new ColorMatrixFilter(
		elts[0],elts[1],elts[2],elts[3],
		elts[4],elts[5],elts[6],elts[7],
		elts[8],elts[9],elts[10],elts[11]
	)
	
}
