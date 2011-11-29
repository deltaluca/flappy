package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import nme.filters.BlurFilter;
import nme.events.MouseEvent;

import gui.Gui;
import gui.MipMap;

import map.MapReader;

class Map extends GuiElem {
	//mapdata corresponding to the input .svg file for clickable regions and other metadata.
	//graphics being ordered large to small for building mipmap.
	public function new(mapdata:String, graphics:Array<BitmapData>) {
		super();

		this.mapdata = MapReader.parse(mapdata);
		map = new MipMap(graphics);

		build();
		viewport = null;
	}

	//--------------------------------------------------------------------------------------------

	//mipmap of map graphics + mapdata for pointer selection and highlighting etc.
	var map:MipMap; var mapdata:map.Map;

	//highlighting of current region.
	var highlight:Sprite;

	//viewport corresponding to the application display in unit map coordinates.
	// viewport.xy, viewport.xy + viewport.wh in [0,1]
	var viewport:Rectangle;

	//zoom level, mapped to a real scale on display
	//bounds defined and enforced in setzoom
	public var zoom:Int;

	//application display with/height and DPI scale mode for graphics.
	var stageWidth :Int;
	var stageHeight:Int;
	var stageScale:ScaleMode;

	//--------------------------------------------------------------------------------------------

	public function dispose() {
		//another bug in NME means we cannot use weak reference event handlers.
		//or atleast not to anonymous functions but i don't trust it

		removeEventListener(MouseEvent.MOUSE_DOWN, mdown);
		removeEventListener(MouseEvent.MOUSE_UP, mup);
		removeEventListener(MouseEvent.MOUSE_WHEEL, mwheel);
		removeEventListener(MouseEvent.MOUSE_MOVE, mmove);
	}

	//--------------------------------------------------------------------------------------------
	/// event handlers

	//dragging of mouse
	var drag:Bool;
	var px:Float; var py:Float;

	function mdown(_) {
		drag = true;
		px = stage.mouseX;
		py = stage.mouseY;
	}
	function mmove(_) {
		var cx = stage.mouseX;
		var cy = stage.mouseY;

		if(drag) {
			viewport.x -= (cx-px)/map.width;
			viewport.y -= (cy-py)/map.height;
			clamp_viewport();
			display();

			px = cx; py = cy;
		}

		setprovince();
	}
	function mup(_) {
		drag = false;
	}
	function mwheel(ev) {
		setzoom(zoom - ev.delta);
		setprovince();
	} 

	//--------------------------------------------------------------------------------------------

	var selected:MapProvince;

	function setprovince() {
		var mapp = new Point();
		mapp.x = (stage.mouseX/stageWidth *viewport.width  + viewport.x)*mapdata.width;
		mapp.y = (stage.mouseY/stageHeight*viewport.height + viewport.y)*mapdata.height;

		var province = mapdata.province(mapp);
		var g = highlight.graphics;

		if(province != selected) {
			g.clear();
			if(province!=null) {
				g.lineStyle(2,0xff0000,1);
				for(path in province.paths) {
					g.moveTo(path[0].x,path[0].y);
					for(i in 1...path.length) g.lineTo(path[i].x,path[i].y);
					g.lineTo(path[0].x,path[0].y);
				}
			}		
		}

		selected = province;
	}

	//--------------------------------------------------------------------------------------------

	function build() {
		zoom = 0;

		addChild(map);

		highlight = new Sprite();	
		addChild(highlight);
		highlight.filters= [new BlurFilter(4,4,1)];
		
		//highlight has this invisible box defined to match map dimensions
		//so that highlighted region drawn inside can be scaled and displayed correctly
		var invbox = new Sprite();
		invbox.graphics.lineStyle(1,0,0);
		invbox.graphics.drawRect(0,0,this.mapdata.width,this.mapdata.height);
		highlight.addChild(invbox);

		///event handlers
		addEventListener(MouseEvent.MOUSE_DOWN, mdown);
		addEventListener(MouseEvent.MOUSE_UP, mup);
		addEventListener(MouseEvent.MOUSE_WHEEL, mwheel);
		addEventListener(MouseEvent.MOUSE_MOVE, mmove);
	}

	//--------------------------------------------------------------------------------------------

	public function display() {
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

	//--------------------------------------------------------------------------------------------

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
