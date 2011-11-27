package gui;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.display.PixelSnapping;
import nme.geom.Matrix;
import nme.geom.ColorTransform;
import nme.display.Sprite;

class MipMap extends Sprite {
	public var mips:Array<Bitmap>;
	public var ratio:Float;

	//maps[i] > maps[i+1]
	public function new(mips:Array<BitmapData>) {
		super();
		this.mips = new Array<Bitmap>();		
		for(m in mips) this.mips.push(new Bitmap(m, PixelSnapping.AUTO, true));
		ratio = mips[0].height/mips[0].width;
	}
	public function resize(width:Int,height:Int) {
		while(numChildren>0) removeChild(getChildAt(0));

		var up  :Bitmap = null;
		var down:Bitmap = null;

		for(mip in mips) {
			mip.width = mip.bitmapData.width;
			mip.height = mip.bitmapData.height;
			mip.alpha = 1;

			if(width == mip.width) {
				addChild(mip);
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
			addChild(mip);
		}else {
/*			bitmapData = up.clone();
			var d = new Bitmap(down,PixelSnapping.AUTO,true);
			bitmapData.draw(d, new Matrix(up.width/down.width,0,0,up.height/down.height), new ColorTransform(1,1,1,1 - (width-down.width)/(up.width-down.width))); */
			addChild(up);
			addChild(down);
			down.alpha = 1-(width-down.width)/(up.width-down.width);
			down.width = up.width;
			down.height = up.height;
		}
		this.width = width;
		this.height = height;
	}
}
