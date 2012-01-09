package gui;

import gui.Menu;
import gui.Button;
import gui.Map;

import map.MapDef;
import daide.Language;

import cpp.Sys;

import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.display.Sprite;
import nme.ui.Keyboard;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFieldType;
import nme.Assets;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;

import gui.Interface;

enum ScaleMode {
	sSmall;
	sDefault;
	sLarge;
}

class GuiElem extends Sprite {
	
	public function getBounds(?m:Matrix) {
		var m2 = new Matrix(1,0,0,1, x,y);
		if(m!=null) m2.concat(m);

		var ret = new Rectangle(m2.tx,m2.ty,width,height);
		for(c in 0...numChildren) {
			var ch = getChildAt(c);
			if(Std.is(ch, GuiElem)) {
				var t = cast(ch,GuiElem).getBounds(m2);
				ret = ret.union(t);
			}else {
				var t = new Rectangle(m2.tx+ch.x,m2.ty+ch.y,ch.width,ch.height);
				ret = ret.union(t);
			}
		}

		return ret;
	}

	public function new() {
		super();
	}

	public function resize(width:Int,height:Int,scale:ScaleMode) {}
}

class Gui extends GuiElem {
	public function new() {
		super();
		build();
	}

	var int:GuiInterface;
	public function bind(int:GuiInterface) {
		this.int = int;
	}

	//mapg is placed on display list by default so that initial map load can swap it's place.
	public var map:Map; var mapg:Sprite;

	var statmenu:Menu; //status
	var mainmenu:Menu; //main

	var ip:Textual;
	var port:Textual;
	var phases:Array<MipMap>;
	var year:Textual;

	var stageWidth:Int; var stageHeight:Int; var scaleMode:ScaleMode;
	var topbar:Sprite;

	var warnings:Array<nme.text.TextField>;
	function build() {
		addChild(mapg = new Sprite());
		
		topbar = new Sprite();
		var m = new nme.geom.Matrix();
		m.createGradientBox(25,27,Math.PI/2,0,0);
		topbar.graphics.beginGradientFill(nme.display.GradientType.LINEAR,
			[0xffffff,0xdfdfdf,0x444444,0x444444],
			[1       ,1       ,1       ,0       ],
			[0       ,0xd9    ,0xec    ,0xff    ],
			m
		);
		topbar.graphics.drawRect(0,0,25,27);
		addChild(topbar);

		addChild(statmenu = new Menu());
		addChild(mainmenu = new Menu());

		//warnings -- quickly written
		warnings = [];
		var font = Assets.getFont("Assets/Courier.ttf");
		var me = this;
		function warning(info:String) {
			var txt = new nme.text.TextField();
			txt.defaultTextFormat = new nme.text.TextFormat(font.fontName,16,0);
			txt.filters = [new nme.filters.GlowFilter(0xffffff,0.6,4,6,4,1)];
			txt.width = info.length*20*72/96;
			txt.text = info;
			txt.height = 19;
			me.warnings.push(txt);
			me.addChild(txt);
			var tim = new haxe.Timer(2000);
			tim.run = function() {
				me.removeChild(txt);
				me.warnings.shift();
				for(w in me.warnings) w.y -= 19;
			}
			txt.y = 25+(me.warnings.length-1)*19;
			me.refresh();
		}
		//

		function icon(name:String,small=false) {
			var but = new RoundButton(25);
			var ex = new MipMap([Assets.getBitmapData("Assets/"+name+".png")]);
			but.addChild(ex);
			but.onResize = function(w,_,_) {
				var ws = Std.int(w*(small ? 30/50 : 40/50));
				ex.resize(ws,ws);
				ex.x = ex.y = (w-ws)/2;
			}
			return but;
		}

		var close = icon("PowerButton");
		close.onClick = function() {
			Sys.exit(0);
		}

		var connect = icon("ConnectionButton");
		connect.onClick = function() {
			try {
				int.observer(ip.txt,Std.parseInt(port.txt));
			}catch(e:Dynamic) {
				warning("Connection failure");
			}
		}

		var t = new Textual(3,14,"ip:");
		t.set(32,17);
		mainmenu.insert(t);
		ip = new Textual(15);
		ip.set(140,18);
		mainmenu.insert(ip);

		var t = new Textual(5,14,"port:");
		t.set(50,17);
		mainmenu.insert(t);
		port = new Textual(5);
		port.set(53,18);
		mainmenu.insert(port);

		mainmenu.insert(new Spacer(10));
		mainmenu.insert(connect);
		mainmenu.insert(new Spacer(30));
		mainmenu.insert(close);

		ip.txt = "172.16.135.128";
		port.txt = "4444";

		//------------------------------------------------

		var pause = icon("Pause",true);
		pause.onClick = function() {
			int.pause();
		}
		var step = icon("Step",true);
		step.onClick = function() {
			int.step();
		}
		var play = icon("Play",true);
		play.onClick = function() {
			int.play();
		}
		var faster = icon("Faster",true);
		faster.onClick = function() {
			int.setDelay(int.getDelay()/1.5);
		}
		var slower = icon("Slower",true);
		slower.onClick = function() {
			int.setDelay(int.getDelay()*1.5);
		}

		statmenu.insert(pause);
		statmenu.insert(step);
		statmenu.insert(play);
		statmenu.insert(new Spacer(20));
		statmenu.insert(faster);
		statmenu.insert(slower);
		statmenu.insert(new Spacer(30));

		var phase = new Spacer(25);
		statmenu.insert(phase);

		phases = [];
		phases.push(new MipMap([Assets.getBitmapData("Assets/Spring.png")]));
		phases.push(new MipMap([Assets.getBitmapData("Assets/Summer.png")]));
		phases.push(new MipMap([Assets.getBitmapData("Assets/Fall.png")]));
		phases.push(new MipMap([Assets.getBitmapData("Assets/Autumn.png")]));
		phases.push(new MipMap([Assets.getBitmapData("Assets/Winter.png")]));
		for(p in phases) {
			p.resize(23,23);
			phase.addChild(p);
			p.visible = false;
		}

		year = new Textual(4,17,"    ");
		year.set(63,20);
		statmenu.insert(year);

	}

