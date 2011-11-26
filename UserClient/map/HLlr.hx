package map;



	import map.HLex;
	import scx.Match;

	class PTU {
		static public function index(t:PathToken) return Type.enumIndex(t)
	}

	typedef VerbosePath = Array<VerbosePathCommand>;
	enum VerbosePathCommand {
		vpMoveTo(rel:Bool, x:Float,y:Float);
		vpLineTo(rel:Bool, x:Float,y:Float);
		vpHLineTo(rel:Bool, x:Float);
		vpVLineTo(rel:Bool, y:Float);
		vpCurveTo(rel:Bool, x:Float,y:Float,cx:Float,cy:Float);
		vpCubicTo(rel:Bool, x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float);
		vpSmoothQTo(rel:Bool, x:Float,y:Float);
		vpSmoothTo(rel:Bool, x:Float,y:Float, cx2:Float,cy2:Float);
		vpClose;
	}


enum Action {
	aE;
	aS(n:Int);
	aR(r:Int);
	aA;
	aG(n:Int);
}class ActionRule {
	public var from:Int; public var to:Int; public var rel:Bool; public var act:Action;
	public function new(from:Int,act:Action,?rel:Bool=false,?to:Int=-1) {
		this.from = from; this.act = act; this.rel = rel; if(to==-1) this.to = from else this.to = to;
	}
}
class HLlr {
	public static var errors:Array<String>;

