package gui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.PixelSnapping;
import nme.geom.Matrix;
import nme.geom.ColorTransform;

class MipMap extends Bitmap {
	public var mips:Array<BitmapData>;
	public var ratio:Float;

	//maps[i] > maps[i+1]
	public function new(mips:Array<BitmapData>) {
		super(null, PixelSnapping.AUTO, true);
		this.mips = mips;		
		ratio = mips[0].height/mips[0].width;
	}
	public function resize(width:Int,height:Int) {
		var up  :BitmapData = null;
		var down:BitmapData = null;

		for(mip in mips) {
			if(width == mip.width) {
				bitmapData = mip;
				return;
			}
			if(width > mip.width) {
				down = mip;
				break;
			}
			up = mip;
		}

		if(down==null || up==null) {
			var mip = mips[0];
			if(width<mip.width) mip = mips[mips.length-1];
			bitmapData = mip;
		}else {
			bitmapData = up.clone();
			var d = new Bitmap(down,PixelSnapping.AUTO,true);
			bitmapData.draw(d, new Matrix(up.width/down.width,0,0,up.height/down.height), new ColorTransform(1,1,1,1 - (width-down.width)/(up.width-down.width))); 
		}
		this.width = width;
		this.height = height;
	}
}
