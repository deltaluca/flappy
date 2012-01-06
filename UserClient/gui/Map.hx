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
import nme.text.TextField;
import nme.text.TextFormat;

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

enum ArrowType {
	aHold;
	aNormal;
	aSupport;
	aConvoy;
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

		icon_army = [];
		icon_fleet = [];
	}

	//--------------------------------------------------------------------------------------------

	public function arrow(x:Location, y:Location, type:ArrowType, s1:Bool, s2:Bool=false) {
		var xloc = location_point(x);
		var yloc = location_point(y);

		var arrow_height:Float;
		var col = Match.match(pair(type,s1),
			pair(aNormal, true ) = {
				arrow_height = 6;
				0;
			},
			pair(aNormal, false) = { //move bounced
				arrow_height = 3;
				0xff0000;
			},
			pair(aSupport, true ) = {
				arrow_height = 3;
				0x30f030;
			},
			pair(aSupport, false ) = { //support cut[Ma
				arrow_height = 2;
				0x10a010;
			},
			pair(aHold, true) = {
				arrow_height = 3;
				0x4040ff;
			},
			pair(aHold, false) = {
				arrow_height = 3;
				0;
			},
			_ = {
				arrow_height = 2;
				0xffffff;
			}
		);
		var arrow_width = arrow_height*0.75;

		var g = arrows.graphics;
		g.lineStyle(2,col,1);

		g.moveTo(xloc.x,xloc.y);
		var cx = (xloc.x+yloc.x)/2 - (yloc.y-xloc.y)*0.25;
		var cy = (xloc.y+yloc.y)/2 + (yloc.x-xloc.x)*0.25;
		g.curveTo(cx,cy,yloc.x,yloc.y);

		if(!s2) {
			var dcx = yloc.x-cx;
			var dcy = yloc.y-cy;
			var dcl = 1/Math.sqrt(dcx*dcx+dcy*dcy);
			dcx *= dcl; dcy *= dcl;
	
			g.beginFill(col,1);
			g.moveTo(yloc.x,yloc.y);
			g.lineTo(yloc.x - dcx*arrow_height + dcy*arrow_width,
					 yloc.y - dcy*arrow_height - dcx*arrow_width);
			g.lineTo(yloc.x - dcx*arrow_height - dcy*arrow_width,
					 yloc.y - dcy*arrow_height + dcx*arrow_width);
			g.lineTo(yloc.x,yloc.y);
			g.endFill();
		}else {
			g.beginFill(((col&0x7f7f7f)<<1)|(col&0x808080), 1);
			g.drawCircle(yloc.x,yloc.y,arrow_height);
			g.endFill();
		}
	}

	public function inform_defn(powers:Array<Int>, provinces:MdfProvinces, adjs:Array<MdfProAdjacencies>) {
/*		var spr = new Sprite();
		addChild(spr);
		var g = spr.graphics;
		g.lineStyle(2,0,1);
	
		for(adj in adjs) {
			var pro = adj.pro;
			var adjs = adj.coasts;

			for(adj in adjs) {
				switch(adj.unit) {
				case utArmy:
					for(loc in adj.locs)
						arrow({province:pro, coast:null}, loc);
				case utFleet:
					for(loc in adj.locs)
						arrow({province:pro, coast:adj.coast}, loc);
				default:
				}
			}
		}	*/
	}

	//--------------------------------------------------------------------------------------------

	/*

		discern when turn ends based on information supplied.

		When an order result is received, we begin rendering the arrows displaying unit movement and results
		When a supply ownership/location message is received, we assume that no more order results are to be given
		And arrows are cleared with units moved to the new location.

		To this effect, when supply/locations are informed, arrows are simply cleared which fits the above rules.
	
	*/

	//--------------------------------------------------------------------------------------------

	public function inform_result(order:MsgOrder, result:CompOrderResult) {
		switch(order) {
			case moHold(unitloc):
				arrow(unitloc.location, unitloc.location, aHold, Match.match(result.result, rSuccess=true, _=false), true);
			case moMove(unitloc, loc):
				arrow(unitloc.location, loc, aNormal, Match.match(result.result, rSuccess=true, _=false));
			case moSupport(unitloc, supportloc, move):
				var success = Match.match(result.result, rSupportCut=false,_=true);
				if(move==null) { //support a hold
					arrow(unitloc.location, supportloc.location, aSupport, success, true); 
				}else { //support a move
					arrow(unitloc.location, { province:move, coast:null /*!!!*/ }, aSupport, success);
				}	
			default: //don't care (yet)
		}
	}

	public function inform_supplyOwnerships(scos:Array<ScoEntry>) {
		arrows.graphics.clear();

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

		display();
	}

	public function inform_displayid() {
		displayid = !displayid;
		display();
	}

	var icon_army :Array<MipMap>;
	var icon_fleet:Array<MipMap>;
	function genunit(type:UnitType) {
		switch(type) {
			case utArmy:
				if(icon_army.length==0) return new MipMap([
					Assets.getBitmapData("Assets/army-big1.png"),
					Assets.getBitmapData("Assets/army.png"),
					Assets.getBitmapData("Assets/army-sm1.png")
				]);
				else return icon_army.pop();
			case utFleet:
				if(icon_fleet.length==0) return new MipMap([
					Assets.getBitmapData("Assets/fleet-big1.png"),
					Assets.getBitmapData("Assets/fleet.png"),
					Assets.getBitmapData("Assets/fleet-sm1.png")
				]);
				else return icon_fleet.pop();
		}
	}

	public function location_point(location:Location) {
		var id = TokenUtils.provinceId(location.province);
		var name = mapnames.nameOf(id);
		if(location.coast!=null) {
			name += " "+Match.match(location.coast,
				cNorth = "NC", cNorthEast = "NEC",
				cSouth = "SC", cSouthWest = "SWC",
				cEast  = "EC", cSouthEast = "SEC",
				cWest  = "WC", cNorthWest = "NWC"
			);
		}

		return mapdata.locations.get(name);
	}

	//-------------------------------------------------------------
	// Mapping locations to integers and back again. not just provinces to integers (mapnames)
	public static var coastids = [""," NC"," SC"," EC"," WC"," NEC"," SWC"," SEC"," NWC"];
	public static inline var COASTOFF = 26;

	public function province_coast(location:String) {
		var l3 = location.substr(location.length-3); var p3 = location.substr(0,location.length-3);
		var l4 = location.substr(location.length-4); var p4 = location.substr(0,location.length-4);
	
		var province = "";
		var coast = 0;
		if     (l3==" NC")  { province = p3; coast = 1; }
		else if(l3==" SC")  { province = p3; coast = 2; }
		else if(l3==" EC")  { province = p3; coast = 3; }
		else if(l3==" WC")  { province = p3; coast = 4; }
		else if(l4==" NEC") { province = p4; coast = 5; }
		else if(l4==" SWC") { province = p4; coast = 6; }
		else if(l4==" SEC") { province = p4; coast = 7; }
		else if(l4==" NWC") { province = p4; coast = 8; }
		else province = location;

		var provinceid = mapnames.idOf(province);
		return { value: provinceid | (coast << COASTOFF),
			provinceid: provinceid,
			  province: province,
				 coast: coastids[coast]
		};
	}
	public function location_pc(pc:Int) {
		var coast = pc >>> COASTOFF; pc ^= (coast<<COASTOFF);
		return mapnames.nameOf(pc) + coastids[coast];
	}
	//-------------------------------------------------------------

	var unitlocs:Array<{power:Int, pos:Point, type:UnitType, mip:MipMap}>;
	public function inform_locations(locs:Array<UnitWithLocAndMRT>) {
		arrows.graphics.clear();

		for(x in unitlocs) {
			removeChild(x.mip);
			switch(x.type) {
				case utArmy:  icon_army.push(x.mip);
				case utFleet: icon_fleet.push(x.mip);
			}
		}
		unitlocs = [];

		for(x in locs) {
			var u = x.unitloc;

			var pos = location_point(u.location);
			var mip = genunit(u.type);
			mip.filters = [MapConfig.powerFilter(u.power)];
			addChild(mip);
			unitlocs.push({power:u.power, pos:pos, mip:mip, type:u.type});
		}

		display();
	}

	//--------------------------------------------------------------------------------------------

	//mipmap of map graphics + mapdata for pointer selection and highlighting etc.
	var map:MipMap; var mapdata:map.Map; var mapnames:MapNames;
	//debug id's
	var debugids:IntHash<{p:TextField,i:TextField}>;
	public var displayid:Bool; //display debugid.i txtfield also.

	//supply centres
	var supplies:Hash<MipMap>;

	//highlighting of current region.
	var highlight:Sprite;
	//arrow rendering
	var arrows:Sprite;

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
		arrows = new Sprite();
		addChild(arrows);

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

		unitlocs = [];
		
		//highlight has this invisible box defined to match map dimensions
		//so that highlighted region drawn inside can be scaled and displayed correctly
		var invbox = new Sprite();
		invbox.graphics.lineStyle(1,0,0);
		invbox.graphics.drawRect(0,0,this.mapdata.width,this.mapdata.height);
		highlight.addChild(invbox);
		//so does arrows
		invbox = new Sprite();
		invbox.graphics.lineStyle(1,0,0);
		invbox.graphics.drawRect(0,0,this.mapdata.width,this.mapdata.height);
		arrows.addChild(invbox);

		///event handlers
		addEventListener(MouseEvent.MOUSE_DOWN, mdown);
		addEventListener(MouseEvent.MOUSE_UP, mup);
		addEventListener(MouseEvent.MOUSE_WHEEL, mwheel);
		addEventListener(MouseEvent.MOUSE_MOVE, mmove);

		//debug ids
		var font = Assets.getFont("Assets/Courier.ttf");

		debugids = new IntHash<{p:TextField,i:TextField}>();
		for(MDF in mapdata.locations.keys()) {
			var loc = mapdata.locations.get(MDF);
			var txt = new TextField();
			txt.defaultTextFormat = new TextFormat(font.fontName,10,0);
			txt.selectable = false;

			var txti = new TextField();
			txti.defaultTextFormat = new TextFormat(font.fontName,10,0x333333);
			txti.selectable = false;

			var id = province_coast(MDF);	
			debugids.set(id.value,{p:txt,i:txti});
			addChild(txt);
			addChild(txti);

			var mdftxt = if(id.coast=="") id.province else id.coast;
			var idtxt = if(id.coast=="") "0x"+StringTools.hex(id.provinceid) else "";

			txt.text = mdftxt;
			txti.text = idtxt;

			txt.width = 6*mdftxt.length+6;
			txti.width = 6*idtxt.length+6;
			txt.height = 10.2;
			txti.height = if(idtxt=="") 0 else 10.2;
		}
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

		highlight.x = arrows.x = map.x;
		highlight.y = arrows.y = map.y;
		highlight.width  = arrows.width  = map.width;
		highlight.height = arrows.height = map.height;

		var rad = Std.int(10*Math.sqrt(zoom_scale()) * (Match.match(stageScale, sSmall=1.0, sDefault=1.5, sLarge=2.0)));

		for(key in supplies.keys()) {
			var mp = supplies.get(key);
			var pos = mapdata.supplies.get(key);
			var npos = mapToScreen(pos.x,pos.y);

			mp.resize(rad,rad);
			mp.x = npos.x - (mp.width /2);
			mp.y = npos.y - (mp.height/2);
		}

		rad *= 2;

		for(x in unitlocs) {
			var pos = mapToScreen(x.pos.x,x.pos.y);
			var mp = x.mip;
			mp.resize(rad,Std.int(rad*mp.ratio));
			mp.x = pos.x - (mp.width /2);
			mp.y = pos.y - (mp.height/2);
		}

		if(true) {
			for(MDFid in debugids.keys()) {
				var txt = debugids.get(MDFid);	
				var MDF = location_pc(MDFid);
				var loc = mapdata.locations.get(MDF);
				var npos = mapToScreen(loc.x,loc.y);
				var sumh = txt.p.height + (displayid ? txt.i.height : 0);
				txt.p.x = npos.x-txt.p.width/2;
				txt.p.y = npos.y - sumh/2;
				txt.i.x = npos.x-txt.i.width/2;
				txt.i.y = npos.y - sumh/2 + txt.p.height;
				txt.i.visible = displayid;
			}
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
