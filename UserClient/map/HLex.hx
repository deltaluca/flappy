package map;

	enum PathToken {
		ptMove(rel:Bool);
		ptClose;
		ptLine(rel:Bool);
		ptVert(rel:Bool);
		ptHorz(rel:Bool);
		ptCubic(rel:Bool);
		ptSmooth(rel:Bool);	
		ptQuad(rel:Bool);
		ptSmoothQ(rel:Bool);
		ptNum(x:Float);
	}
class HLex {
	static inline var entry_state:Int = 3;
	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([48,57,16]);
transitions.push(cur);
var cur = [];
cur.push([48,57,14]);
transitions.push(cur);
var cur = [];
cur.push([43,43,1]);
cur.push([45,45,1]);
cur.push([48,57,14]);
transitions.push(cur);
var cur = [];
cur.push([9,10,5]);
cur.push([13,13,5]);
cur.push([32,32,5]);
cur.push([44,44,5]);
cur.push([43,43,4]);
cur.push([45,45,4]);
cur.push([46,46,0]);
cur.push([48,57,15]);
cur.push([67,67,10]);
cur.push([99,99,10]);
cur.push([76,76,8]);
cur.push([108,108,8]);
cur.push([77,77,6]);
cur.push([109,109,6]);
cur.push([81,81,12]);
cur.push([113,113,12]);
cur.push([83,83,11]);
cur.push([115,115,11]);
cur.push([84,84,13]);
cur.push([116,116,13]);
cur.push([86,86,9]);
cur.push([118,118,9]);
cur.push([90,90,7]);
cur.push([122,122,7]);
transitions.push(cur);
var cur = [];
cur.push([46,46,0]);
cur.push([48,57,15]);
transitions.push(cur);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
var cur = [];
cur.push([48,57,14]);
transitions.push(cur);
var cur = [];
cur.push([46,46,0]);
cur.push([48,57,15]);
cur.push([69,69,2]);
cur.push([101,101,2]);
transitions.push(cur);
var cur = [];
cur.push([48,57,16]);
cur.push([69,69,2]);
cur.push([101,101,2]);
transitions.push(cur);
}
        static var accepting = [false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true];
	public static function lexify(input:String):Array<PathToken> {
		init();
var ret = new Array<PathToken>();
var valid = false;
var valcnt = 0;
var attr = 0;
var errstate = false;
var errstr:String = null;

var state = entry_state;
var pos = 0;
var ipos = pos;

while(pos<input.length) {
	//evaluate next state to progress to.
	var trans = transitions[state];
	var char = input.charCodeAt(pos);

	state = -1;
	if(trans!=null){
		for(range in trans) {
			if(char>=range[0] && char<=range[1]) {
				state = range[2];
				break;
			}
		}
	}

	if(state==-1) {
		//ERROR?
		if(!valid) {
			if(!errstate) {
				if(errstr==null) errstr = input.charAt(ipos);
				else errstr += input.charAt(ipos);
			}else errstr += String.fromCharCode(char);
			pos = ipos + 1;
		}else {
			if(errstr!=null) {
				var tok = errtok(errstr);
				if(tok!=null) ret.push(tok);
				errstr = null;
			}
			var tok = tokenof(attr,input.substr(ipos,valcnt));
			if(tok!=null) ret.push(tok);
			pos = ipos+valcnt;
		}
		errstate = !valid;
		state = entry_state;
		valid = false;
		ipos = pos;
	}else {
		pos++;
		errstate = false;
	}

	if(accepting[state]) {
		valid = true;
		valcnt = pos-ipos;
		attr = state;
	}else if(pos==input.length) {
		if(!valid) {
			if(!errstate) {
				if(errstr==null) errstr = input.charAt(ipos);
				else errstr += input.charAt(ipos);
			}
			var tok = tokenof(attr,input.substr(ipos,valcnt));
			if(tok!=null) ret.push(tok);
			pos = ipos+valcnt;
		}
		errstate = !valid;
		state = entry_state;
		valid = false;
		ipos = pos;
	}
}

if(ipos<input.length) {
	if(!valid) ret.push(errtok(input.substr(ipos)));
	else {
		if(errstr!=null) {
			var tok = errtok(errstr);
			if(tok!=null) ret.push(tok);
			errstr = null;
		}
		var tok = tokenof(attr,input.substr(ipos,valcnt));
		if(tok!=null) ret.push(tok);
		pos = ipos+valcnt;
	}
}

if(errstr!=null) {
	var tok = errtok(errstr);
	if(tok!=null) ret.push(tok);
	errstr = null;
}

return ret;
}
	static inline function errtok(hxl_match:String):PathToken {
		return null;
	}
	static function tokenof(id:Int, hxl_match:String):PathToken {
		switch(id) {
			default: return null;
            case 6:
				return ({ ptMove( hxl_match =="m"); });
            case 7:
				return ({ ptClose; });
            case 8:
				return ({ ptLine( hxl_match =="l"); });
            case 9:
				return ({ ptVert( hxl_match =="v"); });
            case 10:
				return ({ ptCubic( hxl_match =="c"); });
            case 11:
				return ({ ptSmooth( hxl_match =="s"); });
            case 12:
				return ({ ptQuad( hxl_match =="q"); });
            case 13:
				return ({ ptSmoothQ( hxl_match =="t"); });
            case 14:
				return ({ ptNum(Std.parseFloat( hxl_match )); });
            case 15:
				return ({ ptNum(Std.parseFloat( hxl_match )); });
            case 16:
				return ({ ptNum(Std.parseFloat( hxl_match )); });
        }
	}
}
