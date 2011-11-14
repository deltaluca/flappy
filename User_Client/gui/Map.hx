package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;

import gui.Gui;

class Map extends GuiElem {
	public function new() {
		super();
		build();
	}

	var map:Bitmap;

	function build() {
		map = new Bitmap(Assets.getBitmapData("Assets/map-std.png"));
		addChild(map);
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
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
	}
}
