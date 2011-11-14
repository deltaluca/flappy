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
		map.width = width;
		map.height = height;
	}
}
