package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import gui.Gui;

class Map extends GuiElem {
	public function new() {
		super();
		build();
		viewport = null; 
	}

	var map:Bitmap;
	var viewport:RelBounds;
	var stageWidth :Int;
	var stageHeight:Int;

	/* get around NME bug */ // (#)
	var disp:Bitmap;
	/* =----------------= */

	function build() {
		map = new Bitmap(Assets.getBitmapData("Assets/map-std.png"));
		// #
		// addChild(map);
	}

	public function display() {
		// #
		//if(viewport.x==0) map.x = 0 else map.x = -viewport.x*map.width;
		//if(viewport.y==0) map.y = 0 else map.y = -viewport.y*map.height;
		var b = new BitmapData(Std.int(0.5+map.width),Std.int(0.5+map.height));
		b.draw(map);
		//disp.bitmapData.draw(map, new Matrix(1,0,0,1,-viewport.x*map.width,-viewport.y*map.height));
		//disp.bitmapData.copyPixels(b, new Rectangle(viewport.x*map.width,viewport.y*map.height,viewport.w*map.width,viewport.h*map.height), new Point(0,0))
		disp.bitmapData.copyPixels(b, new Rectangle(0,0,map.width,map.height), new Point(-viewport.x*map.width,-viewport.y*map.height));
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		//#
		if(disp!=null) removeChild(disp);
		disp = new Bitmap(new BitmapData(width,height));
		addChild(disp);
		//¬#

		stageWidth  = width;
		stageHeight = height;
		var ratio = map.height/map.width;

		var width_h  = ratio*width;
		if(width_h > height) {
			map.width = width;
			map.height = width_h;
		}else {
			var height_w = height/ratio;
			map.width = height_w;
			map.height = height;
		}

		if(viewport==null) {
			viewport = {x:0.0,y:0.0,w:0.0,h:0.0};
			viewport.w = stageWidth/map.width;
			viewport.h = stageHeight/map.height;
			viewport.x = 0.5*(1-viewport.w);
			viewport.y = 0.5*(1-viewport.h);
		}else {
			var nw = stageWidth/map.width;
			var nh = stageHeight/map.height;
			viewport.x -= 0.5*(nw-viewport.w); 
			viewport.y -= 0.5*(nh-viewport.h); 
			viewport.w = nw;
			viewport.h = nh;
	
			if(viewport.x<0) viewport.x = 0;
			if(viewport.y<0) viewport.y = 0;
			if(viewport.w+viewport.x > 1) viewport.x = 1-viewport.w;
			if(viewport.h+viewport.y > 1) viewport.y = 1-viewport.h;
		}

		display();
	}
}
