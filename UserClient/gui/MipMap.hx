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

	public function clone() {
		var inp = new Array<BitmapData>();
		for(mip in mips) inp.push(mip.bitmapData.clone()); //have to clone to avoid NME bug (OGLTexture destructor)
		var ret = new MipMap(inp);
		return ret;
	}

	//maps[i] > maps[i+1]
	public function new(mips:Array<BitmapData>) {
		super();
		this.mips = new Array<Bitmap>();		
		for(m in mips) this.mips.push(new Bitmap(m, PixelSnapping.AUTO, true));
		ratio = mips[0].height/mips[0].width;
		resize(mips[0].width,mips[0].height);
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
				this.width = width;
				this.height = height;
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
