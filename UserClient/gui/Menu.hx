package gui;

import nme.display.Sprite;
import nme.Assets;

import gui.Gui;

class Menu extends GuiElem {
	public var elts:Array<GuiElem>;	

	public function new() {
		super();
		elts = new Array<GuiElem>();
	}

	public function insert(x:GuiElem) {
		elts.push(x);
		addChild(x);
	}

	public override function resize(_:Int,_:Int,scale:ScaleMode) {
		var px = 0.0;
		for(e in elts) {
			e.resize(-1,-1,scale);
			var bnd = e.getBounds();
			e.y -= bnd.y; e.y = (25-bnd.height)/2;
			e.x -= bnd.x; e.x += px;
			px += bnd.width;
		}
	}
}

class Spacer extends GuiElem {
	public function new(width:Int) {
		super();
		graphics.beginFill(0,0);
		graphics.drawRect(0,0,width,25);
	}

	public override function resize(_:Int,_:Int,scale:ScaleMode) {
	}
}

class Textual extends GuiElem {
	public function set(w:Int,h:Int) {
		txtf.width = w;
		txtf.height = h;
	}
	public function new(maxchar:Int, size:Int=16, txt="") {
		super();
		txtf = new nme.text.TextField();
		var font = Assets.getFont("Assets/Courier.ttf");
		txtf.defaultTextFormat = new nme.text.TextFormat(font.fontName,size,0);
	
		addChild(txtf);

		if(txt!="") {
			this.txt = txt;
			txtf.selectable = false;
		}else {
			txtf.type = nme.text.TextFieldType.INPUT;
			txtf.maxChars = maxchar;
		}
	}
	
	var txtf:nme.text.TextField;
	public var txt(getText,setText):String;
	function getText() return txtf.text
	function setText(txt:String) return txtf.text = txt

	public override function resize(_:Int,_:Int,scale:ScaleMode) {
	}
}