	static var actions:Array<Array<ActionRule>>;
	static var rules:Array<{cb:Array<Dynamic>->Void,sym:Int,cnt:Int}>;
	static function init() {
		if(actions!=null) return;
		actions = new Array<Array<ActionRule>>();
		var ret = [];
		ret.push(new ActionRule(2,aS(32)));
		ret.push(new ActionRule(12,aG(1)));
		ret.push(new ActionRule(13,aG(3),true,14));
		ret.push(new ActionRule(24,aG(6)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aA));
		ret.push(new ActionRule(2,aS(32)));
		ret.push(new ActionRule(13,aG(2)));
		ret.push(new ActionRule(14,aG(4)));
		ret.push(new ActionRule(24,aG(6)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(1)));
		ret.push(new ActionRule(2,aR(1)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(0)));
		ret.push(new ActionRule(2,aR(0)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(2)));
		ret.push(new ActionRule(2,aR(2)));
		ret.push(new ActionRule(3,aS(10)));
		ret.push(new ActionRule(4,aS(37)));
		ret.push(new ActionRule(5,aS(41)));
		ret.push(new ActionRule(6,aS(38)));
		ret.push(new ActionRule(7,aS(42)));
		ret.push(new ActionRule(8,aS(55)));
		ret.push(new ActionRule(9,aS(64),true,10));
		ret.push(new ActionRule(15,aG(5)));
		ret.push(new ActionRule(16,aG(9)));
		ret.push(new ActionRule(17,aG(11),true,23));
		ret.push(new ActionRule(26,aG(18)));
		ret.push(new ActionRule(27,aG(20)));
		ret.push(new ActionRule(29,aG(22)));
		ret.push(new ActionRule(30,aG(24)));
		ret.push(new ActionRule(32,aG(26)));
		ret.push(new ActionRule(34,aG(28)));
		ret.push(new ActionRule(35,aG(30)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(3)));
		ret.push(new ActionRule(2,aR(3)));
		ret.push(new ActionRule(3,aS(10)));
		ret.push(new ActionRule(4,aS(37)));
		ret.push(new ActionRule(5,aS(41)));
		ret.push(new ActionRule(6,aS(38)));
		ret.push(new ActionRule(7,aS(42)));
		ret.push(new ActionRule(8,aS(55)));
		ret.push(new ActionRule(9,aS(64),true,10));
		ret.push(new ActionRule(16,aG(8)));
		ret.push(new ActionRule(17,aG(11),true,23));
		ret.push(new ActionRule(26,aG(18)));
		ret.push(new ActionRule(27,aG(20)));
		ret.push(new ActionRule(29,aG(22)));
		ret.push(new ActionRule(30,aG(24)));
		ret.push(new ActionRule(32,aG(26)));
		ret.push(new ActionRule(34,aG(28)));
		ret.push(new ActionRule(35,aG(30)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(25,aG(7)));
		ret.push(new ActionRule(36,aG(35)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(14)));
		ret.push(new ActionRule(2,aR(14),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(5)));
		ret.push(new ActionRule(2,aR(5),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(4)));
		ret.push(new ActionRule(2,aR(4),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(6)));
		ret.push(new ActionRule(2,aR(6),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(7)));
		ret.push(new ActionRule(2,aR(7),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(8)));
		ret.push(new ActionRule(2,aR(8),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(9)));
		ret.push(new ActionRule(2,aR(9),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(10)));
		ret.push(new ActionRule(2,aR(10),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(11)));
		ret.push(new ActionRule(2,aR(11),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(12)));
		ret.push(new ActionRule(2,aR(12),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(13)));
		ret.push(new ActionRule(2,aR(13),10));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(25,aG(19)));
		ret.push(new ActionRule(36,aG(35)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(15)));
		ret.push(new ActionRule(2,aR(15),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(28,aG(21)));
		ret.push(new ActionRule(36,aG(40)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(16)));
		ret.push(new ActionRule(2,aR(16),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(39)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(28,aG(23)));
		ret.push(new ActionRule(36,aG(40)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(17)));
		ret.push(new ActionRule(2,aR(17),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(39)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(31,aG(25)));
		ret.push(new ActionRule(36,aG(49)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(18)));
		ret.push(new ActionRule(2,aR(18),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(43)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(33,aG(27)));
		ret.push(new ActionRule(36,aG(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(19)));
		ret.push(new ActionRule(2,aR(19),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(56)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(33,aG(29)));
		ret.push(new ActionRule(36,aG(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(20)));
		ret.push(new ActionRule(2,aR(20),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(56)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(25,aG(31)));
		ret.push(new ActionRule(36,aG(35)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(21)));
		ret.push(new ActionRule(2,aR(21),10));
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(31)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(34)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(23)));
		ret.push(new ActionRule(2,aR(23),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(22)));
		ret.push(new ActionRule(2,aR(22),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(32)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(29)));
		ret.push(new ActionRule(2,aR(29),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(28)));
		ret.push(new ActionRule(2,aR(28),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(34)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(35)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(44)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(45)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(46)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(47)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(48)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(27)));
		ret.push(new ActionRule(2,aR(27),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(50)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(51)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(52)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(53)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(54)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(26)));
		ret.push(new ActionRule(2,aR(26),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(57)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(58)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(59)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(25)));
		ret.push(new ActionRule(2,aR(25),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(61)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(62)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aS(66)));
		ret.push(new ActionRule(36,aG(63)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(24)));
		ret.push(new ActionRule(2,aR(24),11));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(37)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(11,aR(38)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(30)));
		ret.push(new ActionRule(2,aR(30),11));
		actions.push(ret);

		rules = new Array<{cb:Array<Dynamic>->Void,sym:Int,cnt:Int}>();
		rules.push({cb:R0, sym:12, cnt:1});
		rules.push({cb:R1, sym:12, cnt:2});
		rules.push({cb:R2, sym:13, cnt:1});
		rules.push({cb:R3, sym:13, cnt:2});
		rules.push({cb:R4, sym:15, cnt:1});
		rules.push({cb:R5, sym:15, cnt:2});
		rules.push({cb:R6, sym:16, cnt:1});
		rules.push({cb:R7, sym:16, cnt:1});
		rules.push({cb:R8, sym:16, cnt:1});
		rules.push({cb:R9, sym:16, cnt:1});
		rules.push({cb:R10, sym:16, cnt:1});
		rules.push({cb:R11, sym:16, cnt:1});
		rules.push({cb:R12, sym:16, cnt:1});
		rules.push({cb:R13, sym:16, cnt:1});
		rules.push({cb:R14, sym:14, cnt:2});
		rules.push({cb:R15, sym:17, cnt:2});
		rules.push({cb:R16, sym:18, cnt:2});
		rules.push({cb:R17, sym:19, cnt:2});
		rules.push({cb:R18, sym:20, cnt:2});
		rules.push({cb:R19, sym:21, cnt:2});
		rules.push({cb:R20, sym:22, cnt:2});
		rules.push({cb:R21, sym:23, cnt:2});
		rules.push({cb:R22, sym:25, cnt:2});
		rules.push({cb:R23, sym:25, cnt:3});
		rules.push({cb:R24, sym:33, cnt:4});
		rules.push({cb:R25, sym:33, cnt:5});
		rules.push({cb:R26, sym:31, cnt:6});
		rules.push({cb:R27, sym:31, cnt:7});
		rules.push({cb:R28, sym:28, cnt:1});
		rules.push({cb:R29, sym:28, cnt:2});
		rules.push({cb:R30, sym:36, cnt:1});
		rules.push({cb:R31, sym:24, cnt:1});
		rules.push({cb:R32, sym:26, cnt:1});
		rules.push({cb:R33, sym:27, cnt:1});
		rules.push({cb:R34, sym:29, cnt:1});
		rules.push({cb:R35, sym:30, cnt:1});
		rules.push({cb:R36, sym:32, cnt:1});
		rules.push({cb:R37, sym:34, cnt:1});
		rules.push({cb:R38, sym:35, cnt:1});
	}
	static function getaction(cstate:Int,ind:Int) {
		var acts = actions[cstate];
		if(acts==null) return aE;

		for(x in acts) {
			if(x.from <= ind && ind <= x.to) {
				if(x.rel) {
					return switch(x.act) {
						case aR(z): aR(z+ind-x.from);
						case aS(z): aS(z+ind-x.from);
						case aG(z): aG(z+ind-x.from);
						default: throw "eep";
					};
				} else return x.act;
			}
			else if(x.from > ind) return aE;
		}
		return aE;
	}

	public static function parse(input:Array<PathToken>): VerbosePath  {
		init();

		errors = new Array<String>();
		var entry_state = 0;
var stack = new Array<Int>();
var ret = new Array<Dynamic>();
input.push(null);
var cur = input.shift();
var cstate = entry_state;
while(true){
	var action = getaction(cstate,cur==null ? 0 : PTU.index(cur)+2);
	switch(action) {
		case aS(id):
			ret.push(cur);
			stack.push(cstate);
			cstate = id;
			cur = input.shift();
		case aR(id):
			var c = rules[id];
			c.cb(ret);
			if(c.cnt>0) {
				for(i in 0...c.cnt-1) stack.pop();
				cstate = stack[stack.length-1];
			}else stack.push(cstate);
			var goto = getaction(cstate,c.sym);
			switch(goto) { case aG(id): cstate = id; default: }
		case aA:
			break;
		case aE:
			throw "yeeeeh, cba with errors";
		default:
	}
}
return if(ret.length==0) null else ret[0];
	}

	private static inline function R0(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R1(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: VerbosePath  = ret.pop();
var hllr__0: VerbosePath  = ret.pop();
		var retret: VerbosePath  = ({ hllr__0.concat(hllr__1); });
		ret.push(retret);
	}
	private static inline function R2(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R3(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: VerbosePath  = ret.pop();
var hllr__0: VerbosePath  = ret.pop();
		var retret: VerbosePath  = ({ hllr__0.concat(hllr__1); });
		ret.push(retret);
	}
	private static inline function R4(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R5(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: VerbosePath  = ret.pop();
var hllr__0: VerbosePath  = ret.pop();
		var retret: VerbosePath  = ({ hllr__0.concat(hllr__1); });
		ret.push(retret);
	}
	private static inline function R6(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: VerbosePath  = ({ [vpClose]; });
		ret.push(retret);
	}
	private static inline function R7(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R8(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R9(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R10(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R11(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R12(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R13(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R14(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var fst = hllr__1.shift();
		var ret = [vpMoveTo(hllr__0,fst.x,fst.y)];
		for(c in hllr__1)
			ret.push(vpLineTo(hllr__0,c.x,c.y));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R15(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(c in hllr__1) ret.push(vpLineTo(hllr__0,c.x,c.y));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R16(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Float>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(v in hllr__1) ret.push(vpHLineTo(hllr__0,v));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R17(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Float>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(v in hllr__1) ret.push(vpVLineTo(hllr__0,v));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R18(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(c in hllr__1) ret.push(vpCubicTo(hllr__0, c.x,c.y,c.cx1,c.cy1,c.cx2,c.cy2));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R19(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float,cx:Float,cy:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(c in hllr__1) ret.push(vpSmoothTo(hllr__0, c.x,c.y,c.cx,c.cy));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R20(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float,cx:Float,cy:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(c in hllr__1) ret.push(vpCurveTo(hllr__0, c.x,c.y,c.cx,c.cy));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R21(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<{x:Float,y:Float}>  = ret.pop();
var hllr__0: Bool  = ret.pop();
		var retret: VerbosePath  = ({
		var ret = [];
		for(c in hllr__1) ret.push(vpSmoothQTo(hllr__0, c.x,c.y));
		ret;
	});
		ret.push(retret);
	}
	private static inline function R22(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Float  = ret.pop();
var hllr__0: Float  = ret.pop();
		var retret: Array<{x:Float,y:Float}>  = ({ [{x:hllr__0,y:hllr__1}]; });
		ret.push(retret);
	}
	private static inline function R23(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2: Float  = ret.pop();
var hllr__1: Float  = ret.pop();
var hllr__0: Array<{x:Float,y:Float}>  = ret.pop();
		var retret: Array<{x:Float,y:Float}>  = ({ hllr__0.push({x:hllr__1,y:hllr__2}); hllr__0; });
		ret.push(retret);
	}
	private static inline function R24(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3: Float  = ret.pop();
var hllr__2: Float  = ret.pop();
var hllr__1: Float  = ret.pop();
var hllr__0: Float  = ret.pop();
		var retret: Array<{x:Float,y:Float,cx:Float,cy:Float}>  = ({ [{cx:hllr__0,cy:hllr__1,x:hllr__2,y:hllr__3}]; });
		ret.push(retret);
	}
	private static inline function R25(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Float  = ret.pop();
var hllr__3: Float  = ret.pop();
var hllr__2: Float  = ret.pop();
var hllr__1: Float  = ret.pop();
var hllr__0: Array<{x:Float,y:Float,cx:Float,cy:Float}>  = ret.pop();
		var retret: Array<{x:Float,y:Float,cx:Float,cy:Float}>  = ({ hllr__0.push({cx:hllr__1,cy:hllr__2,x:hllr__3,y:hllr__4}); hllr__0; });
		ret.push(retret);
	}
	private static inline function R26(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__5: Float  = ret.pop();
var hllr__4: Float  = ret.pop();
var hllr__3: Float  = ret.pop();
var hllr__2: Float  = ret.pop();
var hllr__1: Float  = ret.pop();
var hllr__0: Float  = ret.pop();
		var retret: Array<{x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float}>  = ({ [{cx1:hllr__0,cy1:hllr__1,cx2:hllr__2,cy2:hllr__3,x:hllr__4,y:hllr__5}]; });
		ret.push(retret);
	}
	private static inline function R27(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6: Float  = ret.pop();
var hllr__5: Float  = ret.pop();
var hllr__4: Float  = ret.pop();
var hllr__3: Float  = ret.pop();
var hllr__2: Float  = ret.pop();
var hllr__1: Float  = ret.pop();
var hllr__0: Array<{x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float}>  = ret.pop();
		var retret: Array<{x:Float,y:Float,cx1:Float,cy1:Float,cx2:Float,cy2:Float}>  = ({ hllr__0.push({cx1:hllr__1,cy1:hllr__2,cx2:hllr__3,cy2:hllr__4,x:hllr__5,y:hllr__6}); hllr__0; });
		ret.push(retret);
	}
	private static inline function R28(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Float  = ret.pop();
		var retret: Array<Float>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R29(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Float  = ret.pop();
var hllr__0: Array<Float>  = ret.pop();
		var retret: Array<Float>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R30(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Float  = ({ Match.match(hllr__0,ptNum(x)=x); });
		ret.push(retret);
	}
	private static inline function R31(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptMove(x)=x); });
		ret.push(retret);
	}
	private static inline function R32(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptLine(x)=x); });
		ret.push(retret);
	}
	private static inline function R33(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptHorz(x)=x); });
		ret.push(retret);
	}
	private static inline function R34(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptVert(x)=x); });
		ret.push(retret);
	}
	private static inline function R35(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptCubic(x)=x); });
		ret.push(retret);
	}
	private static inline function R36(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptSmooth(x)=x); });
		ret.push(retret);
	}
	private static inline function R37(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptQuad(x)=x); });
		ret.push(retret);
	}
	private static inline function R38(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:PathToken = ret.pop();
		var retret: Bool  = ({ Match.match(hllr__0,ptSmoothQ(x)=x); });
		ret.push(retret);
	}
}
