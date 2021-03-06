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
	aMove;
	aRetreat;
	aSupport;
	aConvoy;
	aBuild;
	aDislodge;
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

		dislodged = [];
		icon_army = [];
		icon_fleet = [];
	}

	//--------------------------------------------------------------------------------------------

	public function stdarrow(x:Location, y:Location, type:ArrowType, s1=true) {
		arrow(location_point(x),location_point(y),type,s1);
	}
	public function arrow(xloc:Point, yloc:Point, type:ArrowType, s1=true) {
		var arrow_height:Float;
		var dashed = false;
		var col:Int = 0xffffff;

		switch(type) {
			case aMove:
				col = if(s1) 0xff0000 else 0x660000;
				arrow_height = 15;
			case aRetreat:
				col = if(s1) 0xff00ff else 0x660066;
				arrow_height = 15;
				dashed = true;
				xloc.x += 20;
				xloc.y += 20;
			case aSupport:
				col = if(s1) 0xff00 else 0x6600;
				arrow_height = 12;
				dashed = true;
			case aBuild:
				col = 0xffffff;
				arrow_height = 12;
				dashed = true;
			case aDislodge:
				col = 0xffffff;
				arrow_height = -8;
				yloc.x += 20;
				yloc.y += 20;
			default:
				arrow_height = 0;
		}
	
		var circle = arrow_height<0;
		arrow_height = Math.abs(arrow_height);
	
		var scale = Match.match(stageScale, sSmall=1.0, sDefault=1.5, sLarge=2.0);
		var sc = Math.max(1,scale*Math.sqrt(zoom_scale())*0.5);

		arrow_height *= sc;
		var arrow_width = arrow_height*0.75;

		var g = arrows.graphics;

		var nx = - (yloc.y-xloc.y);
		var ny =   (yloc.x-xloc.x);
		var nl = 1/Math.sqrt(nx*nx+ny*ny);
		nx*= nl;
		ny*= nl;

		var cx = (xloc.x+yloc.x)/2 - (yloc.y-xloc.y)*0.3;
		var cy = (xloc.y+yloc.y)/2 + (yloc.x-xloc.x)*0.3;
		var cvx = (xloc.x+yloc.x)/2 - (yloc.y-xloc.y)*0.2;
		var cvy = (xloc.y+yloc.y)/2 + (yloc.x-xloc.x)*0.2;

		//nme can't render non-convex polygons (BAH)
		//render arrow in patches
		var u = {x:xloc.x,y:xloc.y}; var un = {x:yloc.x+nx*arrow_width/2, y:yloc.y+ny*arrow_width/2};
		var v = {x:xloc.x,y:xloc.y}; var vn = {x:yloc.x-nx*arrow_width/2, y:yloc.y-ny*arrow_width/2};

		//doesn't need to be accurate.
		var arclength = Math.sqrt(Math.pow(yloc.x-xloc.x,2)+Math.pow(yloc.y-xloc.y,2));
		var cnt = Math.round(arclength/(5));

		for(i in 1...cnt) {
			var part = i%4;
			var skip = dashed && part<2;

			if(skip && part==0) {
				g.lineStyle(1,0,1);
				g.moveTo(u.x,u.y);
				g.lineTo(v.x,v.y);
			}

			var t = i/cnt;
			g.lineStyle(0,0,0);
			g.beginFill(col,skip?0.25:1.0);
			g.moveTo(u.x,u.y);
			g.lineTo(v.x,v.y);

			var ux = u.x; var uy = u.y;
			var vx = v.x; var vy = v.y;
			u.x = (1-t)*(1-t)*xloc.x + 2*(1-t)*t*cx + t*t*un.x;
			u.y = (1-t)*(1-t)*xloc.y + 2*(1-t)*t*cy + t*t*un.y;
			v.x = (1-t)*(1-t)*xloc.x + 2*(1-t)*t*cvx + t*t*vn.x;
			v.y = (1-t)*(1-t)*xloc.y + 2*(1-t)*t*cvy + t*t*vn.y;

			g.lineTo(v.x,v.y);
			g.lineTo(u.x,u.y);
			g.endFill();

			g.lineStyle(1,0,1);
			g.moveTo(ux,uy);
			g.lineTo(u.x,u.y);
			g.moveTo(vx,vy);
			g.lineTo(v.x,v.y);
			
			if(skip && part==1) {
				g.lineStyle(1,0,1);
				g.moveTo(u.x,u.y);
				g.lineTo(v.x,v.y);
			}

		}
		g.lineStyle(1,0,1);
		//----------------------

		if(!circle) {
			var dcx = yloc.x-cx;
			var dcy = yloc.y-cy;
			var dcl = 1/Math.sqrt(dcx*dcx+dcy*dcy);
			dcx *= dcl; dcy *= dcl;
	
			g.moveTo(yloc.x,yloc.y);
			g.beginFill(col,1);
			g.lineTo(yloc.x - dcx*arrow_height + dcy*arrow_width,
					 yloc.y - dcy*arrow_height - dcx*arrow_width);
			g.lineTo(yloc.x - dcx*arrow_height - dcy*arrow_width,
					 yloc.y - dcy*arrow_height + dcx*arrow_width);
			g.lineTo(yloc.x,yloc.y);
			g.endFill();
		}else {
			g.beginFill(col,1);
			g.drawCircle(yloc.x,yloc.y,arrow_height);
			g.endFill();
		}
	}

	public function inform_defn(powers:Array<Int>, provinces:MdfProvinces, adjs:Array<MdfProAdjacencies>) {
	}

	//--------------------------------------------------------------------------------------------

	public function clear_results() {
		arrows.graphics.clear();
	}

	public function inform_result(order:MsgOrder, result:CompOrderResult) {
		function dislodge(x:UnitWithLoc) {
			if(result.ret) {
				stdarrow(x.location,x.location,aDislodge);
				setDislodged(x,true);
			}
		}

		switch(order) {
			case moHold(unitloc):
				dislodge(unitloc);
				//display something when hold is fail?
			case moMove(unitloc, loc):
				dislodge(unitloc);
				var success = Match.match(result.result, rSuccess=true,_=false);
				stdarrow(unitloc.location, loc, aMove, success);
			case moSupport(unitloc, supportloc, move):
				dislodge(unitloc);
				var success = Match.match(result.result, rSupportCut=false,_=true);
				if(move==null) { //support a hold
					stdarrow(unitloc.location, supportloc.location, aSupport, success); 
				}else { //support a move
					stdarrow(unitloc.location, { province:move, coast:null /*!!!*/ }, aSupport, success);
				}	
			case moBuild(unitloc):
				dislodge(unitloc);
				var sco = supply_point(unitloc.location);
				arrow(sco, location_point(unitloc.location), aBuild, true);
			case moRetreat(unit,loc):
				var success = Match.match(result.result, rSuccess=true,_=false);
				stdarrow(unit.location,loc,aRetreat,success);
				var t = isDislodged(unit);
				if(t==null) { result.ret = true; dislodge(unit); }
				isDislodged(unit).rem = true;
			default: //don't care (yet)
		}
	}

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
					Assets.getBitmapData("Assets/army-big2.png"),
					Assets.getBitmapData("Assets/army-big1.png"),
					Assets.getBitmapData("Assets/army.png")
				]);
				else return icon_army.pop();
			case utFleet:
				if(icon_fleet.length==0) return new MipMap([
					Assets.getBitmapData("Assets/fleet-big2.png"),
					Assets.getBitmapData("Assets/fleet-big1.png"),
					Assets.getBitmapData("Assets/fleet.png")
				]);
				else return icon_fleet.pop();
		}
	}

	public function supply_point(location:Location) {
		var id = TokenUtils.provinceId(location.province);
		var name = mapnames.nameOf(id);

		return mapdata.supplies.get(name);
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

		var ret = mapdata.locations.get(name);
		return new Point(ret.x,ret.y);
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

	var dislodged:Array<{unit:UnitWithLoc,rem:Bool}>;
	public function isDislodged(x:UnitWithLoc) {
		for(dx in dislodged) {
			var d = dx.unit;
			if(d.power == x.power && Type.enumEq(x.type,d.type) && Type.enumEq(x.location.province,d.location.province) && Type.enumEq(x.location.coast,d.location.coast))
				return dx;
		}
		return null;
	}

	public function setDislodged(x:UnitWithLoc, add:Bool) {
		if(add) {
			if(isDislodged(x)!=null) return;
			else dislodged.push({unit:x,rem:false});
		}else {
			var d = isDislodged(x);
			if(d==null) return;

			for(i in 0...dislodged.length) {
				if(dislodged[i]==d) {
					dislodged[i] = dislodged[dislodged.length-1];
					dislodged.pop();
					break;
				}
			}
		}
	}

	var unitlocs:Array<{power:Int, pos:Point, type:UnitType, mip:MipMap, dis:Bool}>;
	public function inform_locations(locs:Array<UnitWithLocAndMRT>) {
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
			var dis = isDislodged(u);
			if(dis!=null && dis.rem) {
				setDislodged(u,false);
				dis = null;
			}

			var mip = genunit(u.type);
			mip.filters = [MapConfig.powerFilter(u.power)];
			addChild(mip);
			unitlocs.push({power:u.power, pos:pos, mip:mip, type:u.type, dis:dis!=null});
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
		//addChild(highlight);
		arrows = new Sprite();

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
			txt.height = 13.2;
			txti.height = if(idtxt=="") 0 else 12.2;

			txt.filters = [new nme.filters.GlowFilter(0xffffff,0.6,4,6,4,1)];
		}

		addChild(arrows);
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

		var scale = Match.match(stageScale, sSmall=1.0, sDefault=1.5, sLarge=2.0);
		var rad = Std.int(15*zoom_scale() * scale);

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
			var ploc = if(x.dis) new Point(x.pos.x+20,x.pos.y+20) else x.pos;
			var pos = mapToScreen(ploc.x,ploc.y);
			var mp = x.mip;
			mp.resize(rad,Std.int(rad*mp.ratio));
			mp.x = pos.x - (mp.width /2);
			mp.y = pos.y - (mp.height/2);
		}

		var sc = scale*Math.sqrt(zoom_scale())*0.8;

		for(MDFid in debugids.keys()) {
			var txt = debugids.get(MDFid);	
			var MDF = location_pc(MDFid);
			var loc = mapdata.locations.get(MDF);
			var npos = mapToScreen(loc.x,loc.y);
		
			txt.i.scaleX = txt.i.scaleY = txt.p.scaleX = txt.p.scaleY = sc;
			txt.p.x = npos.x-txt.p.width/2*sc;
			txt.p.y = npos.y - txt.p.height/2*sc;
			txt.i.x = npos.x-txt.i.width/2*sc;
			txt.i.y = txt.p.y + txt.p.height*sc;
			txt.i.visible = displayid;
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
