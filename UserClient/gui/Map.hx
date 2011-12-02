package gui;

import nme.display.Sprite;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.Point;

import nme.filters.BlurFilter;
import nme.filters.ColorMatrixFilter;
import nme.events.MouseEvent;

import gui.Gui;
import gui.MipMap;
import gui.ColorMatrix;

import map.MapReader;
import map.MapDef;

import daide.Language;
import daide.Tokens;

import scx.Match;

class MapConfig {
	//power colours, offset by 1 so that powers[0] = UNO colour
	public static var powers:Array<Int> = [
		0xbfbdbe, // <-- UNO

		0xa9283f, // <-- power 0
		0x4552b6, // onwards
		0x40abf7,
		0x483f1b,
		0x5f9061,
		0xb1a3bc,
		0xdfad32
	];

	static var power_filters:Array<ColorMatrixFilter>;
	public static function powerFilter(power:Null<Int>) {
		return if(power==null) power_filters[0] else power_filters[power+1];
	}

	public static function init() {
		power_filters = new Array<ColorMatrixFilter>();
		for(p in powers) power_filters.push(ColorMatrix.fromred(p).filter());
	}
}

class Map extends GuiElem {
	//mapdata corresponding to the input .svg file for clickable regions and other metadata.
	//graphics being ordered large to small for building mipmap.
	public function new(mapdef:MapDefinition) {
		super();

		this.mapdata = MapReader.parse(mapdef.regions);
		map = new MipMap(mapdef.mipmap);
		this.mapnames = MapReader.names(mapdef.names);

		MapConfig.init();

		build();
		viewport = null;
	}

	//--------------------------------------------------------------------------------------------

	public function inform_supplyOwnerships(scos:Array<ScoEntry>) {
		for(sco in scos) {
			var power = sco.power;
			var cmf = MapConfig.powerFilter(power);
			for(loc in sco.locs) {
				var id = TokenUtils.provinceId(loc);
				var name = mapnames.nameOf(id);
				var sc:MipMap = supplies.get(name);
				sc.filters = [cmf];
			}
		}
	}

	//--------------------------------------------------------------------------------------------

	//mipmap of map graphics + mapdata for pointer selection and highlighting etc.
	var map:MipMap; var mapdata:map.Map; var mapnames:MapNames;

	//supply centres
	var supplies:Hash<MipMap>;

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
		var mapp = screenToMap(stage.mouseX, stage.mouseY);
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
//		highlight.filters= [new BlurFilter(4,4,1)];

		//
		var cmf = ColorMatrix.fromred(0xffffff).filter();
		supplies = new Hash<MipMap>();
		for(key in mapdata.supplies.keys()) {
			var mp = new MipMap([
				Assets.getBitmapData("Assets/supply_centre-big1.png"),
				Assets.getBitmapData("Assets/supply_centre.png"),
				Assets.getBitmapData("Assets/supply_centre-sm1.png")
			]);
			supplies.set(key, mp);
			addChild(mp);
			mp.filters = [cmf];
		}
		
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

	//take point in mapdata coordinates
	//return point corresponding to screen coordinate
	public function mapToScreen(x:Float,y:Float) {
		return new Point(
			(x/mapdata.width  - viewport.x)/viewport.width  * stageWidth,
			(y/mapdata.height - viewport.y)/viewport.height * stageHeight
		);
	}

	//take point in screen coordinates
	//return point corresponding to mapdata coordinates
	public function screenToMap(x:Float,y:Float) {
		return new Point(
			(x/stageWidth  * viewport.width  + viewport.x)*mapdata.width,
			(y/stageHeight * viewport.height + viewport.y)*mapdata.height
		);
	}

	public function display() {
		map.x = -viewport.x*map.width;
		map.y = -viewport.y*map.height;

		highlight.x = map.x;
		highlight.y = map.y;
		highlight.width = map.width;
		highlight.height = map.height;

		for(key in supplies.keys()) {
			var mp = supplies.get(key);
			var pos = mapdata.supplies.get(key);
			var npos = mapToScreen(pos.x,pos.y);

			var rad = Std.int(10*Math.sqrt(zoom_scale()) * (Match.match(stageScale, sSmall=1.0, sDefault=1.5, sLarge=2.0)));
			mp.resize(rad,rad);
			mp.x = npos.x - (mp.width /2);
			mp.y = npos.y - (mp.height/2);
		}
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

	function zoom_scale() return Math.pow(1.2,zoom)

	//--------------------------------------------------------------------------------------------

	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		//else assume on scale mode has changed
		if(width>0 && height>0) {
			stageWidth  = width;
			stageHeight = height;
			stageScale = scale;
	
			var ratio = map.ratio;
			var zoomv = zoom_scale();
	
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
		}

		display();
	}
}
