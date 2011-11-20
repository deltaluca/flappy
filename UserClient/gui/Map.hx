package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import gui.Gui;
import gui.GStage;

class Map extends GuiElem {
	public function new() {
		super();
		build();
		viewport = null; 
	}

	var map:GObj;
	var viewport:Rectangle;
	var stageWidth :Int;
	var stageHeight:Int;

	function build() {
		map = new GObj(new Bitmap(Assets.getBitmapData("Assets/map-std.png")));
		addChild(map);
	}

	public function display() {
		map.x = -viewport.x*map.width;
		map.y = -viewport.y*map.height;
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
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
			viewport = new Rectangle();
			viewport.width = stageWidth/map.width;
			viewport.height = stageHeight/map.height;
			viewport.x = 0.5*(1-viewport.width);
			viewport.y = 0.5*(1-viewport.height);
		}else {
			var nw = stageWidth/map.width;
			var nh = stageHeight/map.height;
			viewport.x -= 0.5*(nw-viewport.width); 
			viewport.y -= 0.5*(nh-viewport.height); 
			viewport.width = nw;
			viewport.height = nh;
	
			if(viewport.x<0) viewport.x = 0;
			if(viewport.y<0) viewport.y = 0;
			if(viewport.width+viewport.x > 1) viewport.x = 1-viewport.width;
			if(viewport.height+viewport.y > 1) viewport.y = 1-viewport.height;
		}

		display();
	}
}