	public function inform_turn(turn:Turn) {
		for(p in phases) p.visible = false;

		year.txt = Std.string(turn.turn);
		switch(turn.phase) {
			case pSpring: phases[0].visible = true;
			case pSummer: phases[1].visible = true;
			case pFall:   phases[2].visible = true;
			case pAutumn: phases[3].visible = true;
			case pWinter: phases[4].visible = true;
		}	
	}

	var currentMap:String;
	public function load(mapname:String) {
		mapname = mapname.toLowerCase();
		if(mapname==currentMap) return;

		currentMap = mapname;
		var mapdef = MapDef.lookup(mapname);
		var nmap = new Map(mapdef);
		addChild(nmap);

		if(map==null) {
			swapChildren(nmap,mapg);
			removeChild(mapg);
			mapg = null;
		}else {
			swapChildren(nmap,map);
			removeChild(map);
			map.dispose();
		}
		
		map = nmap;

		if(scaleMode!=null) resize(stageWidth,stageHeight,scaleMode);
	}

	public function inform_locations(locs:Array<UnitWithLocAndMRT>) {
		map.inform_locations(locs);
	}

	public function inform_iam(power:Null<Int>, passcode:Int) {
		if(power==null) {
			//observer
		}else {
		}
	}

	public function refresh() {
		resize(stageWidth,stageHeight,scaleMode);
	}
	public override function resize(width:Int,height:Int,scale:ScaleMode) {
		stageWidth = width;
		stageHeight = height;
		scaleMode = scale;

		topbar.width = width;

		if(map!=null) {
			map.y = 25;
			map.resize(width,height-25,scale);
		}

		statmenu.resize(-1,-1,scale);
		mainmenu.resize(-1,-1,scale);

		var bnds = statmenu.getBounds();
		statmenu.y += -bnds.y;
		statmenu.x += -bnds.x;
		
		var bnds = mainmenu.getBounds();
		mainmenu.x += width-bnds.width-bnds.x;
		mainmenu.y += -bnds.y;
		
		for(w in warnings) {
			w.x = (width - w.width)/2;
		}
	}
}

