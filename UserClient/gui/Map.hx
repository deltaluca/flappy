package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import nme.filters.BlurFilter;

import gui.Gui;
import gui.MipMap;

import map.MapReader;

class Map extends GuiElem {
	public function new() {
		super();
		build();
		viewport = null; 
	}

	var map:MipMap; var mapdata:map.Map;
	var highlight:Sprite;
	var viewport:Rectangle;
	public var zoom:Int;

	var stageWidth :Int;
	var stageHeight:Int;
	var stageScale:ScaleMode;

	public function load(mapdata:String, graphics:Array<BitmapData>) {
		this.mapdata = MapReader.parse(mapdata);
		if(map!=null) removeChild(map);
		map = new MipMap(graphics);
		addChild(map);
		swapChildren(highlight,map);
		var invbox = new Sprite();
		invbox.graphics.lineStyle(1,0,0);
		invbox.graphics.drawRect(0,0,this.mapdata.width,this.mapdata.height);
		highlight.addChild(invbox);
	}

	function build() {
		zoom = 0;

		highlight = new Sprite();	
		addChild(highlight);
		highlight.filters= [new BlurFilter(4,4,1)];

		var drag = false;
		var px:Float; var py:Float;
		var stage = flash.Lib.current.stage;
		addEventListener(nme.events.MouseEvent.MOUSE_DOWN, function(_) {
			drag = true;
			px = stage.mouseX;
			py = stage.mouseY;

			if(mapdata!=null) {
				var mapp = new Point(
					(px/stageWidth*viewport.width + viewport.x)*mapdata.width,
					(py/stageHeight*viewport.height + viewport.y)*mapdata.height
				);
				var province:MapProvince = mapdata.province(mapp);
				if(province!=null) trace(province.id); else trace("nada");
			
				if(province!=null) {
					var g = highlight.graphics;
					g.clear();
					g.lineStyle(2,0xff0000,1);
					for(path in province.paths) {
						g.moveTo(path[0].x,path[0].y);
						for(i in 1...path.length) g.lineTo(path[i].x,path[i].y);
						g.lineTo(path[0].x,path[0].y);
					} 
				}
			}
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

			if(map!=null) {
				viewport.x -= (cx-px)/map.width;
				viewport.y -= (cy-py)/map.width;
				clamp_viewport();
			}

			display();

			px = cx;
			py = cy;
		});
	}

	public function display() {
		if(map==null) return;

		map.x = -viewport.x*map.width;
		map.y = -viewport.y*map.height;

		highlight.x = map.x;
		highlight.y = map.y;
		highlight.width = map.width;
		highlight.height = map.height;
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
		if(map==null) return;

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
