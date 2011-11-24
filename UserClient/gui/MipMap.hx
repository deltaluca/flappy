package gui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.utils.ByteArray;

class Mip {
	public var data:ByteArray;
	public var width:Int;
	public var height:Int;
	public var bitmap:BitmapData;

	public function new(mip:BitmapData) {
//		data = mip.getPixels(mip.rect);
		width = mip.width;
		height = mip.height;
		bitmap = mip;
	}

	public inline function interp(x:Float, y:Float) {
		if(x>=width-1) x = width-1.001; else if(x<0) x = 0; if(y>=height-1) y = height-1.001; else if(y<0) y = 0;
		var ix = Std.int(x); var iy = Std.int(y);
		var fx = x - ix; var fy = y - iy; var ifx = 1-fx; var ify = 1-fy;

		data.position = (iy*width+ix)<<2;
		var a = data.readByte(); var r = data.readByte(); var g = data.readByte(); var b = data.readByte();
		var a2 = data.readByte(); var r2 = data.readByte(); var g2 = data.readByte(); var b2 = data.readByte();
		data.position += (width-2)<<2;
		var a3 = data.readByte(); var r3 = data.readByte(); var g3 = data.readByte(); var b3 = data.readByte();
		var a4 = data.readByte(); var r4 = data.readByte(); var g4 = data.readByte(); var b4 = data.readByte();
		var c0 = ifx*ify; var c1 = fx*ify; var c2 = ifx*fy; var c3 = fx*fy;
		return argb(
			a*c0 + a2*c1 + a3*c2 + a4*c3,
			r*c0 + r2*c1 + r3*c2 + r4*c3,
			g*c0 + g2*c1 + g3*c2 + g4*c3,
			b*c0 + b2*c1 + b3*c2 + b4*c3
		);
	}

	public static inline function weighted(cols:Array<Int>, weights:Array<Float>=null) {
		var a = 0.0; var r = 0.0; var g = 0.0; var b = 0.0;
		var wsum = 0.0;
		for(i in 0...cols.length) {
			var c = cols[i];
			var w = weights[i];

			a += (c>>>24)*w;
			r += ((c>>>16)&0xff)*w;
			g += ((c>>>8)&0xff)*w;
			b += (c&0xff)*w;

			wsum += w;
		}

		return argb(a/wsum,r/wsum,g/wsum,b/wsum);
	}
	static inline function argb(a:Float,r:Float,g:Float,b:Float) {
		return Std.int(b) | (Std.int(g)<<8) | (Std.int(r)<<16) | (Std.int(a)<<24);
	}

}

class MipMap extends Bitmap {
	public var mips:Array<Mip>;
	public var ratio:Float;

	//maps[i] > maps[i+1]
	public function new(mips:Array<BitmapData>) {
		super();
		this.mips = new Array<Mip>();		
		ratio = mips[0].height/mips[0].width;
		for(m in mips) this.mips.push(new Mip(m));
	}

	public function resize(width:Int,height:Int) {

		var d:Mip = null;
		var w:Int = -1;
		for(mip in mips) {
			var dw = width-mip.width;
			if(w==-1 || dw*dw<w) { w = dw*dw; d = mip; }
		}
		bitmapData = d.bitmap;
		this.width = width;
		this.height = height;

		return;
		// too slow!!

		var up  :Mip = null;
		var down:Mip = null;

		for(mip in mips) {
			if(width == mip.width) {
				return;
			}
			if(width > mip.width) {
				down = mip;
				break;
			}
			up = mip;
		}

		var cur = new ByteArray();
		if(down==null || up==null) {
			var mip = mips[0];
			if(width<mip.width) mip = mips[mips.length-1];
		
			for(y in 0...height) {
				for(x in 0...width) cur.writeInt(mip.interp(x*mip.width/width,y*mip.height/height));
			}
		}else {
			var fw = (width-down.width)/(up.width-down.width);
			for(y in 0...height) {
				for(x in 0...width) {
					var dc = down.interp(x/width*down.width,y/height*down.height);
					var uc = up.interp(x/width*up.width,y/height*up.height);
					cur.writeInt(Mip.weighted([dc,uc],[1-fw,fw]));
				}
			}
		}

		bitmapData = new BitmapData(width,height,true,0);
		bitmapData.setPixels(bitmapData.rect,cur);
	}
}
