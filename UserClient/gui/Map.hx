package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import gui.Gui;
import gui.MipMap;

class Map extends GuiElem {
	public function new() {
		super();
		build();
		viewport = null; 
	}

	var map:MipMap;
	var viewport:Rectangle;
	public var zoom:Int;

	var stageWidth :Int;
	var stageHeight:Int;
	var stageScale:ScaleMode;

	function build() {
		map = new MipMap([
			Assets.getBitmapData("Assets/map-std-big1.png"),
			Assets.getBitmapData("Assets/map-std.png"),
			Assets.getBitmapData("Assets/map-std-sm1.png")
		]);
		addChild(map);

		zoom = 0;	

		var drag = false;
		var px:Float; var py:Float;
		var stage = flash.Lib.current.stage;
		addEventListener(nme.events.MouseEvent.MOUSE_DOWN, function(_) {
			drag = true;
			px = stage.mouseX;
			py = stage.mouseY;
		});
		addEventListener(nme.events.MouseEvent.MOUSE_UP, function(_) {
			drag = false;
		});

		addEventListener(nme.events.MouseEvent.MOUSE_WHEEL, function(ev) {
			setzoom(zoom-ev.delta);
		});

		var me = this;
		addEventListener(nme.events.MouseEvent.MOUSE_MOVE, function(_) {
			if(!drag) return;

			var cx = stage.mouseX;
			var cy = stage.mouseY;

			viewport.x -= (cx-px)/map.width;
			viewport.y -= (cy-py)/map.width;
			clamp_viewport();

			display();

			px = cx;
			py = cy;
		});
	}

	public function display() {
		map.x = -viewport.x*map.width;
		map.y = -viewport.y*map.height;
	}

	public function clamp_viewport() {
		if(viewport.x<0) viewport.x = 0;
		if(viewport.y<0) viewport.y = 0;
		if(viewport.width +viewport.x > 1) viewport.x = 1-viewport.width;
		if(viewport.height+viewport.y > 1) viewport.y = 1-viewport.height;
	}

	public function setzoom(z:Int) {
		zoom = z; if(zoom<0) zoom = 0; if(zoom>10) zoom = 10;
		resize(stageWidth,stageHeight,stageScale);
	}

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		stageWidth  = width;
		stageHeight = height;
		stageScale = scale;

		var ratio = map.ratio;

		var zoomv = Math.pow(1.2,zoom);

		var width_h  = ratio*width*zoomv;
		if(width_h > height*zoomv) {
			map.resize(Std.int(width*zoomv), Std.int(width_h));
		}else {
			var height_w = height*zoomv/ratio;
			map.resize(Std.int(height_w),Std.int(height*zoomv));
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
			clamp_viewport();	
		}

		display();
	}
}
