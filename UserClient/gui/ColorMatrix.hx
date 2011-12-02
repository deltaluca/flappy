package gui;

import nme.filters.ColorMatrixFilter;

class ColorMatrix {

	var elts:Array<Float>;

	function new(xs) {
		if(xs==null)
			elts = [1.0,0,0,0, 0,1,0,0, 0,0,1,0];
		else
			elts = xs;
	}

	static public function hsl_shift(H:Float,S:Float,V:Float) {
	    var VSU = V*S*Math.cos(H);
	    var VSW = V*S*Math.sin(H);

		return new ColorMatrix([
    		(.299*V+.701*VSU+.168*VSW),(.587*V-.587*VSU+.330*VSW),(.114*V-.114*VSU-.497*VSW),0,
    		(.299*V-.299*VSU-.328*VSW),(.587*V+.413*VSU+.035*VSW),(.114*V-.114*VSU+.292*VSW),0,
	   		(.299*V-.3*VSU+1.25*VSW),(.587*V-.588*VSU-1.05*VSW),(.114*V+.886*VSU-.203*VSW),0
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
		var V = (max+min)/2;
		if(max!=min) {
			S = if(V<0.5) (max-min)/(max+min) else (max-min)/(2-max-min);
			if(S!=0) {
				if(r==max) H = (g-b)/(max-min);
				else if(g==max) H = 2 + (b-r)/(max-min);
				else H = 4+(r-g)/(max-min);
	
				H *= Math.PI/3;
			}
		}

		return {H:H,S:S,V:V};
	}

	//matrix to transform RED 0xff0000 into given RGB value
	static public function fromred(rgb:Int) {
		var col = hsl(rgb); 
		var ret = hsl_shift(-col.H,col.S,col.V*2);
		return ret;
	}

	public function filter() return new ColorMatrixFilter(
		[elts[0],elts[1],elts[2],0,elts[3],
		elts[4],elts[5],elts[6],0,elts[7],
		elts[8],elts[9],elts[10],0,elts[11],
		0,0,0,1]
	)
	
}
