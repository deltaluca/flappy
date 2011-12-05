package daide;




import daide.Tokens;
import daide.Language;
import Type;

class TU {

	static public function text(t:Token) {
		return switch(t) { case tText(x): x; default: null; };
	}
	static public function nonzero(t:Token) {
		return switch(t) { case tNonZero(x): x; default: -1; };
	}
	static public function power(t:Token) {
		return switch(t) { case tPower(x): x; default: -1; };
	}
	static public function province(t:Token) {
		return switch(t) { case tProvince(x): x; default: null; };
	}
	static public function coast(t:Token) {
		return switch(t) { case tCoast(x): x; default: null; };
	}
	static public function unitType(t:Token) {
		return switch(t) { case tUnitType(x): x; default: null; };
	}
	static public function phase(t:Token) {
		return switch(t) { case tPhase(x): x; default: null; };
	}
	static public function parameter(t:Token) {
		return switch(t) { case tParameter(x): x; default: null; };
	}

	//need a mapping [0,#tokens) in order tokens are declared
	//this is complicated due to the nesting of Token declarations
	//otherwise could have simply used Type.enumIndex(t)
	static var offsets:Array<Int> = null;
	static public function index(t:Token) {
		if(offsets==null) {
			offsets = [0,1,2,3,4];
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(UnitType).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Order).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(OrderNote).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Result).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Coast).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Phase).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Command).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Parameter).length);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Press).length);
			offsets.push(offsets[offsets.length-1] + 1);
			offsets.push(offsets[offsets.length-1] + Type.getEnumConstructs(Province).length);
		}

		var off = offsets[Type.enumIndex(t)];
		var pars = Type.enumParameters(t);
		var ind = if(pars.length==0) 0 else Type.enumIndex(pars[0]);
		if(ind==-1) ind = 0;
		return off + ind;
	}
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
		ret.push(new ActionRule(58,aS(99)));
		ret.push(new ActionRule(59,aS(35)));
		ret.push(new ActionRule(60,aS(103)));
		ret.push(new ActionRule(61,aS(40),true,63));
		ret.push(new ActionRule(64,aS(46)));
		ret.push(new ActionRule(65,aS(48)));
		ret.push(new ActionRule(66,aS(130)));
		ret.push(new ActionRule(67,aS(54),true,70));
		ret.push(new ActionRule(71,aS(64)));
		ret.push(new ActionRule(72,aS(68),true,73));
		ret.push(new ActionRule(74,aS(155)));
		ret.push(new ActionRule(75,aS(70)));
		ret.push(new ActionRule(76,aS(165)));
		ret.push(new ActionRule(77,aS(71)));
		ret.push(new ActionRule(78,aS(73)));
		ret.push(new ActionRule(79,aS(77)));
		ret.push(new ActionRule(80,aS(174)));
		ret.push(new ActionRule(81,aS(268)));
		ret.push(new ActionRule(82,aS(78)));
		ret.push(new ActionRule(83,aS(178)));
		ret.push(new ActionRule(84,aS(182)));
		ret.push(new ActionRule(85,aS(84)));
		ret.push(new ActionRule(86,aS(87)));
		ret.push(new ActionRule(87,aS(91)));
		ret.push(new ActionRule(88,aS(556)));
		ret.push(new ActionRule(144,aG(1010)));
		ret.push(new ActionRule(146,aG(1),true,147));
		ret.push(new ActionRule(155,aG(98)));
		ret.push(new ActionRule(170,aG(193)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(2)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(3)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(14)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(151,aG(4)));
		ret.push(new ActionRule(174,aG(217)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(15)));
		ret.push(new ActionRule(4,aS(47)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(174,aG(216)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(52)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(716),true,4));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(150,aG(7)));
		ret.push(new ActionRule(174,aG(718)));
		ret.push(new ActionRule(175,aG(213)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(716)));
		ret.push(new ActionRule(4,aS(72)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(174,aG(718)));
		ret.push(new ActionRule(175,aG(212)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(85)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(105)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(118)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(125)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(146)));
		ret.push(new ActionRule(182,aG(816)));
		ret.push(new ActionRule(195,aG(349)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(211)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(14)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(151,aG(17)));
		ret.push(new ActionRule(174,aG(217)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(14)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(151,aG(18)));
		ret.push(new ActionRule(174,aG(217)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(14)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(151,aG(19)));
		ret.push(new ActionRule(174,aG(217)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(15)));
		ret.push(new ActionRule(4,aS(214)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(174,aG(216)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(15)));
		ret.push(new ActionRule(4,aS(215)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(174,aG(216)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(3,aS(15)));
		ret.push(new ActionRule(4,aS(488)));
		ret.push(new ActionRule(5,aS(580),true,87));
		ret.push(new ActionRule(89,aS(663),true,135));
		ret.push(new ActionRule(138,aS(710),true,142));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(715)));
		ret.push(new ActionRule(174,aG(216)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(237)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(296)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(313)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(412)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(572)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(578)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(828)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(829)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(830)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(834)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(835)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(32)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(33)));
		ret.push(new ActionRule(143,aS(34)));
		ret.push(new ActionRule(145,aG(974)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(1),87));
		ret.push(new ActionRule(89,aR(1),135));
		ret.push(new ActionRule(138,aR(1),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(0),87));
		ret.push(new ActionRule(89,aR(0),135));
		ret.push(new ActionRule(138,aR(0),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(26)));
		ret.push(new ActionRule(3,aS(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(37)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(38)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(39)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(27)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(24)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(19)));
		ret.push(new ActionRule(3,aS(115)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(43)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(44)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(45)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(3)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(18)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(49)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(50)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(51)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(5)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(53)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(6)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(7)));
		ret.push(new ActionRule(3,aS(134)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(8)));
		ret.push(new ActionRule(3,aS(137)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(23)));
		ret.push(new ActionRule(3,aS(12)));
		ret.push(new ActionRule(162,aG(148)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(58)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(59)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(61)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(62)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(63)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(4)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(65)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(58,aS(395)));
		ret.push(new ActionRule(59,aS(226)));
		ret.push(new ActionRule(61,aS(231)));
		ret.push(new ActionRule(82,aS(232)));
		ret.push(new ActionRule(85,aS(236)));
		ret.push(new ActionRule(153,aG(66)));
		ret.push(new ActionRule(167,aG(149)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(67)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(22)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(11)));
		ret.push(new ActionRule(3,aS(151)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(5)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(25)));
		ret.push(new ActionRule(3,aS(156)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(6)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(17)));
		ret.push(new ActionRule(2,aR(233),87));
		ret.push(new ActionRule(89,aR(233),135));
		ret.push(new ActionRule(138,aR(233),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(74)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(288)));
		ret.push(new ActionRule(61,aS(291)));
		ret.push(new ActionRule(62,aS(316),true,63));
		ret.push(new ActionRule(65,aS(292)));
		ret.push(new ActionRule(67,aS(194)));
		ret.push(new ActionRule(70,aS(298)));
		ret.push(new ActionRule(71,aS(305)));
		ret.push(new ActionRule(72,aS(320)));
		ret.push(new ActionRule(75,aS(321)));
		ret.push(new ActionRule(79,aS(322)));
		ret.push(new ActionRule(81,aS(268)));
		ret.push(new ActionRule(82,aS(218)));
		ret.push(new ActionRule(83,aS(198)));
		ret.push(new ActionRule(85,aS(312)));
		ret.push(new ActionRule(87,aS(323)));
		ret.push(new ActionRule(148,aG(75)));
		ret.push(new ActionRule(155,aG(315)));
		ret.push(new ActionRule(157,aG(169)));
		ret.push(new ActionRule(158,aG(171)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(76)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(10)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(12)));
		ret.push(new ActionRule(3,aS(354)));
		ret.push(new ActionRule(163,aG(173)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(79)));
		ret.push(new ActionRule(152,aG(83)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(80)));
		ret.push(new ActionRule(164,aG(220)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(81)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(219)));
		ret.push(new ActionRule(152,aG(82)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(21)));
		ret.push(new ActionRule(3,aS(223)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(20)));
		ret.push(new ActionRule(3,aS(223)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(15)));
		ret.push(new ActionRule(3,aS(8)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(86)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(14)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(88)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(288)));
		ret.push(new ActionRule(61,aS(291)));
		ret.push(new ActionRule(65,aS(292)));
		ret.push(new ActionRule(67,aS(194)));
		ret.push(new ActionRule(70,aS(298)));
		ret.push(new ActionRule(71,aS(283)));
		ret.push(new ActionRule(73,aS(287)));
		ret.push(new ActionRule(81,aS(268)));
		ret.push(new ActionRule(83,aS(198)));
		ret.push(new ActionRule(85,aS(311)));
		ret.push(new ActionRule(148,aG(89)));
		ret.push(new ActionRule(155,aG(315)));
		ret.push(new ActionRule(156,aG(189)));
		ret.push(new ActionRule(157,aG(191)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(90)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(9)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(92)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(93)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(94)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(95)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(96)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(97)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(16)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(28)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(100)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(101)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(102)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(49)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(104)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(9)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(106)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(107)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(108)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(109)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(110)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(111)));
		ret.push(new ActionRule(169,aG(113)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(112)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(56)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(114)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(57)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(116)));
		ret.push(new ActionRule(100,aS(123)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(117)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(10)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(119)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(120)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(342)));
		ret.push(new ActionRule(161,aG(121)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(345)));
		ret.push(new ActionRule(4,aS(122)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(35)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(124)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(11)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(126)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(127)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(342)));
		ret.push(new ActionRule(161,aG(128)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(345)));
		ret.push(new ActionRule(4,aS(129)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(131)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(132)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(133)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(44)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(135)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(136)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(138)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(139)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(140)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(330)));
		ret.push(new ActionRule(159,aG(141)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(142)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(143)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(336)));
		ret.push(new ActionRule(160,aG(144)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(4,aS(145)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(34)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(147)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(41)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(40)));
		ret.push(new ActionRule(3,aS(351)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(150)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(50)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(152)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(153)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(348)));
		ret.push(new ActionRule(162,aG(154)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(37)));
		ret.push(new ActionRule(3,aS(351)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(45)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(157)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(158)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(159)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(160)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(161)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(162)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(19,aS(772)));
		ret.push(new ActionRule(21,aS(773),true,41));
		ret.push(new ActionRule(43,aS(794)));
		ret.push(new ActionRule(165,aG(391)));
		ret.push(new ActionRule(166,aG(163)));
		ret.push(new ActionRule(177,aG(393)));
		ret.push(new ActionRule(184,aG(390)));
		ret.push(new ActionRule(185,aG(729)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(164)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(42)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(166)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(167)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(168)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(54)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(170)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(31)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(172)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(32)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(38)));
		ret.push(new ActionRule(3,aS(357)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(175)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(176)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(177)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(52)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(180)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(181)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(43)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(183)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(184)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(185)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(186)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(19,aS(772)));
		ret.push(new ActionRule(21,aS(773),true,37));
		ret.push(new ActionRule(165,aG(187)));
		ret.push(new ActionRule(184,aG(390)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(188)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(39)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(190)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(29)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(192)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(30)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(58)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(195)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(196)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(197)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(64)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(199)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(200)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(201)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(65)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(269)));
		ret.push(new ActionRule(154,aG(254)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(318)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(421)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(422)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(557)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(878)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(209)));
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(945)));
		ret.push(new ActionRule(180,aG(13)));
		ret.push(new ActionRule(202,aG(949)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(887)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(748),true,57));
		ret.push(new ActionRule(149,aG(889)));
		ret.push(new ActionRule(180,aG(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(252)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(235),87));
		ret.push(new ActionRule(89,aR(235),135));
		ret.push(new ActionRule(138,aR(235),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(234),87));
		ret.push(new ActionRule(89,aR(234),135));
		ret.push(new ActionRule(138,aR(234),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(91),87));
		ret.push(new ActionRule(89,aR(91),135));
		ret.push(new ActionRule(138,aR(91),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(93),87));
		ret.push(new ActionRule(89,aR(93),135));
		ret.push(new ActionRule(138,aR(93),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(92),87));
		ret.push(new ActionRule(89,aR(92),135));
		ret.push(new ActionRule(138,aR(92),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(90),87));
		ret.push(new ActionRule(89,aR(90),135));
		ret.push(new ActionRule(138,aR(90),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(219)));
		ret.push(new ActionRule(152,aG(222)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(220)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(221)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(274)));
		ret.push(new ActionRule(3,aR(274),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(223)));
		ret.push(new ActionRule(4,aR(86)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(224)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(225)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(275)));
		ret.push(new ActionRule(3,aR(275),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(227)));
		ret.push(new ActionRule(4,aR(323)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(229)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(230)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(324)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(322)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(233)));
		ret.push(new ActionRule(4,aR(321)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(234)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(235)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(320)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(20)));
		ret.push(new ActionRule(4,aR(325)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(238)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(80)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(253)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(255)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(256)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(257)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(258)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(259)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(260)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(261)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(262)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(263)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(264)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(265)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(252)));
		ret.push(new ActionRule(154,aG(266)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(262),5));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(271)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(277)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(290)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(414)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(576)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(734)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(886)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(921)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(926)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(928)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(934)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(937)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(959)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(981)));
		ret.push(new ActionRule(5,aS(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(263),5));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(202)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(270)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(239)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(272)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(273)));
		ret.push(new ActionRule(169,aG(275)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(274)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(466)));
		ret.push(new ActionRule(4,aR(466)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(276)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(467)));
		ret.push(new ActionRule(4,aR(467)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(278)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(279)));
		ret.push(new ActionRule(169,aG(281)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(280)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(464)));
		ret.push(new ActionRule(4,aR(464)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(282)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(465)));
		ret.push(new ActionRule(4,aR(465)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(284)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(574)));
		ret.push(new ActionRule(61,aS(307)));
		ret.push(new ActionRule(85,aS(285)));
		ret.push(new ActionRule(173,aG(309)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(25)));
		ret.push(new ActionRule(4,aS(286)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(67)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(66)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(289)));
		ret.push(new ActionRule(4,aR(73)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(240)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(75)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(71)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(293)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(294)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(295)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(21)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(297)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(69)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(299)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(300)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(301)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(302)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(303)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(304)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(68)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(306)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(574)));
		ret.push(new ActionRule(61,aS(307)));
		ret.push(new ActionRule(85,aS(577)));
		ret.push(new ActionRule(173,aG(309)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(308)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(70)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(310)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(74)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(22)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(22)));
		ret.push(new ActionRule(4,aR(88)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(314)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(72)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(76)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(82)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(203)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(319)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(85)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(83)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(87)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(84)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(324)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(325)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(326)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(327)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(328)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(329)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(89)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(809)));
		ret.push(new ActionRule(193,aG(331)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(810)));
		ret.push(new ActionRule(4,aS(332)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(333)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(334)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(335)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(315)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(799)));
		ret.push(new ActionRule(187,aG(337)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(338)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(302),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(799)));
		ret.push(new ActionRule(187,aG(340)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(341)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(303),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(89,aS(827)));
		ret.push(new ActionRule(90,aS(26)));
		ret.push(new ActionRule(92,aS(27)));
		ret.push(new ActionRule(94,aS(28)));
		ret.push(new ActionRule(95,aS(831),true,97));
		ret.push(new ActionRule(98,aS(29),true,99));
		ret.push(new ActionRule(101,aS(836)));
		ret.push(new ActionRule(197,aG(343)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(344)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(338),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(89,aS(827)));
		ret.push(new ActionRule(90,aS(26)));
		ret.push(new ActionRule(92,aS(27)));
		ret.push(new ActionRule(94,aS(28)));
		ret.push(new ActionRule(95,aS(831),true,97));
		ret.push(new ActionRule(98,aS(29),true,99));
		ret.push(new ActionRule(101,aS(836)));
		ret.push(new ActionRule(197,aG(346)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(347)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(339),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(816)));
		ret.push(new ActionRule(195,aG(349)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(350)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(336)));
		ret.push(new ActionRule(3,aR(336)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(816)));
		ret.push(new ActionRule(195,aG(352)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(353)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(337)));
		ret.push(new ActionRule(3,aR(337)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(730)));
		ret.push(new ActionRule(100,aS(732)));
		ret.push(new ActionRule(178,aG(355)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(356)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(250)));
		ret.push(new ActionRule(3,aR(250)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(730)));
		ret.push(new ActionRule(100,aS(732)));
		ret.push(new ActionRule(178,aG(358)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(359)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(251)));
		ret.push(new ActionRule(3,aR(251)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(361)));
		ret.push(new ActionRule(164,aG(961)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(362)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(363)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(8,aS(364)));
		ret.push(new ActionRule(9,aS(370)));
		ret.push(new ActionRule(10,aS(376),true,11));
		ret.push(new ActionRule(12,aS(379)));
		ret.push(new ActionRule(14,aS(385),true,15));
		ret.push(new ActionRule(16,aS(388),true,17));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(365)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(13,aS(366)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(367)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(368)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(369)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(273)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(371)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(372)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(373)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(8,aS(374)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(375)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(272)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(264)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(378)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(269)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(380)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(381)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(382)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(270)));
		ret.push(new ActionRule(11,aS(383)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(384)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(271)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(265)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(387)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(268)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(266)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(276)));
		ret.push(new ActionRule(44,aR(276)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(244)));
		ret.push(new ActionRule(44,aS(392)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(246)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(245)));
		ret.push(new ActionRule(44,aS(394)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(247)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(396)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(397)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(398)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(81)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(415)));
		ret.push(new ActionRule(169,aG(417)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(554)));
		ret.push(new ActionRule(169,aG(425)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(554)));
		ret.push(new ActionRule(169,aG(426)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(446)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(449)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(484)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(554)));
		ret.push(new ActionRule(169,aG(880)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(64,aS(487)));
		ret.push(new ActionRule(78,aS(489)));
		ret.push(new ActionRule(86,aS(494)));
		ret.push(new ActionRule(104,aS(499)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(430)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(112,aS(504)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(118,aS(525)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(122,aS(529)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(470)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(129,aS(535)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(555)));
		ret.push(new ActionRule(169,aG(923)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(420)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(490)));
		ret.push(new ActionRule(200,aG(492)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(420)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(495)));
		ret.push(new ActionRule(200,aG(497)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(410)));
		ret.push(new ActionRule(107,aS(419)));
		ret.push(new ActionRule(109,aS(429)));
		ret.push(new ActionRule(111,aS(435)));
		ret.push(new ActionRule(113,aS(441)));
		ret.push(new ActionRule(114,aS(451)));
		ret.push(new ActionRule(119,aS(455)));
		ret.push(new ActionRule(120,aS(461)));
		ret.push(new ActionRule(123,aS(465)));
		ret.push(new ActionRule(124,aS(469)));
		ret.push(new ActionRule(126,aS(475)));
		ret.push(new ActionRule(128,aS(479)));
		ret.push(new ActionRule(136,aS(483)));
		ret.push(new ActionRule(138,aS(486)));
		ret.push(new ActionRule(168,aG(500)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(411)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(23)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(413)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(241)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(399)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(416)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(436)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(418)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(437)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(204)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(205)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(423)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(424)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(400)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(401)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(427)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(428)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(433)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(391)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(432)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(431)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(910)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(120,aS(997)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(433)));
		ret.push(new ActionRule(209,aG(502)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(433)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(434)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(429)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(436)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(437)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(439)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(438)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(432)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(440)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(431)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(442)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(443)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(444)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(125,aS(445)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(402)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(447)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(434)));
		ret.push(new ActionRule(106,aS(448)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(403)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(450)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(435)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(452)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(453)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(454)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(425)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(456)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(930)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(954)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(457)));
		ret.push(new ActionRule(207,aG(459)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(458)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(421)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(460)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(424)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(462)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(463)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(464)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(426)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(466)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(467)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(468)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(427)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(472)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(471)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(910)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(120,aS(997)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(473)));
		ret.push(new ActionRule(209,aG(533)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(473)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(474)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(428)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(476)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(389)));
		ret.push(new ActionRule(59,aR(389),60));
		ret.push(new ActionRule(71,aR(389)));
		ret.push(new ActionRule(78,aR(389)));
		ret.push(new ActionRule(80,aR(389),81));
		ret.push(new ActionRule(86,aR(389)));
		ret.push(new ActionRule(102,aR(389),125));
		ret.push(new ActionRule(127,aR(389),132));
		ret.push(new ActionRule(136,aR(389),137));
		ret.push(new ActionRule(199,aG(477)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(478)));
		ret.push(new ActionRule(59,aS(837),true,60));
		ret.push(new ActionRule(71,aS(839)));
		ret.push(new ActionRule(78,aS(840)));
		ret.push(new ActionRule(80,aS(841),true,81));
		ret.push(new ActionRule(86,aS(843)));
		ret.push(new ActionRule(102,aS(844),true,125));
		ret.push(new ActionRule(127,aS(868),true,132));
		ret.push(new ActionRule(136,aS(874),true,137));
		ret.push(new ActionRule(198,aG(876)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(422)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(480)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(481)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(482)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(430)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(404)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(485)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(423)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(438)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(16)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(449)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(407)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(491)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(446)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(493)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(447)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(408)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(496)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(444)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(498)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(445)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(409)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(501)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(448)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(503)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(451)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(505)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(107,aS(877)));
		ret.push(new ActionRule(114,aS(506)));
		ret.push(new ActionRule(119,aS(511)));
		ret.push(new ActionRule(120,aS(992)));
		ret.push(new ActionRule(123,aS(516)));
		ret.push(new ActionRule(200,aG(521)));
		ret.push(new ActionRule(208,aG(523)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(507)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(508)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(509)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(510)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(461)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(512)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(513)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(514)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(515)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(460)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(517)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(518)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(519)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(520)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(462)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(522)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(459)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(524)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(458)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(526)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(129,aS(1000)));
		ret.push(new ActionRule(210,aG(527)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(528)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(453)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(530)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(107,aS(877)));
		ret.push(new ActionRule(200,aG(531)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(532)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(452)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(534)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(450)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(536)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(109,aS(1004)));
		ret.push(new ActionRule(114,aS(537)));
		ret.push(new ActionRule(119,aS(542)));
		ret.push(new ActionRule(123,aS(547)));
		ret.push(new ActionRule(124,aS(1007)));
		ret.push(new ActionRule(211,aG(552)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(538)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(539)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(540)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(541)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(457)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(543)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(544)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(545)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(546)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(456)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(548)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(549)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(550)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(551)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(455)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(553)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(454)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(463)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(922)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(206)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(558)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(562)));
		ret.push(new ActionRule(171,aG(559)));
		ret.push(new ActionRule(172,aG(561)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(59)));
		ret.push(new ActionRule(3,aS(562)));
		ret.push(new ActionRule(172,aG(560)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(63)));
		ret.push(new ActionRule(3,aR(63)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(62)));
		ret.push(new ActionRule(3,aR(62)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(563)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(564)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(565)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(566)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(567)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(568)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(569)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(570)));
		ret.push(new ActionRule(143,aS(24)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(571)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(61)));
		ret.push(new ActionRule(3,aR(61)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(573)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(60)));
		ret.push(new ActionRule(3,aR(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(575)));
		ret.push(new ActionRule(4,aR(78)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(242)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(79)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(25)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(579)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(77)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(96),87));
		ret.push(new ActionRule(89,aR(96),135));
		ret.push(new ActionRule(138,aR(96),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(97),87));
		ret.push(new ActionRule(89,aR(97),135));
		ret.push(new ActionRule(138,aR(97),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(98),87));
		ret.push(new ActionRule(89,aR(98),135));
		ret.push(new ActionRule(138,aR(98),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(99),87));
		ret.push(new ActionRule(89,aR(99),135));
		ret.push(new ActionRule(138,aR(99),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(100),87));
		ret.push(new ActionRule(89,aR(100),135));
		ret.push(new ActionRule(138,aR(100),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(101),87));
		ret.push(new ActionRule(89,aR(101),135));
		ret.push(new ActionRule(138,aR(101),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(102),87));
		ret.push(new ActionRule(89,aR(102),135));
		ret.push(new ActionRule(138,aR(102),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(103),87));
		ret.push(new ActionRule(89,aR(103),135));
		ret.push(new ActionRule(138,aR(103),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(104),87));
		ret.push(new ActionRule(89,aR(104),135));
		ret.push(new ActionRule(138,aR(104),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(105),87));
		ret.push(new ActionRule(89,aR(105),135));
		ret.push(new ActionRule(138,aR(105),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(106),87));
		ret.push(new ActionRule(89,aR(106),135));
		ret.push(new ActionRule(138,aR(106),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(107),87));
		ret.push(new ActionRule(89,aR(107),135));
		ret.push(new ActionRule(138,aR(107),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(108),87));
		ret.push(new ActionRule(89,aR(108),135));
		ret.push(new ActionRule(138,aR(108),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(109),87));
		ret.push(new ActionRule(89,aR(109),135));
		ret.push(new ActionRule(138,aR(109),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(110),87));
		ret.push(new ActionRule(89,aR(110),135));
		ret.push(new ActionRule(138,aR(110),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(111),87));
		ret.push(new ActionRule(89,aR(111),135));
		ret.push(new ActionRule(138,aR(111),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(112),87));
		ret.push(new ActionRule(89,aR(112),135));
		ret.push(new ActionRule(138,aR(112),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(113),87));
		ret.push(new ActionRule(89,aR(113),135));
		ret.push(new ActionRule(138,aR(113),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(114),87));
		ret.push(new ActionRule(89,aR(114),135));
		ret.push(new ActionRule(138,aR(114),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(115),87));
		ret.push(new ActionRule(89,aR(115),135));
		ret.push(new ActionRule(138,aR(115),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(116),87));
		ret.push(new ActionRule(89,aR(116),135));
		ret.push(new ActionRule(138,aR(116),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(117),87));
		ret.push(new ActionRule(89,aR(117),135));
		ret.push(new ActionRule(138,aR(117),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(118),87));
		ret.push(new ActionRule(89,aR(118),135));
		ret.push(new ActionRule(138,aR(118),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(119),87));
		ret.push(new ActionRule(89,aR(119),135));
		ret.push(new ActionRule(138,aR(119),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(120),87));
		ret.push(new ActionRule(89,aR(120),135));
		ret.push(new ActionRule(138,aR(120),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(121),87));
		ret.push(new ActionRule(89,aR(121),135));
		ret.push(new ActionRule(138,aR(121),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(122),87));
		ret.push(new ActionRule(89,aR(122),135));
		ret.push(new ActionRule(138,aR(122),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(123),87));
		ret.push(new ActionRule(89,aR(123),135));
		ret.push(new ActionRule(138,aR(123),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(124),87));
		ret.push(new ActionRule(89,aR(124),135));
		ret.push(new ActionRule(138,aR(124),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(125),87));
		ret.push(new ActionRule(89,aR(125),135));
		ret.push(new ActionRule(138,aR(125),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(126),87));
		ret.push(new ActionRule(89,aR(126),135));
		ret.push(new ActionRule(138,aR(126),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(127),87));
		ret.push(new ActionRule(89,aR(127),135));
		ret.push(new ActionRule(138,aR(127),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(128),87));
		ret.push(new ActionRule(89,aR(128),135));
		ret.push(new ActionRule(138,aR(128),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(129),87));
		ret.push(new ActionRule(89,aR(129),135));
		ret.push(new ActionRule(138,aR(129),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(130),87));
		ret.push(new ActionRule(89,aR(130),135));
		ret.push(new ActionRule(138,aR(130),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(131),87));
		ret.push(new ActionRule(89,aR(131),135));
		ret.push(new ActionRule(138,aR(131),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(132),87));
		ret.push(new ActionRule(89,aR(132),135));
		ret.push(new ActionRule(138,aR(132),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(133),87));
		ret.push(new ActionRule(89,aR(133),135));
		ret.push(new ActionRule(138,aR(133),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(134),87));
		ret.push(new ActionRule(89,aR(134),135));
		ret.push(new ActionRule(138,aR(134),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(135),87));
		ret.push(new ActionRule(89,aR(135),135));
		ret.push(new ActionRule(138,aR(135),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(136),87));
		ret.push(new ActionRule(89,aR(136),135));
		ret.push(new ActionRule(138,aR(136),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(137),87));
		ret.push(new ActionRule(89,aR(137),135));
		ret.push(new ActionRule(138,aR(137),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(138),87));
		ret.push(new ActionRule(89,aR(138),135));
		ret.push(new ActionRule(138,aR(138),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(139),87));
		ret.push(new ActionRule(89,aR(139),135));
		ret.push(new ActionRule(138,aR(139),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(140),87));
		ret.push(new ActionRule(89,aR(140),135));
		ret.push(new ActionRule(138,aR(140),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(141),87));
		ret.push(new ActionRule(89,aR(141),135));
		ret.push(new ActionRule(138,aR(141),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(142),87));
		ret.push(new ActionRule(89,aR(142),135));
		ret.push(new ActionRule(138,aR(142),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(143),87));
		ret.push(new ActionRule(89,aR(143),135));
		ret.push(new ActionRule(138,aR(143),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(144),87));
		ret.push(new ActionRule(89,aR(144),135));
		ret.push(new ActionRule(138,aR(144),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(145),87));
		ret.push(new ActionRule(89,aR(145),135));
		ret.push(new ActionRule(138,aR(145),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(146),87));
		ret.push(new ActionRule(89,aR(146),135));
		ret.push(new ActionRule(138,aR(146),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(147),87));
		ret.push(new ActionRule(89,aR(147),135));
		ret.push(new ActionRule(138,aR(147),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(148),87));
		ret.push(new ActionRule(89,aR(148),135));
		ret.push(new ActionRule(138,aR(148),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(149),87));
		ret.push(new ActionRule(89,aR(149),135));
		ret.push(new ActionRule(138,aR(149),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(150),87));
		ret.push(new ActionRule(89,aR(150),135));
		ret.push(new ActionRule(138,aR(150),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(151),87));
		ret.push(new ActionRule(89,aR(151),135));
		ret.push(new ActionRule(138,aR(151),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(152),87));
		ret.push(new ActionRule(89,aR(152),135));
		ret.push(new ActionRule(138,aR(152),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(153),87));
		ret.push(new ActionRule(89,aR(153),135));
		ret.push(new ActionRule(138,aR(153),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(154),87));
		ret.push(new ActionRule(89,aR(154),135));
		ret.push(new ActionRule(138,aR(154),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(155),87));
		ret.push(new ActionRule(89,aR(155),135));
		ret.push(new ActionRule(138,aR(155),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(156),87));
		ret.push(new ActionRule(89,aR(156),135));
		ret.push(new ActionRule(138,aR(156),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(157),87));
		ret.push(new ActionRule(89,aR(157),135));
		ret.push(new ActionRule(138,aR(157),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(158),87));
		ret.push(new ActionRule(89,aR(158),135));
		ret.push(new ActionRule(138,aR(158),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(159),87));
		ret.push(new ActionRule(89,aR(159),135));
		ret.push(new ActionRule(138,aR(159),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(160),87));
		ret.push(new ActionRule(89,aR(160),135));
		ret.push(new ActionRule(138,aR(160),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(161),87));
		ret.push(new ActionRule(89,aR(161),135));
		ret.push(new ActionRule(138,aR(161),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(162),87));
		ret.push(new ActionRule(89,aR(162),135));
		ret.push(new ActionRule(138,aR(162),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(163),87));
		ret.push(new ActionRule(89,aR(163),135));
		ret.push(new ActionRule(138,aR(163),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(164),87));
		ret.push(new ActionRule(89,aR(164),135));
		ret.push(new ActionRule(138,aR(164),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(165),87));
		ret.push(new ActionRule(89,aR(165),135));
		ret.push(new ActionRule(138,aR(165),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(166),87));
		ret.push(new ActionRule(89,aR(166),135));
		ret.push(new ActionRule(138,aR(166),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(167),87));
		ret.push(new ActionRule(89,aR(167),135));
		ret.push(new ActionRule(138,aR(167),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(168),87));
		ret.push(new ActionRule(89,aR(168),135));
		ret.push(new ActionRule(138,aR(168),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(169),87));
		ret.push(new ActionRule(89,aR(169),135));
		ret.push(new ActionRule(138,aR(169),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(170),87));
		ret.push(new ActionRule(89,aR(170),135));
		ret.push(new ActionRule(138,aR(170),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(171),87));
		ret.push(new ActionRule(89,aR(171),135));
		ret.push(new ActionRule(138,aR(171),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(172),87));
		ret.push(new ActionRule(89,aR(172),135));
		ret.push(new ActionRule(138,aR(172),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(173),87));
		ret.push(new ActionRule(89,aR(173),135));
		ret.push(new ActionRule(138,aR(173),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(174),87));
		ret.push(new ActionRule(89,aR(174),135));
		ret.push(new ActionRule(138,aR(174),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(175),87));
		ret.push(new ActionRule(89,aR(175),135));
		ret.push(new ActionRule(138,aR(175),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(176),87));
		ret.push(new ActionRule(89,aR(176),135));
		ret.push(new ActionRule(138,aR(176),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(177),87));
		ret.push(new ActionRule(89,aR(177),135));
		ret.push(new ActionRule(138,aR(177),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(178),87));
		ret.push(new ActionRule(89,aR(178),135));
		ret.push(new ActionRule(138,aR(178),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(179),87));
		ret.push(new ActionRule(89,aR(179),135));
		ret.push(new ActionRule(138,aR(179),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(180),87));
		ret.push(new ActionRule(89,aR(180),135));
		ret.push(new ActionRule(138,aR(180),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(181),87));
		ret.push(new ActionRule(89,aR(181),135));
		ret.push(new ActionRule(138,aR(181),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(182),87));
		ret.push(new ActionRule(89,aR(182),135));
		ret.push(new ActionRule(138,aR(182),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(183),87));
		ret.push(new ActionRule(89,aR(183),135));
		ret.push(new ActionRule(138,aR(183),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(184),87));
		ret.push(new ActionRule(89,aR(184),135));
		ret.push(new ActionRule(138,aR(184),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(185),87));
		ret.push(new ActionRule(89,aR(185),135));
		ret.push(new ActionRule(138,aR(185),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(186),87));
		ret.push(new ActionRule(89,aR(186),135));
		ret.push(new ActionRule(138,aR(186),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(187),87));
		ret.push(new ActionRule(89,aR(187),135));
		ret.push(new ActionRule(138,aR(187),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(188),87));
		ret.push(new ActionRule(89,aR(188),135));
		ret.push(new ActionRule(138,aR(188),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(189),87));
		ret.push(new ActionRule(89,aR(189),135));
		ret.push(new ActionRule(138,aR(189),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(190),87));
		ret.push(new ActionRule(89,aR(190),135));
		ret.push(new ActionRule(138,aR(190),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(191),87));
		ret.push(new ActionRule(89,aR(191),135));
		ret.push(new ActionRule(138,aR(191),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(192),87));
		ret.push(new ActionRule(89,aR(192),135));
		ret.push(new ActionRule(138,aR(192),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(193),87));
		ret.push(new ActionRule(89,aR(193),135));
		ret.push(new ActionRule(138,aR(193),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(194),87));
		ret.push(new ActionRule(89,aR(194),135));
		ret.push(new ActionRule(138,aR(194),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(195),87));
		ret.push(new ActionRule(89,aR(195),135));
		ret.push(new ActionRule(138,aR(195),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(196),87));
		ret.push(new ActionRule(89,aR(196),135));
		ret.push(new ActionRule(138,aR(196),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(197),87));
		ret.push(new ActionRule(89,aR(197),135));
		ret.push(new ActionRule(138,aR(197),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(198),87));
		ret.push(new ActionRule(89,aR(198),135));
		ret.push(new ActionRule(138,aR(198),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(199),87));
		ret.push(new ActionRule(89,aR(199),135));
		ret.push(new ActionRule(138,aR(199),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(200),87));
		ret.push(new ActionRule(89,aR(200),135));
		ret.push(new ActionRule(138,aR(200),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(201),87));
		ret.push(new ActionRule(89,aR(201),135));
		ret.push(new ActionRule(138,aR(201),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(202),87));
		ret.push(new ActionRule(89,aR(202),135));
		ret.push(new ActionRule(138,aR(202),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(203),87));
		ret.push(new ActionRule(89,aR(203),135));
		ret.push(new ActionRule(138,aR(203),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(204),87));
		ret.push(new ActionRule(89,aR(204),135));
		ret.push(new ActionRule(138,aR(204),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(205),87));
		ret.push(new ActionRule(89,aR(205),135));
		ret.push(new ActionRule(138,aR(205),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(206),87));
		ret.push(new ActionRule(89,aR(206),135));
		ret.push(new ActionRule(138,aR(206),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(207),87));
		ret.push(new ActionRule(89,aR(207),135));
		ret.push(new ActionRule(138,aR(207),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(208),87));
		ret.push(new ActionRule(89,aR(208),135));
		ret.push(new ActionRule(138,aR(208),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(209),87));
		ret.push(new ActionRule(89,aR(209),135));
		ret.push(new ActionRule(138,aR(209),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(210),87));
		ret.push(new ActionRule(89,aR(210),135));
		ret.push(new ActionRule(138,aR(210),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(211),87));
		ret.push(new ActionRule(89,aR(211),135));
		ret.push(new ActionRule(138,aR(211),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(212),87));
		ret.push(new ActionRule(89,aR(212),135));
		ret.push(new ActionRule(138,aR(212),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(213),87));
		ret.push(new ActionRule(89,aR(213),135));
		ret.push(new ActionRule(138,aR(213),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(214),87));
		ret.push(new ActionRule(89,aR(214),135));
		ret.push(new ActionRule(138,aR(214),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(215),87));
		ret.push(new ActionRule(89,aR(215),135));
		ret.push(new ActionRule(138,aR(215),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(216),87));
		ret.push(new ActionRule(89,aR(216),135));
		ret.push(new ActionRule(138,aR(216),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(217),87));
		ret.push(new ActionRule(89,aR(217),135));
		ret.push(new ActionRule(138,aR(217),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(218),87));
		ret.push(new ActionRule(89,aR(218),135));
		ret.push(new ActionRule(138,aR(218),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(219),87));
		ret.push(new ActionRule(89,aR(219),135));
		ret.push(new ActionRule(138,aR(219),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(220),87));
		ret.push(new ActionRule(89,aR(220),135));
		ret.push(new ActionRule(138,aR(220),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(221),87));
		ret.push(new ActionRule(89,aR(221),135));
		ret.push(new ActionRule(138,aR(221),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(222),87));
		ret.push(new ActionRule(89,aR(222),135));
		ret.push(new ActionRule(138,aR(222),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(223),87));
		ret.push(new ActionRule(89,aR(223),135));
		ret.push(new ActionRule(138,aR(223),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(224),87));
		ret.push(new ActionRule(89,aR(224),135));
		ret.push(new ActionRule(138,aR(224),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(225),87));
		ret.push(new ActionRule(89,aR(225),135));
		ret.push(new ActionRule(138,aR(225),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(226),87));
		ret.push(new ActionRule(89,aR(226),135));
		ret.push(new ActionRule(138,aR(226),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(227),87));
		ret.push(new ActionRule(89,aR(227),135));
		ret.push(new ActionRule(138,aR(227),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(228),87));
		ret.push(new ActionRule(89,aR(228),135));
		ret.push(new ActionRule(138,aR(228),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(229),87));
		ret.push(new ActionRule(89,aR(229),135));
		ret.push(new ActionRule(138,aR(229),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(230),87));
		ret.push(new ActionRule(89,aR(230),135));
		ret.push(new ActionRule(138,aR(230),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(95),87));
		ret.push(new ActionRule(89,aR(95),135));
		ret.push(new ActionRule(138,aR(95),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(232),87));
		ret.push(new ActionRule(89,aR(232),135));
		ret.push(new ActionRule(138,aR(232),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(233),87));
		ret.push(new ActionRule(89,aR(233),135));
		ret.push(new ActionRule(138,aR(233),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(231),87));
		ret.push(new ActionRule(89,aR(231),135));
		ret.push(new ActionRule(138,aR(231),143));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(45,aS(721),true,52));
		ret.push(new ActionRule(176,aG(806)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(45,aS(721),true,52));
		ret.push(new ActionRule(176,aG(815)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(236)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(237)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(238)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(239)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(240)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(241)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(242)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(295)));
		ret.push(new ActionRule(44,aR(295)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(731)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(248)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(733)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(249)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(740)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(741)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(742)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(743)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(744)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(179,aG(745)));
		ret.push(new ActionRule(181,aG(747)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(312)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(310)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(311)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(394)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(395)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(935)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(746)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(329)));
		ret.push(new ActionRule(139,aR(329),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(328)));
		ret.push(new ActionRule(139,aR(328),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(253)));
		ret.push(new ActionRule(143,aR(253)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(254)));
		ret.push(new ActionRule(143,aR(254)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(255)));
		ret.push(new ActionRule(143,aR(255)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(256)));
		ret.push(new ActionRule(143,aR(256)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(257)));
		ret.push(new ActionRule(143,aR(257)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(768)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(807)));
		ret.push(new ActionRule(191,aG(755)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(4,aR(307)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(808)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(807)));
		ret.push(new ActionRule(191,aG(757)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(4,aR(306)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(808)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(807)));
		ret.push(new ActionRule(191,aG(759)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(760)));
		ret.push(new ActionRule(4,aS(818)));
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(771)));
		ret.push(new ActionRule(183,aG(808)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(761),true,142));
		ret.push(new ActionRule(181,aG(720)));
		ret.push(new ActionRule(194,aG(769)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(258),4));
		ret.push(new ActionRule(13,aR(258)));
		ret.push(new ActionRule(45,aR(258),52));
		ret.push(new ActionRule(93,aR(258)));
		ret.push(new ActionRule(139,aR(258),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(259),4));
		ret.push(new ActionRule(13,aR(259)));
		ret.push(new ActionRule(45,aR(259),52));
		ret.push(new ActionRule(93,aR(259)));
		ret.push(new ActionRule(139,aR(259),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(260),4));
		ret.push(new ActionRule(13,aR(260)));
		ret.push(new ActionRule(45,aR(260),52));
		ret.push(new ActionRule(93,aR(260)));
		ret.push(new ActionRule(139,aR(260),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(261),4));
		ret.push(new ActionRule(13,aR(261)));
		ret.push(new ActionRule(45,aR(261),52));
		ret.push(new ActionRule(93,aR(261)));
		ret.push(new ActionRule(139,aR(261),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(821)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(767)));
		ret.push(new ActionRule(182,aG(825)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(6,aS(797),true,7));
		ret.push(new ActionRule(186,aG(753)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(301)));
		ret.push(new ActionRule(93,aR(301)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(770)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(317),4));
		ret.push(new ActionRule(93,aR(317)));
		ret.push(new ActionRule(139,aR(317),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(316),4));
		ret.push(new ActionRule(93,aR(316)));
		ret.push(new ActionRule(139,aR(316),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(277)));
		ret.push(new ActionRule(44,aR(277)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(291)));
		ret.push(new ActionRule(44,aR(291)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(288)));
		ret.push(new ActionRule(44,aR(288)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(278)));
		ret.push(new ActionRule(44,aR(278)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(289)));
		ret.push(new ActionRule(44,aR(289)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(281)));
		ret.push(new ActionRule(44,aR(281)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(292)));
		ret.push(new ActionRule(44,aR(292)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(293)));
		ret.push(new ActionRule(44,aR(293)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(285)));
		ret.push(new ActionRule(44,aR(285)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(294)));
		ret.push(new ActionRule(44,aR(294)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(283)));
		ret.push(new ActionRule(44,aR(283)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(290)));
		ret.push(new ActionRule(44,aR(290)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(282)));
		ret.push(new ActionRule(44,aR(282)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(279)));
		ret.push(new ActionRule(44,aR(279)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(280)));
		ret.push(new ActionRule(44,aR(280)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(286)));
		ret.push(new ActionRule(44,aR(286)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(284)));
		ret.push(new ActionRule(44,aR(284)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(287)));
		ret.push(new ActionRule(44,aR(287)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(296)));
		ret.push(new ActionRule(44,aR(296)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(297)));
		ret.push(new ActionRule(44,aR(297)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(298)));
		ret.push(new ActionRule(44,aR(298)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(299)));
		ret.push(new ActionRule(44,aR(299)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(300)));
		ret.push(new ActionRule(44,aR(300)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(805)));
		ret.push(new ActionRule(6,aS(797),true,7));
		ret.push(new ActionRule(186,aG(756)));
		ret.push(new ActionRule(190,aG(801)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(805)));
		ret.push(new ActionRule(6,aS(797),true,7));
		ret.push(new ActionRule(186,aG(756)));
		ret.push(new ActionRule(190,aG(803)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(330)));
		ret.push(new ActionRule(139,aR(330),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(331)));
		ret.push(new ActionRule(139,aR(331),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(795)));
		ret.push(new ActionRule(188,aG(800)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(796)));
		ret.push(new ActionRule(4,aR(304)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(802)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(308),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(804)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(309),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(7,aS(719)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(754)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(318),4));
		ret.push(new ActionRule(139,aR(318),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(319),4));
		ret.push(new ActionRule(139,aR(319),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(243)));
		ret.push(new ActionRule(5,aS(735)));
		ret.push(new ActionRule(100,aS(736)));
		ret.push(new ActionRule(192,aG(811)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(243)));
		ret.push(new ActionRule(5,aS(735)));
		ret.push(new ActionRule(100,aS(736)));
		ret.push(new ActionRule(192,aG(813)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(812)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(313),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(814)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(314),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(327)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(332)));
		ret.push(new ActionRule(93,aS(817)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(758)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(333)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(765)));
		ret.push(new ActionRule(196,aG(823)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(765)));
		ret.push(new ActionRule(196,aG(824)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(822)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(334),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(766)));
		ret.push(new ActionRule(4,aR(407)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(766)));
		ret.push(new ActionRule(4,aR(414)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(826)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(335),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(344)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(343)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(340)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(341)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(349)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(348)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(346)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(347)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(342)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(345)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(354)));
		ret.push(new ActionRule(59,aR(354),60));
		ret.push(new ActionRule(71,aR(354)));
		ret.push(new ActionRule(78,aR(354)));
		ret.push(new ActionRule(80,aR(354),81));
		ret.push(new ActionRule(86,aR(354)));
		ret.push(new ActionRule(102,aR(354),125));
		ret.push(new ActionRule(127,aR(354),132));
		ret.push(new ActionRule(136,aR(354),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(384)));
		ret.push(new ActionRule(59,aR(384),60));
		ret.push(new ActionRule(71,aR(384)));
		ret.push(new ActionRule(78,aR(384)));
		ret.push(new ActionRule(80,aR(384),81));
		ret.push(new ActionRule(86,aR(384)));
		ret.push(new ActionRule(102,aR(384),125));
		ret.push(new ActionRule(127,aR(384),132));
		ret.push(new ActionRule(136,aR(384),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(356)));
		ret.push(new ActionRule(59,aR(356),60));
		ret.push(new ActionRule(71,aR(356)));
		ret.push(new ActionRule(78,aR(356)));
		ret.push(new ActionRule(80,aR(356),81));
		ret.push(new ActionRule(86,aR(356)));
		ret.push(new ActionRule(102,aR(356),125));
		ret.push(new ActionRule(127,aR(356),132));
		ret.push(new ActionRule(136,aR(356),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(359)));
		ret.push(new ActionRule(59,aR(359),60));
		ret.push(new ActionRule(71,aR(359)));
		ret.push(new ActionRule(78,aR(359)));
		ret.push(new ActionRule(80,aR(359),81));
		ret.push(new ActionRule(86,aR(359)));
		ret.push(new ActionRule(102,aR(359),125));
		ret.push(new ActionRule(127,aR(359),132));
		ret.push(new ActionRule(136,aR(359),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(355)));
		ret.push(new ActionRule(59,aR(355),60));
		ret.push(new ActionRule(71,aR(355)));
		ret.push(new ActionRule(78,aR(355)));
		ret.push(new ActionRule(80,aR(355),81));
		ret.push(new ActionRule(86,aR(355)));
		ret.push(new ActionRule(102,aR(355),125));
		ret.push(new ActionRule(127,aR(355),132));
		ret.push(new ActionRule(136,aR(355),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(386)));
		ret.push(new ActionRule(59,aR(386),60));
		ret.push(new ActionRule(71,aR(386)));
		ret.push(new ActionRule(78,aR(386)));
		ret.push(new ActionRule(80,aR(386),81));
		ret.push(new ActionRule(86,aR(386)));
		ret.push(new ActionRule(102,aR(386),125));
		ret.push(new ActionRule(127,aR(386),132));
		ret.push(new ActionRule(136,aR(386),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(358)));
		ret.push(new ActionRule(59,aR(358),60));
		ret.push(new ActionRule(71,aR(358)));
		ret.push(new ActionRule(78,aR(358)));
		ret.push(new ActionRule(80,aR(358),81));
		ret.push(new ActionRule(86,aR(358)));
		ret.push(new ActionRule(102,aR(358),125));
		ret.push(new ActionRule(127,aR(358),132));
		ret.push(new ActionRule(136,aR(358),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(352)));
		ret.push(new ActionRule(59,aR(352),60));
		ret.push(new ActionRule(71,aR(352)));
		ret.push(new ActionRule(78,aR(352)));
		ret.push(new ActionRule(80,aR(352),81));
		ret.push(new ActionRule(86,aR(352)));
		ret.push(new ActionRule(102,aR(352),125));
		ret.push(new ActionRule(127,aR(352),132));
		ret.push(new ActionRule(136,aR(352),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(364)));
		ret.push(new ActionRule(59,aR(364),60));
		ret.push(new ActionRule(71,aR(364)));
		ret.push(new ActionRule(78,aR(364)));
		ret.push(new ActionRule(80,aR(364),81));
		ret.push(new ActionRule(86,aR(364)));
		ret.push(new ActionRule(102,aR(364),125));
		ret.push(new ActionRule(127,aR(364),132));
		ret.push(new ActionRule(136,aR(364),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(360)));
		ret.push(new ActionRule(59,aR(360),60));
		ret.push(new ActionRule(71,aR(360)));
		ret.push(new ActionRule(78,aR(360)));
		ret.push(new ActionRule(80,aR(360),81));
		ret.push(new ActionRule(86,aR(360)));
		ret.push(new ActionRule(102,aR(360),125));
		ret.push(new ActionRule(127,aR(360),132));
		ret.push(new ActionRule(136,aR(360),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(363)));
		ret.push(new ActionRule(59,aR(363),60));
		ret.push(new ActionRule(71,aR(363)));
		ret.push(new ActionRule(78,aR(363)));
		ret.push(new ActionRule(80,aR(363),81));
		ret.push(new ActionRule(86,aR(363)));
		ret.push(new ActionRule(102,aR(363),125));
		ret.push(new ActionRule(127,aR(363),132));
		ret.push(new ActionRule(136,aR(363),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(381)));
		ret.push(new ActionRule(59,aR(381),60));
		ret.push(new ActionRule(71,aR(381)));
		ret.push(new ActionRule(78,aR(381)));
		ret.push(new ActionRule(80,aR(381),81));
		ret.push(new ActionRule(86,aR(381)));
		ret.push(new ActionRule(102,aR(381),125));
		ret.push(new ActionRule(127,aR(381),132));
		ret.push(new ActionRule(136,aR(381),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(376)));
		ret.push(new ActionRule(59,aR(376),60));
		ret.push(new ActionRule(71,aR(376)));
		ret.push(new ActionRule(78,aR(376)));
		ret.push(new ActionRule(80,aR(376),81));
		ret.push(new ActionRule(86,aR(376)));
		ret.push(new ActionRule(102,aR(376),125));
		ret.push(new ActionRule(127,aR(376),132));
		ret.push(new ActionRule(136,aR(376),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(385)));
		ret.push(new ActionRule(59,aR(385),60));
		ret.push(new ActionRule(71,aR(385)));
		ret.push(new ActionRule(78,aR(385)));
		ret.push(new ActionRule(80,aR(385),81));
		ret.push(new ActionRule(86,aR(385)));
		ret.push(new ActionRule(102,aR(385),125));
		ret.push(new ActionRule(127,aR(385),132));
		ret.push(new ActionRule(136,aR(385),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(371)));
		ret.push(new ActionRule(59,aR(371),60));
		ret.push(new ActionRule(71,aR(371)));
		ret.push(new ActionRule(78,aR(371)));
		ret.push(new ActionRule(80,aR(371),81));
		ret.push(new ActionRule(86,aR(371)));
		ret.push(new ActionRule(102,aR(371),125));
		ret.push(new ActionRule(127,aR(371),132));
		ret.push(new ActionRule(136,aR(371),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(378)));
		ret.push(new ActionRule(59,aR(378),60));
		ret.push(new ActionRule(71,aR(378)));
		ret.push(new ActionRule(78,aR(378)));
		ret.push(new ActionRule(80,aR(378),81));
		ret.push(new ActionRule(86,aR(378)));
		ret.push(new ActionRule(102,aR(378),125));
		ret.push(new ActionRule(127,aR(378),132));
		ret.push(new ActionRule(136,aR(378),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(375)));
		ret.push(new ActionRule(59,aR(375),60));
		ret.push(new ActionRule(71,aR(375)));
		ret.push(new ActionRule(78,aR(375)));
		ret.push(new ActionRule(80,aR(375),81));
		ret.push(new ActionRule(86,aR(375)));
		ret.push(new ActionRule(102,aR(375),125));
		ret.push(new ActionRule(127,aR(375),132));
		ret.push(new ActionRule(136,aR(375),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(372)));
		ret.push(new ActionRule(59,aR(372),60));
		ret.push(new ActionRule(71,aR(372)));
		ret.push(new ActionRule(78,aR(372)));
		ret.push(new ActionRule(80,aR(372),81));
		ret.push(new ActionRule(86,aR(372)));
		ret.push(new ActionRule(102,aR(372),125));
		ret.push(new ActionRule(127,aR(372),132));
		ret.push(new ActionRule(136,aR(372),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(379)));
		ret.push(new ActionRule(59,aR(379),60));
		ret.push(new ActionRule(71,aR(379)));
		ret.push(new ActionRule(78,aR(379)));
		ret.push(new ActionRule(80,aR(379),81));
		ret.push(new ActionRule(86,aR(379)));
		ret.push(new ActionRule(102,aR(379),125));
		ret.push(new ActionRule(127,aR(379),132));
		ret.push(new ActionRule(136,aR(379),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(368)));
		ret.push(new ActionRule(59,aR(368),60));
		ret.push(new ActionRule(71,aR(368)));
		ret.push(new ActionRule(78,aR(368)));
		ret.push(new ActionRule(80,aR(368),81));
		ret.push(new ActionRule(86,aR(368)));
		ret.push(new ActionRule(102,aR(368),125));
		ret.push(new ActionRule(127,aR(368),132));
		ret.push(new ActionRule(136,aR(368),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(367)));
		ret.push(new ActionRule(59,aR(367),60));
		ret.push(new ActionRule(71,aR(367)));
		ret.push(new ActionRule(78,aR(367)));
		ret.push(new ActionRule(80,aR(367),81));
		ret.push(new ActionRule(86,aR(367)));
		ret.push(new ActionRule(102,aR(367),125));
		ret.push(new ActionRule(127,aR(367),132));
		ret.push(new ActionRule(136,aR(367),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(365)));
		ret.push(new ActionRule(59,aR(365),60));
		ret.push(new ActionRule(71,aR(365)));
		ret.push(new ActionRule(78,aR(365)));
		ret.push(new ActionRule(80,aR(365),81));
		ret.push(new ActionRule(86,aR(365)));
		ret.push(new ActionRule(102,aR(365),125));
		ret.push(new ActionRule(127,aR(365),132));
		ret.push(new ActionRule(136,aR(365),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(351)));
		ret.push(new ActionRule(59,aR(351),60));
		ret.push(new ActionRule(71,aR(351)));
		ret.push(new ActionRule(78,aR(351)));
		ret.push(new ActionRule(80,aR(351),81));
		ret.push(new ActionRule(86,aR(351)));
		ret.push(new ActionRule(102,aR(351),125));
		ret.push(new ActionRule(127,aR(351),132));
		ret.push(new ActionRule(136,aR(351),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(388)));
		ret.push(new ActionRule(59,aR(388),60));
		ret.push(new ActionRule(71,aR(388)));
		ret.push(new ActionRule(78,aR(388)));
		ret.push(new ActionRule(80,aR(388),81));
		ret.push(new ActionRule(86,aR(388)));
		ret.push(new ActionRule(102,aR(388),125));
		ret.push(new ActionRule(127,aR(388),132));
		ret.push(new ActionRule(136,aR(388),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(350)));
		ret.push(new ActionRule(59,aR(350),60));
		ret.push(new ActionRule(71,aR(350)));
		ret.push(new ActionRule(78,aR(350)));
		ret.push(new ActionRule(80,aR(350),81));
		ret.push(new ActionRule(86,aR(350)));
		ret.push(new ActionRule(102,aR(350),125));
		ret.push(new ActionRule(127,aR(350),132));
		ret.push(new ActionRule(136,aR(350),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(369)));
		ret.push(new ActionRule(59,aR(369),60));
		ret.push(new ActionRule(71,aR(369)));
		ret.push(new ActionRule(78,aR(369)));
		ret.push(new ActionRule(80,aR(369),81));
		ret.push(new ActionRule(86,aR(369)));
		ret.push(new ActionRule(102,aR(369),125));
		ret.push(new ActionRule(127,aR(369),132));
		ret.push(new ActionRule(136,aR(369),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(366)));
		ret.push(new ActionRule(59,aR(366),60));
		ret.push(new ActionRule(71,aR(366)));
		ret.push(new ActionRule(78,aR(366)));
		ret.push(new ActionRule(80,aR(366),81));
		ret.push(new ActionRule(86,aR(366)));
		ret.push(new ActionRule(102,aR(366),125));
		ret.push(new ActionRule(127,aR(366),132));
		ret.push(new ActionRule(136,aR(366),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(377)));
		ret.push(new ActionRule(59,aR(377),60));
		ret.push(new ActionRule(71,aR(377)));
		ret.push(new ActionRule(78,aR(377)));
		ret.push(new ActionRule(80,aR(377),81));
		ret.push(new ActionRule(86,aR(377)));
		ret.push(new ActionRule(102,aR(377),125));
		ret.push(new ActionRule(127,aR(377),132));
		ret.push(new ActionRule(136,aR(377),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(373)));
		ret.push(new ActionRule(59,aR(373),60));
		ret.push(new ActionRule(71,aR(373)));
		ret.push(new ActionRule(78,aR(373)));
		ret.push(new ActionRule(80,aR(373),81));
		ret.push(new ActionRule(86,aR(373)));
		ret.push(new ActionRule(102,aR(373),125));
		ret.push(new ActionRule(127,aR(373),132));
		ret.push(new ActionRule(136,aR(373),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(370)));
		ret.push(new ActionRule(59,aR(370),60));
		ret.push(new ActionRule(71,aR(370)));
		ret.push(new ActionRule(78,aR(370)));
		ret.push(new ActionRule(80,aR(370),81));
		ret.push(new ActionRule(86,aR(370)));
		ret.push(new ActionRule(102,aR(370),125));
		ret.push(new ActionRule(127,aR(370),132));
		ret.push(new ActionRule(136,aR(370),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(380)));
		ret.push(new ActionRule(59,aR(380),60));
		ret.push(new ActionRule(71,aR(380)));
		ret.push(new ActionRule(78,aR(380)));
		ret.push(new ActionRule(80,aR(380),81));
		ret.push(new ActionRule(86,aR(380)));
		ret.push(new ActionRule(102,aR(380),125));
		ret.push(new ActionRule(127,aR(380),132));
		ret.push(new ActionRule(136,aR(380),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(353)));
		ret.push(new ActionRule(59,aR(353),60));
		ret.push(new ActionRule(71,aR(353)));
		ret.push(new ActionRule(78,aR(353)));
		ret.push(new ActionRule(80,aR(353),81));
		ret.push(new ActionRule(86,aR(353)));
		ret.push(new ActionRule(102,aR(353),125));
		ret.push(new ActionRule(127,aR(353),132));
		ret.push(new ActionRule(136,aR(353),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(374)));
		ret.push(new ActionRule(59,aR(374),60));
		ret.push(new ActionRule(71,aR(374)));
		ret.push(new ActionRule(78,aR(374)));
		ret.push(new ActionRule(80,aR(374),81));
		ret.push(new ActionRule(86,aR(374)));
		ret.push(new ActionRule(102,aR(374),125));
		ret.push(new ActionRule(127,aR(374),132));
		ret.push(new ActionRule(136,aR(374),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(387)));
		ret.push(new ActionRule(59,aR(387),60));
		ret.push(new ActionRule(71,aR(387)));
		ret.push(new ActionRule(78,aR(387)));
		ret.push(new ActionRule(80,aR(387),81));
		ret.push(new ActionRule(86,aR(387)));
		ret.push(new ActionRule(102,aR(387),125));
		ret.push(new ActionRule(127,aR(387),132));
		ret.push(new ActionRule(136,aR(387),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(362)));
		ret.push(new ActionRule(59,aR(362),60));
		ret.push(new ActionRule(71,aR(362)));
		ret.push(new ActionRule(78,aR(362)));
		ret.push(new ActionRule(80,aR(362),81));
		ret.push(new ActionRule(86,aR(362)));
		ret.push(new ActionRule(102,aR(362),125));
		ret.push(new ActionRule(127,aR(362),132));
		ret.push(new ActionRule(136,aR(362),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(382)));
		ret.push(new ActionRule(59,aR(382),60));
		ret.push(new ActionRule(71,aR(382)));
		ret.push(new ActionRule(78,aR(382)));
		ret.push(new ActionRule(80,aR(382),81));
		ret.push(new ActionRule(86,aR(382)));
		ret.push(new ActionRule(102,aR(382),125));
		ret.push(new ActionRule(127,aR(382),132));
		ret.push(new ActionRule(136,aR(382),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(383)));
		ret.push(new ActionRule(59,aR(383),60));
		ret.push(new ActionRule(71,aR(383)));
		ret.push(new ActionRule(78,aR(383)));
		ret.push(new ActionRule(80,aR(383),81));
		ret.push(new ActionRule(86,aR(383)));
		ret.push(new ActionRule(102,aR(383),125));
		ret.push(new ActionRule(127,aR(383),132));
		ret.push(new ActionRule(136,aR(383),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(361)));
		ret.push(new ActionRule(59,aR(361),60));
		ret.push(new ActionRule(71,aR(361)));
		ret.push(new ActionRule(78,aR(361)));
		ret.push(new ActionRule(80,aR(361),81));
		ret.push(new ActionRule(86,aR(361)));
		ret.push(new ActionRule(102,aR(361),125));
		ret.push(new ActionRule(127,aR(361),132));
		ret.push(new ActionRule(136,aR(361),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(357)));
		ret.push(new ActionRule(59,aR(357),60));
		ret.push(new ActionRule(71,aR(357)));
		ret.push(new ActionRule(78,aR(357)));
		ret.push(new ActionRule(80,aR(357),81));
		ret.push(new ActionRule(86,aR(357)));
		ret.push(new ActionRule(102,aR(357),125));
		ret.push(new ActionRule(127,aR(357),132));
		ret.push(new ActionRule(136,aR(357),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(390)));
		ret.push(new ActionRule(59,aR(390),60));
		ret.push(new ActionRule(71,aR(390)));
		ret.push(new ActionRule(78,aR(390)));
		ret.push(new ActionRule(80,aR(390),81));
		ret.push(new ActionRule(86,aR(390)));
		ret.push(new ActionRule(102,aR(390),125));
		ret.push(new ActionRule(127,aR(390),132));
		ret.push(new ActionRule(136,aR(390),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(207)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(879)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(405)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(881)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(391)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(117,aS(884)));
		ret.push(new ActionRule(201,aG(947)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(117,aS(884)));
		ret.push(new ActionRule(201,aG(951)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(885)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(244)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(392)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(888)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(210)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(890)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(393)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(737)));
		ret.push(new ActionRule(100,aS(738)));
		ret.push(new ActionRule(203,aG(894)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(737)));
		ret.push(new ActionRule(100,aS(738)));
		ret.push(new ActionRule(203,aG(897)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(891)));
		ret.push(new ActionRule(204,aG(896)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(895)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(396),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(892)));
		ret.push(new ActionRule(4,aR(406)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(898)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(397),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(911)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(120,aS(992)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(911)));
		ret.push(new ActionRule(208,aG(995)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(986)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(988)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(990)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(993)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(998)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(1005)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(908)));
		ret.push(new ActionRule(71,aS(909)));
		ret.push(new ActionRule(80,aS(913)));
		ret.push(new ActionRule(81,aS(917)));
		ret.push(new ActionRule(102,aS(925)));
		ret.push(new ActionRule(103,aS(929)));
		ret.push(new ActionRule(105,aS(933)));
		ret.push(new ActionRule(108,aS(936)));
		ret.push(new ActionRule(110,aS(944)));
		ret.push(new ActionRule(115,aS(819)));
		ret.push(new ActionRule(116,aS(953)));
		ret.push(new ActionRule(117,aS(957)));
		ret.push(new ActionRule(121,aS(893)));
		ret.push(new ActionRule(130,aS(960)));
		ret.push(new ActionRule(131,aS(963)));
		ret.push(new ActionRule(132,aS(970)));
		ret.push(new ActionRule(133,aS(973)));
		ret.push(new ActionRule(134,aS(977)));
		ret.push(new ActionRule(137,aS(985)));
		ret.push(new ActionRule(205,aG(1008)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(400)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(899)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(900)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(912)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(402)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(914)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(915)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(916)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(401)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(918)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(919)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(920)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(245)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(406)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(415)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(924)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(416)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(246)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(127,aS(927)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(247)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(399)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(902)));
		ret.push(new ActionRule(206,aG(931)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(902)));
		ret.push(new ActionRule(206,aG(932)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(903)));
		ret.push(new ActionRule(4,aR(408)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(903)));
		ret.push(new ActionRule(4,aR(408)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(248)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(739)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(405)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(249)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(938)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(939)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(940)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(941)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(942)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(943)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(417)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(208)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(946)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(882)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(948)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(411)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(950)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(883)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(952)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(412)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(902)));
		ret.push(new ActionRule(206,aG(955)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(902)));
		ret.push(new ActionRule(206,aG(956)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(903)));
		ret.push(new ActionRule(4,aR(409)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(903)));
		ret.push(new ActionRule(4,aR(409)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(958)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(250)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(398)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(360)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(962)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(404)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(964)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(965)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(966)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(967)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(968)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(969)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(413)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(971)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(972)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(820)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(31)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(975)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(902)));
		ret.push(new ActionRule(206,aG(976)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(903)));
		ret.push(new ActionRule(4,aR(410)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(978)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(979)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(980)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(251)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(982)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(983)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(984)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(418)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(901)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(987)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(403)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(989)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(419),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(991)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(420),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(904)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(994)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(439)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(996)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(441)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(905)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(999)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(440)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(1001)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(109,aS(1004)));
		ret.push(new ActionRule(124,aS(1007)));
		ret.push(new ActionRule(211,aG(1002)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(1003)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(470)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(906)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(1006)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(469)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(907)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(1009)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(468)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aA));
		actions.push(ret);

		rules = new Array<{cb:Array<Dynamic>->Void,sym:Int,cnt:Int}>();
		rules.push({cb:R0, sym:145, cnt:1});
		rules.push({cb:R1, sym:145, cnt:1});
		rules.push({cb:R2, sym:144, cnt:1});
		rules.push({cb:R3, sym:144, cnt:1});
		rules.push({cb:R4, sym:146, cnt:7});
		rules.push({cb:R5, sym:146, cnt:1});
		rules.push({cb:R6, sym:146, cnt:7});
		rules.push({cb:R7, sym:146, cnt:1});
		rules.push({cb:R8, sym:146, cnt:1});
		rules.push({cb:R9, sym:146, cnt:4});
		rules.push({cb:R10, sym:146, cnt:4});
		rules.push({cb:R11, sym:146, cnt:1});
		rules.push({cb:R12, sym:146, cnt:1});
		rules.push({cb:R13, sym:146, cnt:4});
		rules.push({cb:R14, sym:146, cnt:4});
		rules.push({cb:R15, sym:146, cnt:1});
		rules.push({cb:R16, sym:146, cnt:7});
		rules.push({cb:R17, sym:146, cnt:4});
		rules.push({cb:R18, sym:146, cnt:4});
		rules.push({cb:R19, sym:146, cnt:1});
		rules.push({cb:R20, sym:146, cnt:2});
		rules.push({cb:R21, sym:146, cnt:5});
		rules.push({cb:R22, sym:146, cnt:4});
		rules.push({cb:R23, sym:146, cnt:1});
		rules.push({cb:R24, sym:146, cnt:1});
		rules.push({cb:R25, sym:146, cnt:1});
		rules.push({cb:R26, sym:146, cnt:1});
		rules.push({cb:R27, sym:146, cnt:5});
		rules.push({cb:R28, sym:146, cnt:1});
		rules.push({cb:R29, sym:147, cnt:4});
		rules.push({cb:R30, sym:147, cnt:4});
		rules.push({cb:R31, sym:147, cnt:4});
		rules.push({cb:R32, sym:147, cnt:4});
		rules.push({cb:R33, sym:147, cnt:4});
		rules.push({cb:R34, sym:147, cnt:10});
		rules.push({cb:R35, sym:147, cnt:10});
		rules.push({cb:R36, sym:147, cnt:10});
		rules.push({cb:R37, sym:147, cnt:5});
		rules.push({cb:R38, sym:147, cnt:2});
		rules.push({cb:R39, sym:147, cnt:7});
		rules.push({cb:R40, sym:147, cnt:2});
		rules.push({cb:R41, sym:147, cnt:4});
		rules.push({cb:R42, sym:147, cnt:10});
		rules.push({cb:R43, sym:147, cnt:4});
		rules.push({cb:R44, sym:147, cnt:4});
		rules.push({cb:R45, sym:147, cnt:1});
		rules.push({cb:R46, sym:147, cnt:4});
		rules.push({cb:R47, sym:147, cnt:4});
		rules.push({cb:R48, sym:147, cnt:4});
		rules.push({cb:R49, sym:147, cnt:4});
		rules.push({cb:R50, sym:147, cnt:4});
		rules.push({cb:R51, sym:147, cnt:7});
		rules.push({cb:R52, sym:147, cnt:4});
		rules.push({cb:R53, sym:147, cnt:1});
		rules.push({cb:R54, sym:147, cnt:4});
		rules.push({cb:R55, sym:147, cnt:5});
		rules.push({cb:R56, sym:147, cnt:11});
		rules.push({cb:R57, sym:147, cnt:11});
		rules.push({cb:R58, sym:147, cnt:1});
		rules.push({cb:R59, sym:170, cnt:5});
		rules.push({cb:R60, sym:172, cnt:11});
		rules.push({cb:R61, sym:172, cnt:10});
		rules.push({cb:R62, sym:171, cnt:1});
		rules.push({cb:R63, sym:171, cnt:2});
		rules.push({cb:R64, sym:148, cnt:4});
		rules.push({cb:R65, sym:148, cnt:4});
		rules.push({cb:R66, sym:156, cnt:1});
		rules.push({cb:R67, sym:156, cnt:4});
		rules.push({cb:R68, sym:157, cnt:7});
		rules.push({cb:R69, sym:157, cnt:7});
		rules.push({cb:R70, sym:157, cnt:4});
		rules.push({cb:R71, sym:157, cnt:1});
		rules.push({cb:R72, sym:157, cnt:4});
		rules.push({cb:R73, sym:157, cnt:1});
		rules.push({cb:R74, sym:157, cnt:4});
		rules.push({cb:R75, sym:157, cnt:5});
		rules.push({cb:R76, sym:157, cnt:1});
		rules.push({cb:R77, sym:173, cnt:4});
		rules.push({cb:R78, sym:173, cnt:1});
		rules.push({cb:R79, sym:173, cnt:5});
		rules.push({cb:R80, sym:167, cnt:4});
		rules.push({cb:R81, sym:167, cnt:4});
		rules.push({cb:R82, sym:158, cnt:1});
		rules.push({cb:R83, sym:158, cnt:1});
		rules.push({cb:R84, sym:158, cnt:1});
		rules.push({cb:R85, sym:158, cnt:4});
		rules.push({cb:R86, sym:158, cnt:2});
		rules.push({cb:R87, sym:158, cnt:1});
		rules.push({cb:R88, sym:158, cnt:1});
		rules.push({cb:R89, sym:158, cnt:7});
		rules.push({cb:R90, sym:151, cnt:1});
		rules.push({cb:R91, sym:151, cnt:3});
		rules.push({cb:R92, sym:151, cnt:2});
		rules.push({cb:R93, sym:151, cnt:4});
		rules.push({cb:R94, sym:174, cnt:1});
		rules.push({cb:R95, sym:174, cnt:1});
		rules.push({cb:R96, sym:174, cnt:1});
		rules.push({cb:R97, sym:174, cnt:1});
		rules.push({cb:R98, sym:174, cnt:1});
		rules.push({cb:R99, sym:174, cnt:1});
		rules.push({cb:R100, sym:174, cnt:1});
		rules.push({cb:R101, sym:174, cnt:1});
		rules.push({cb:R102, sym:174, cnt:1});
		rules.push({cb:R103, sym:174, cnt:1});
		rules.push({cb:R104, sym:174, cnt:1});
		rules.push({cb:R105, sym:174, cnt:1});
		rules.push({cb:R106, sym:174, cnt:1});
		rules.push({cb:R107, sym:174, cnt:1});
		rules.push({cb:R108, sym:174, cnt:1});
		rules.push({cb:R109, sym:174, cnt:1});
		rules.push({cb:R110, sym:174, cnt:1});
		rules.push({cb:R111, sym:174, cnt:1});
		rules.push({cb:R112, sym:174, cnt:1});
		rules.push({cb:R113, sym:174, cnt:1});
		rules.push({cb:R114, sym:174, cnt:1});
		rules.push({cb:R115, sym:174, cnt:1});
		rules.push({cb:R116, sym:174, cnt:1});
		rules.push({cb:R117, sym:174, cnt:1});
		rules.push({cb:R118, sym:174, cnt:1});
		rules.push({cb:R119, sym:174, cnt:1});
		rules.push({cb:R120, sym:174, cnt:1});
		rules.push({cb:R121, sym:174, cnt:1});
		rules.push({cb:R122, sym:174, cnt:1});
		rules.push({cb:R123, sym:174, cnt:1});
		rules.push({cb:R124, sym:174, cnt:1});
		rules.push({cb:R125, sym:174, cnt:1});
		rules.push({cb:R126, sym:174, cnt:1});
		rules.push({cb:R127, sym:174, cnt:1});
		rules.push({cb:R128, sym:174, cnt:1});
		rules.push({cb:R129, sym:174, cnt:1});
		rules.push({cb:R130, sym:174, cnt:1});
		rules.push({cb:R131, sym:174, cnt:1});
		rules.push({cb:R132, sym:174, cnt:1});
		rules.push({cb:R133, sym:174, cnt:1});
		rules.push({cb:R134, sym:174, cnt:1});
		rules.push({cb:R135, sym:174, cnt:1});
		rules.push({cb:R136, sym:174, cnt:1});
		rules.push({cb:R137, sym:174, cnt:1});
		rules.push({cb:R138, sym:174, cnt:1});
		rules.push({cb:R139, sym:174, cnt:1});
		rules.push({cb:R140, sym:174, cnt:1});
		rules.push({cb:R141, sym:174, cnt:1});
		rules.push({cb:R142, sym:174, cnt:1});
		rules.push({cb:R143, sym:174, cnt:1});
		rules.push({cb:R144, sym:174, cnt:1});
		rules.push({cb:R145, sym:174, cnt:1});
		rules.push({cb:R146, sym:174, cnt:1});
		rules.push({cb:R147, sym:174, cnt:1});
		rules.push({cb:R148, sym:174, cnt:1});
		rules.push({cb:R149, sym:174, cnt:1});
		rules.push({cb:R150, sym:174, cnt:1});
		rules.push({cb:R151, sym:174, cnt:1});
		rules.push({cb:R152, sym:174, cnt:1});
		rules.push({cb:R153, sym:174, cnt:1});
		rules.push({cb:R154, sym:174, cnt:1});
		rules.push({cb:R155, sym:174, cnt:1});
		rules.push({cb:R156, sym:174, cnt:1});
		rules.push({cb:R157, sym:174, cnt:1});
		rules.push({cb:R158, sym:174, cnt:1});
		rules.push({cb:R159, sym:174, cnt:1});
		rules.push({cb:R160, sym:174, cnt:1});
		rules.push({cb:R161, sym:174, cnt:1});
		rules.push({cb:R162, sym:174, cnt:1});
		rules.push({cb:R163, sym:174, cnt:1});
		rules.push({cb:R164, sym:174, cnt:1});
		rules.push({cb:R165, sym:174, cnt:1});
		rules.push({cb:R166, sym:174, cnt:1});
		rules.push({cb:R167, sym:174, cnt:1});
		rules.push({cb:R168, sym:174, cnt:1});
		rules.push({cb:R169, sym:174, cnt:1});
		rules.push({cb:R170, sym:174, cnt:1});
		rules.push({cb:R171, sym:174, cnt:1});
		rules.push({cb:R172, sym:174, cnt:1});
		rules.push({cb:R173, sym:174, cnt:1});
		rules.push({cb:R174, sym:174, cnt:1});
		rules.push({cb:R175, sym:174, cnt:1});
		rules.push({cb:R176, sym:174, cnt:1});
		rules.push({cb:R177, sym:174, cnt:1});
		rules.push({cb:R178, sym:174, cnt:1});
		rules.push({cb:R179, sym:174, cnt:1});
		rules.push({cb:R180, sym:174, cnt:1});
		rules.push({cb:R181, sym:174, cnt:1});
		rules.push({cb:R182, sym:174, cnt:1});
		rules.push({cb:R183, sym:174, cnt:1});
		rules.push({cb:R184, sym:174, cnt:1});
		rules.push({cb:R185, sym:174, cnt:1});
		rules.push({cb:R186, sym:174, cnt:1});
		rules.push({cb:R187, sym:174, cnt:1});
		rules.push({cb:R188, sym:174, cnt:1});
		rules.push({cb:R189, sym:174, cnt:1});
		rules.push({cb:R190, sym:174, cnt:1});
		rules.push({cb:R191, sym:174, cnt:1});
		rules.push({cb:R192, sym:174, cnt:1});
		rules.push({cb:R193, sym:174, cnt:1});
		rules.push({cb:R194, sym:174, cnt:1});
		rules.push({cb:R195, sym:174, cnt:1});
		rules.push({cb:R196, sym:174, cnt:1});
		rules.push({cb:R197, sym:174, cnt:1});
		rules.push({cb:R198, sym:174, cnt:1});
		rules.push({cb:R199, sym:174, cnt:1});
		rules.push({cb:R200, sym:174, cnt:1});
		rules.push({cb:R201, sym:174, cnt:1});
		rules.push({cb:R202, sym:174, cnt:1});
		rules.push({cb:R203, sym:174, cnt:1});
		rules.push({cb:R204, sym:174, cnt:1});
		rules.push({cb:R205, sym:174, cnt:1});
		rules.push({cb:R206, sym:174, cnt:1});
		rules.push({cb:R207, sym:174, cnt:1});
		rules.push({cb:R208, sym:174, cnt:1});
		rules.push({cb:R209, sym:174, cnt:1});
		rules.push({cb:R210, sym:174, cnt:1});
		rules.push({cb:R211, sym:174, cnt:1});
		rules.push({cb:R212, sym:174, cnt:1});
		rules.push({cb:R213, sym:174, cnt:1});
		rules.push({cb:R214, sym:174, cnt:1});
		rules.push({cb:R215, sym:174, cnt:1});
		rules.push({cb:R216, sym:174, cnt:1});
		rules.push({cb:R217, sym:174, cnt:1});
		rules.push({cb:R218, sym:174, cnt:1});
		rules.push({cb:R219, sym:174, cnt:1});
		rules.push({cb:R220, sym:174, cnt:1});
		rules.push({cb:R221, sym:174, cnt:1});
		rules.push({cb:R222, sym:174, cnt:1});
		rules.push({cb:R223, sym:174, cnt:1});
		rules.push({cb:R224, sym:174, cnt:1});
		rules.push({cb:R225, sym:174, cnt:1});
		rules.push({cb:R226, sym:174, cnt:1});
		rules.push({cb:R227, sym:174, cnt:1});
		rules.push({cb:R228, sym:174, cnt:1});
		rules.push({cb:R229, sym:174, cnt:1});
		rules.push({cb:R230, sym:174, cnt:1});
		rules.push({cb:R231, sym:175, cnt:1});
		rules.push({cb:R232, sym:175, cnt:1});
		rules.push({cb:R233, sym:175, cnt:1});
		rules.push({cb:R234, sym:150, cnt:1});
		rules.push({cb:R235, sym:150, cnt:2});
		rules.push({cb:R236, sym:176, cnt:1});
		rules.push({cb:R237, sym:176, cnt:1});
		rules.push({cb:R238, sym:176, cnt:1});
		rules.push({cb:R239, sym:176, cnt:1});
		rules.push({cb:R240, sym:176, cnt:1});
		rules.push({cb:R241, sym:176, cnt:1});
		rules.push({cb:R242, sym:176, cnt:1});
		rules.push({cb:R243, sym:176, cnt:1});
		rules.push({cb:R244, sym:166, cnt:1});
		rules.push({cb:R245, sym:166, cnt:1});
		rules.push({cb:R246, sym:166, cnt:2});
		rules.push({cb:R247, sym:166, cnt:2});
		rules.push({cb:R248, sym:178, cnt:2});
		rules.push({cb:R249, sym:178, cnt:2});
		rules.push({cb:R250, sym:163, cnt:3});
		rules.push({cb:R251, sym:163, cnt:4});
		rules.push({cb:R252, sym:149, cnt:2});
		rules.push({cb:R253, sym:180, cnt:1});
		rules.push({cb:R254, sym:180, cnt:1});
		rules.push({cb:R255, sym:180, cnt:1});
		rules.push({cb:R256, sym:180, cnt:1});
		rules.push({cb:R257, sym:180, cnt:1});
		rules.push({cb:R258, sym:181, cnt:1});
		rules.push({cb:R259, sym:181, cnt:1});
		rules.push({cb:R260, sym:181, cnt:1});
		rules.push({cb:R261, sym:181, cnt:1});
		rules.push({cb:R262, sym:154, cnt:1});
		rules.push({cb:R263, sym:154, cnt:2});
		rules.push({cb:R264, sym:164, cnt:4});
		rules.push({cb:R265, sym:164, cnt:4});
		rules.push({cb:R266, sym:164, cnt:4});
		rules.push({cb:R267, sym:164, cnt:4});
		rules.push({cb:R268, sym:164, cnt:5});
		rules.push({cb:R269, sym:164, cnt:5});
		rules.push({cb:R270, sym:164, cnt:7});
		rules.push({cb:R271, sym:164, cnt:9});
		rules.push({cb:R272, sym:164, cnt:9});
		rules.push({cb:R273, sym:164, cnt:9});
		rules.push({cb:R274, sym:152, cnt:3});
		rules.push({cb:R275, sym:152, cnt:4});
		rules.push({cb:R276, sym:165, cnt:1});
		rules.push({cb:R277, sym:184, cnt:1});
		rules.push({cb:R278, sym:184, cnt:1});
		rules.push({cb:R279, sym:184, cnt:1});
		rules.push({cb:R280, sym:184, cnt:1});
		rules.push({cb:R281, sym:184, cnt:1});
		rules.push({cb:R282, sym:184, cnt:1});
		rules.push({cb:R283, sym:184, cnt:1});
		rules.push({cb:R284, sym:184, cnt:1});
		rules.push({cb:R285, sym:184, cnt:1});
		rules.push({cb:R286, sym:184, cnt:1});
		rules.push({cb:R287, sym:184, cnt:1});
		rules.push({cb:R288, sym:184, cnt:1});
		rules.push({cb:R289, sym:184, cnt:1});
		rules.push({cb:R290, sym:184, cnt:1});
		rules.push({cb:R291, sym:184, cnt:1});
		rules.push({cb:R292, sym:184, cnt:1});
		rules.push({cb:R293, sym:184, cnt:1});
		rules.push({cb:R294, sym:184, cnt:1});
		rules.push({cb:R295, sym:177, cnt:1});
		rules.push({cb:R296, sym:185, cnt:1});
		rules.push({cb:R297, sym:185, cnt:1});
		rules.push({cb:R298, sym:185, cnt:1});
		rules.push({cb:R299, sym:185, cnt:1});
		rules.push({cb:R300, sym:185, cnt:1});
		rules.push({cb:R301, sym:182, cnt:3});
		rules.push({cb:R302, sym:160, cnt:3});
		rules.push({cb:R303, sym:160, cnt:4});
		rules.push({cb:R304, sym:187, cnt:2});
		rules.push({cb:R305, sym:189, cnt:2});
		rules.push({cb:R306, sym:190, cnt:2});
		rules.push({cb:R307, sym:190, cnt:5});
		rules.push({cb:R308, sym:188, cnt:3});
		rules.push({cb:R309, sym:188, cnt:4});
		rules.push({cb:R310, sym:192, cnt:2});
		rules.push({cb:R311, sym:192, cnt:2});
		rules.push({cb:R312, sym:192, cnt:4});
		rules.push({cb:R313, sym:193, cnt:3});
		rules.push({cb:R314, sym:193, cnt:4});
		rules.push({cb:R315, sym:159, cnt:6});
		rules.push({cb:R316, sym:183, cnt:1});
		rules.push({cb:R317, sym:183, cnt:3});
		rules.push({cb:R318, sym:191, cnt:1});
		rules.push({cb:R319, sym:191, cnt:2});
		rules.push({cb:R320, sym:153, cnt:4});
		rules.push({cb:R321, sym:153, cnt:1});
		rules.push({cb:R322, sym:153, cnt:1});
		rules.push({cb:R323, sym:153, cnt:1});
		rules.push({cb:R324, sym:153, cnt:5});
		rules.push({cb:R325, sym:153, cnt:1});
		rules.push({cb:R326, sym:153, cnt:4});
		rules.push({cb:R327, sym:194, cnt:2});
		rules.push({cb:R328, sym:179, cnt:1});
		rules.push({cb:R329, sym:179, cnt:2});
		rules.push({cb:R330, sym:186, cnt:1});
		rules.push({cb:R331, sym:186, cnt:1});
		rules.push({cb:R332, sym:195, cnt:1});
		rules.push({cb:R333, sym:195, cnt:5});
		rules.push({cb:R334, sym:196, cnt:3});
		rules.push({cb:R335, sym:196, cnt:4});
		rules.push({cb:R336, sym:162, cnt:3});
		rules.push({cb:R337, sym:162, cnt:4});
		rules.push({cb:R338, sym:161, cnt:3});
		rules.push({cb:R339, sym:161, cnt:4});
		rules.push({cb:R340, sym:197, cnt:2});
		rules.push({cb:R341, sym:197, cnt:2});
		rules.push({cb:R342, sym:197, cnt:2});
		rules.push({cb:R343, sym:197, cnt:2});
		rules.push({cb:R344, sym:197, cnt:1});
		rules.push({cb:R345, sym:197, cnt:1});
		rules.push({cb:R346, sym:197, cnt:1});
		rules.push({cb:R347, sym:197, cnt:2});
		rules.push({cb:R348, sym:197, cnt:1});
		rules.push({cb:R349, sym:197, cnt:1});
		rules.push({cb:R350, sym:198, cnt:1});
		rules.push({cb:R351, sym:198, cnt:1});
		rules.push({cb:R352, sym:198, cnt:1});
		rules.push({cb:R353, sym:198, cnt:1});
		rules.push({cb:R354, sym:198, cnt:1});
		rules.push({cb:R355, sym:198, cnt:1});
		rules.push({cb:R356, sym:198, cnt:1});
		rules.push({cb:R357, sym:198, cnt:1});
		rules.push({cb:R358, sym:198, cnt:1});
		rules.push({cb:R359, sym:198, cnt:1});
		rules.push({cb:R360, sym:198, cnt:1});
		rules.push({cb:R361, sym:198, cnt:1});
		rules.push({cb:R362, sym:198, cnt:1});
		rules.push({cb:R363, sym:198, cnt:1});
		rules.push({cb:R364, sym:198, cnt:1});
		rules.push({cb:R365, sym:198, cnt:1});
		rules.push({cb:R366, sym:198, cnt:1});
		rules.push({cb:R367, sym:198, cnt:1});
		rules.push({cb:R368, sym:198, cnt:1});
		rules.push({cb:R369, sym:198, cnt:1});
		rules.push({cb:R370, sym:198, cnt:1});
		rules.push({cb:R371, sym:198, cnt:1});
		rules.push({cb:R372, sym:198, cnt:1});
		rules.push({cb:R373, sym:198, cnt:1});
		rules.push({cb:R374, sym:198, cnt:1});
		rules.push({cb:R375, sym:198, cnt:1});
		rules.push({cb:R376, sym:198, cnt:1});
		rules.push({cb:R377, sym:198, cnt:1});
		rules.push({cb:R378, sym:198, cnt:1});
		rules.push({cb:R379, sym:198, cnt:1});
		rules.push({cb:R380, sym:198, cnt:1});
		rules.push({cb:R381, sym:198, cnt:1});
		rules.push({cb:R382, sym:198, cnt:1});
		rules.push({cb:R383, sym:198, cnt:1});
		rules.push({cb:R384, sym:198, cnt:1});
		rules.push({cb:R385, sym:198, cnt:1});
		rules.push({cb:R386, sym:198, cnt:1});
		rules.push({cb:R387, sym:198, cnt:1});
		rules.push({cb:R388, sym:198, cnt:1});
		rules.push({cb:R389, sym:199, cnt:0});
		rules.push({cb:R390, sym:199, cnt:2});
		rules.push({cb:R391, sym:200, cnt:7});
		rules.push({cb:R392, sym:201, cnt:5});
		rules.push({cb:R393, sym:202, cnt:6});
		rules.push({cb:R394, sym:203, cnt:2});
		rules.push({cb:R395, sym:203, cnt:2});
		rules.push({cb:R396, sym:204, cnt:3});
		rules.push({cb:R397, sym:204, cnt:4});
		rules.push({cb:R398, sym:205, cnt:5});
		rules.push({cb:R399, sym:205, cnt:8});
		rules.push({cb:R400, sym:205, cnt:1});
		rules.push({cb:R401, sym:205, cnt:4});
		rules.push({cb:R402, sym:205, cnt:4});
		rules.push({cb:R403, sym:205, cnt:4});
		rules.push({cb:R404, sym:205, cnt:4});
		rules.push({cb:R405, sym:205, cnt:7});
		rules.push({cb:R406, sym:205, cnt:2});
		rules.push({cb:R407, sym:205, cnt:2});
		rules.push({cb:R408, sym:205, cnt:2});
		rules.push({cb:R409, sym:205, cnt:2});
		rules.push({cb:R410, sym:205, cnt:6});
		rules.push({cb:R411, sym:205, cnt:7});
		rules.push({cb:R412, sym:205, cnt:7});
		rules.push({cb:R413, sym:205, cnt:7});
		rules.push({cb:R414, sym:205, cnt:5});
		rules.push({cb:R415, sym:205, cnt:10});
		rules.push({cb:R416, sym:205, cnt:10});
		rules.push({cb:R417, sym:205, cnt:10});
		rules.push({cb:R418, sym:205, cnt:10});
		rules.push({cb:R419, sym:206, cnt:3});
		rules.push({cb:R420, sym:206, cnt:4});
		rules.push({cb:R421, sym:168, cnt:4});
		rules.push({cb:R422, sym:168, cnt:4});
		rules.push({cb:R423, sym:168, cnt:4});
		rules.push({cb:R424, sym:168, cnt:4});
		rules.push({cb:R425, sym:168, cnt:4});
		rules.push({cb:R426, sym:168, cnt:4});
		rules.push({cb:R427, sym:168, cnt:4});
		rules.push({cb:R428, sym:168, cnt:4});
		rules.push({cb:R429, sym:168, cnt:4});
		rules.push({cb:R430, sym:168, cnt:4});
		rules.push({cb:R431, sym:168, cnt:4});
		rules.push({cb:R432, sym:168, cnt:4});
		rules.push({cb:R433, sym:168, cnt:7});
		rules.push({cb:R434, sym:168, cnt:8});
		rules.push({cb:R435, sym:168, cnt:12});
		rules.push({cb:R436, sym:168, cnt:11});
		rules.push({cb:R437, sym:168, cnt:11});
		rules.push({cb:R438, sym:168, cnt:1});
		rules.push({cb:R439, sym:208, cnt:4});
		rules.push({cb:R440, sym:209, cnt:4});
		rules.push({cb:R441, sym:209, cnt:4});
		rules.push({cb:R442, sym:207, cnt:2});
		rules.push({cb:R443, sym:207, cnt:2});
		rules.push({cb:R444, sym:169, cnt:4});
		rules.push({cb:R445, sym:169, cnt:4});
		rules.push({cb:R446, sym:169, cnt:4});
		rules.push({cb:R447, sym:169, cnt:4});
		rules.push({cb:R448, sym:169, cnt:4});
		rules.push({cb:R449, sym:169, cnt:4});
		rules.push({cb:R450, sym:169, cnt:4});
		rules.push({cb:R451, sym:169, cnt:4});
		rules.push({cb:R452, sym:169, cnt:4});
		rules.push({cb:R453, sym:169, cnt:4});
		rules.push({cb:R454, sym:169, cnt:4});
		rules.push({cb:R455, sym:169, cnt:7});
		rules.push({cb:R456, sym:169, cnt:7});
		rules.push({cb:R457, sym:169, cnt:7});
		rules.push({cb:R458, sym:169, cnt:4});
		rules.push({cb:R459, sym:169, cnt:4});
		rules.push({cb:R460, sym:169, cnt:7});
		rules.push({cb:R461, sym:169, cnt:7});
		rules.push({cb:R462, sym:169, cnt:7});
		rules.push({cb:R463, sym:169, cnt:1});
		rules.push({cb:R464, sym:155, cnt:7});
		rules.push({cb:R465, sym:155, cnt:7});
		rules.push({cb:R466, sym:155, cnt:10});
		rules.push({cb:R467, sym:155, cnt:10});
		rules.push({cb:R468, sym:211, cnt:4});
		rules.push({cb:R469, sym:211, cnt:4});
		rules.push({cb:R470, sym:210, cnt:4});
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

	public static function parse(input:Array<Token>): Message  {
		init();

		errors = new Array<String>();
		var entry_state = 0;
var stack = new Array<Int>();
var ret = new Array<Dynamic>();
input.push(null);
var cur = input.shift();
var cstate = entry_state;
while(true){
	var action = getaction(cstate,cur==null ? 0 : TU.index(cur)+2);
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
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Int  = ({ 0; });
		ret.push(retret);
	}
	private static inline function R1(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Int  = ({ TU.nonzero(hllr__0); });
		ret.push(retret);
	}
	private static inline function R2(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R3(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R4(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mName(TU.text(hllr__2),TU.text(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R5(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mObserver; });
		ret.push(retret);
	}
	private static inline function R6(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: Int  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mIAm(TU.power(hllr__2),(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R7(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(null); });
		ret.push(retret);
	}
	private static inline function R8(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMapDefinition(null,null,null); });
		ret.push(retret);
	}
	private static inline function R9(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R10(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R11(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(null,null); });
		ret.push(retret);
	}
	private static inline function R12(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(null); });
		ret.push(retret);
	}
	private static inline function R13(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHistory(hllr__2); });
		ret.push(retret);
	}
	private static inline function R14(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R15(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R16(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAdmin(TU.text(hllr__2),TU.text(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R17(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mBadBrackets(hllr__2); });
		ret.push(retret);
	}
	private static inline function R18(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHuh(hllr__2); });
		ret.push(retret);
	}
	private static inline function R19(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(null,null,null); });
		ret.push(retret);
	}
	private static inline function R20(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MsgOrder>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R21(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<MsgOrder>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(hllr__2,hllr__4); });
		ret.push(retret);
	}
	private static inline function R22(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R23(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders(null,null); });
		ret.push(retret);
	}
	private static inline function R24(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R25(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mOrderResult(null,null,null); });
		ret.push(retret);
	}
	private static inline function R26(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R27(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R28(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R29(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R30(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R31(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R32(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R33(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R34(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: Array<MdfProAdjacencies>  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: MdfProvinces  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMapDefinition(hllr__2,hllr__5,hllr__8); });
		ret.push(retret);
	}
	private static inline function R35(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: Variant  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Int  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(TU.power(hllr__2),(hllr__5),hllr__8); });
		ret.push(retret);
	}
	private static inline function R36(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: Variant  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Int  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(null,(hllr__5),hllr__8); });
		ret.push(retret);
	}
	private static inline function R37(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<UnitWithLocAndMRT>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(hllr__2,hllr__4); });
		ret.push(retret);
	}
	private static inline function R38(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<ScoEntry>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(hllr__1); });
		ret.push(retret);
	}
	private static inline function R39(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: OrderNote  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mThink(hllr__2,hllr__5); });
		ret.push(retret);
	}
	private static inline function R40(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<UnitWithLocAndMRT>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R41(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders((hllr__2),null); });
		ret.push(retret);
	}
	private static inline function R42(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: CompOrderResult  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: MsgOrder  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mOrderResult(hllr__2,hllr__5,hllr__8); });
		ret.push(retret);
	}
	private static inline function R43(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSaveGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R44(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mLoadGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R45(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTurnOff; });
		ret.push(retret);
	}
	private static inline function R46(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R47(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mBadBrackets(hllr__2); });
		ret.push(retret);
	}
	private static inline function R48(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHuh(hllr__2); });
		ret.push(retret);
	}
	private static inline function R49(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerDisorder(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R50(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R51(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAdmin(TU.text(hllr__2),TU.text(hllr__5));  });
		ret.push(retret);
	}
	private static inline function R52(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSolo(TU.power(hllr__2));  });
		ret.push(retret);
	}
	private static inline function R53(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R54(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerEliminated(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R55(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R56(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: PressMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3: Int  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mFrom(TU.power(hllr__2),(hllr__3),hllr__6,hllr__9,null); });
		ret.push(retret);
	}
	private static inline function R57(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: ReplyMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3: Int  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mFrom(TU.power(hllr__2),(hllr__3),hllr__6,null,hllr__9); });
		ret.push(retret);
	}
	private static inline function R58(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R59(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<Summary>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSummary(hllr__2,hllr__4); });
		ret.push(retret);
	}
	private static inline function R60(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: Int  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Summary  = ({
		{ power : TU.power(hllr__1), name : TU.text(hllr__3), version : TU.text(hllr__6), centres : 0, year : hllr__9 };
	});
		ret.push(retret);
	}
	private static inline function R61(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Summary  = ({
		{ power : TU.power(hllr__1), name : TU.text(hllr__3), version : TU.text(hllr__6), centres : TU.nonzero(hllr__8), year : -1 };
	});
		ret.push(retret);
	}
	private static inline function R62(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Summary  = ret.pop();
		var retret: Array<Summary>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R63(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Summary  = ret.pop();
var hllr__0: Array<Summary>  = ret.pop();
		var retret: Array<Summary>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R64(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R65(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSaveGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R66(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mObserver; });
		ret.push(retret);
	}
	private static inline function R67(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(mTimeToDeadline(null)); });
		ret.push(retret);
	}
	private static inline function R68(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mName(TU.text(hllr__2),TU.text(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R69(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: Int  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mIAm(TU.power(hllr__2),(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R70(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(mGoFlag); });
		ret.push(retret);
	}
	private static inline function R71(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R72(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R73(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R74(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R75(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R76(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R77(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R78(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R79(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R80(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R81(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerDisorder(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R82(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(null,null,null); });
		ret.push(retret);
	}
	private static inline function R83(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(null,null); });
		ret.push(retret);
	}
	private static inline function R84(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(null); });
		ret.push(retret);
	}
	private static inline function R85(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHistory(hllr__2); });
		ret.push(retret);
	}
	private static inline function R86(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MsgOrder>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R87(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mOrderResult(null,null,null); });
		ret.push(retret);
	}
	private static inline function R88(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R89(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAdmin(TU.text(hllr__2),TU.text(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R90(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Array<Token>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R91(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Array<Token>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<Token>  = ({ hllr__1.unshift(hllr__0); hllr__1.push(hllr__2); hllr__1; });
		ret.push(retret);
	}
	private static inline function R92(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R93(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0 = hllr__0.concat(hllr__2); hllr__0.push(hllr__3); hllr__0; });
		ret.push(retret);
	}
	private static inline function R94(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R95(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R96(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R97(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R98(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R99(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R100(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R101(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R102(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R103(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R104(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R105(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R106(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R107(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R108(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R109(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R110(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R111(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R112(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R113(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R114(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R115(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R116(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R117(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R118(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R119(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R120(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R121(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R122(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R123(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R124(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R125(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R126(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R127(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R128(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R129(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R130(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R131(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R132(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R133(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R134(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R135(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R136(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R137(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R138(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R139(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R140(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R141(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R142(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R143(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R144(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R145(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R146(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R147(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R148(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R149(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R150(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R151(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R152(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R153(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R154(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R155(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R156(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R157(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R158(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R159(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R160(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R161(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R162(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R163(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R164(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R165(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R166(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R167(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R168(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R169(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R170(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R171(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R172(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R173(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R174(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R175(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R176(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R177(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R178(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R179(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R180(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R181(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R182(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R183(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R184(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R185(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R186(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R187(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R188(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R189(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R190(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R191(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R192(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R193(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R194(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R195(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R196(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R197(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R198(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R199(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R200(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R201(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R202(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R203(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R204(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R205(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R206(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R207(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R208(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R209(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R210(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R211(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R212(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R213(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R214(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R215(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R216(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R217(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R218(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R219(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R220(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R221(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R222(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R223(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R224(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R225(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R226(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R227(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R228(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R229(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R230(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R231(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R232(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R233(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R234(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Array<Token>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R235(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R236(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R237(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R238(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R239(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R240(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R241(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R242(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R243(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R244(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: OrderNote  = ret.pop();
		var retret: CompOrderResult  = ({ { note:hllr__0, result:null, ret:false }; });
		ret.push(retret);
	}
	private static inline function R245(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Result  = ret.pop();
		var retret: CompOrderResult  = ({ { note:null, result:hllr__0, ret:false }; });
		ret.push(retret);
	}
	private static inline function R246(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: OrderNote  = ret.pop();
		var retret: CompOrderResult  = ({ { note:hllr__0, result:null, ret:true }; });
		ret.push(retret);
	}
	private static inline function R247(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: Result  = ret.pop();
		var retret: CompOrderResult  = ({ { note:null, result:hllr__0, ret:true }; });
		ret.push(retret);
	}
	private static inline function R248(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScoEntry  = ({ { power : TU.power(hllr__0), locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R249(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScoEntry  = ({ { power : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R250(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: ScoEntry  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<ScoEntry>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R251(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ScoEntry  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<ScoEntry>  = ret.pop();
		var retret: Array<ScoEntry>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R252(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0: Phase  = ret.pop();
		var retret: Turn  = ({ { phase : hllr__0, turn : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R253(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R254(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R255(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R256(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R257(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R258(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R259(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R260(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R261(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R262(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Array<Int>  = ({ [TU.power(hllr__0)]; });
		ret.push(retret);
	}
	private static inline function R263(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: Array<Int>  = ret.pop();
		var retret: Array<Int>  = ({ hllr__0.push(TU.power(hllr__1)); hllr__0; });
		ret.push(retret);
	}
	private static inline function R264(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moHold(hllr__1); });
		ret.push(retret);
	}
	private static inline function R265(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moDisband(hllr__1); });
		ret.push(retret);
	}
	private static inline function R266(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moBuild(hllr__1); });
		ret.push(retret);
	}
	private static inline function R267(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moRemove(hllr__1); });
		ret.push(retret);
	}
	private static inline function R268(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Location  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moRetreat(hllr__1,hllr__4); });
		ret.push(retret);
	}
	private static inline function R269(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Location  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moMove(hllr__1,hllr__4); });
		ret.push(retret);
	}
	private static inline function R270(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: UnitWithLoc  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({
		moSupport(hllr__1,hllr__5,null);
	});
		ret.push(retret);
	}
	private static inline function R271(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__8: Province  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: UnitWithLoc  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({
		moSupport(hllr__1,hllr__5,hllr__8);
	});
		ret.push(retret);
	}
	private static inline function R272(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__8: Province  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: UnitWithLoc  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({
		moConvoy(hllr__1,hllr__5,hllr__8);
	});
		ret.push(retret);
	}
	private static inline function R273(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__8:Token = ret.pop();
var hllr__7: Array<Province>  = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Province  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({
		moMoveByConvoy(hllr__1,hllr__4,hllr__7);
	});
		ret.push(retret);
	}
	private static inline function R274(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MsgOrder  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MsgOrder>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R275(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MsgOrder>  = ret.pop();
		var retret: Array<MsgOrder>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R276(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: OrderNote  = ({ switch(cast(hllr__0,Token)) { case tOrderNote(x): x; default : null; } });
		ret.push(retret);
	}
	private static inline function R277(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R278(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R279(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R280(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R281(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R282(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R283(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R284(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R285(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R286(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R287(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R288(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R289(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R290(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R291(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R292(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R293(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R294(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R295(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Result  = ({ switch(cast(hllr__0,Token)) { case tResult(x): x; default : null; } });
		ret.push(retret);
	}
	private static inline function R296(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R297(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R298(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R299(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R300(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R301(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2: Location  = ret.pop();
var hllr__1: UnitType  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: UnitWithLoc  = ({ { power : TU.power(hllr__0), type : hllr__1, location : hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R302(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfProAdjacencies  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfProAdjacencies>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R303(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfProAdjacencies  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfProAdjacencies>  = ret.pop();
		var retret: Array<MdfProAdjacencies>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R304(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MdfCoastAdjacencies>  = ret.pop();
var hllr__0: Province  = ret.pop();
		var retret: MdfProAdjacencies  = ({ { pro : hllr__0, coasts : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R305(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Coast  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ hllr__1; });
		ret.push(retret);
	}
	private static inline function R306(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Location>  = ret.pop();
var hllr__0: UnitType  = ret.pop();
		var retret: MdfCoastAdjacencies  = ({ { unit : hllr__0, coast : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R307(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<Location>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Coast  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCoastAdjacencies  = ({ { unit : TU.unitType(hllr__1), coast : hllr__2, locs : hllr__4 }; });
		ret.push(retret);
	}
	private static inline function R308(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfCoastAdjacencies  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfCoastAdjacencies>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R309(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfCoastAdjacencies  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfCoastAdjacencies>  = ret.pop();
		var retret: Array<MdfCoastAdjacencies>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R310(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: [TU.power(hllr__0)], locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R311(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: [], locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R312(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3: Array<Province>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: Array<Int>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: hllr__1, locs : hllr__3 }; });
		ret.push(retret);
	}
	private static inline function R313(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfCentreList  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfCentreList>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R314(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfCentreList  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfCentreList>  = ret.pop();
		var retret: Array<MdfCentreList>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R315(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__5:Token = ret.pop();
var hllr__4: Array<Province>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: Array<MdfCentreList>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfProvinces  = ({ {slocs: hllr__1, locs : hllr__4 }; });
		ret.push(retret);
	}
	private static inline function R316(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Province  = ret.pop();
		var retret: Location  = ({ { province : hllr__0, coast : null }; });
		ret.push(retret);
	}
	private static inline function R317(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Location  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Location  = ({ hllr__1; });
		ret.push(retret);
	}
	private static inline function R318(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Location  = ret.pop();
		var retret: Array<Location>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R319(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Location  = ret.pop();
var hllr__0: Array<Location>  = ret.pop();
		var retret: Array<Location>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R320(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,cast [hllr__2]); });
		ret.push(retret);
	}
	private static inline function R321(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,null); });
		ret.push(retret);
	}
	private static inline function R322(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R323(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R324(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R325(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R326(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline((hllr__2)); });
		ret.push(retret);
	}
	private static inline function R327(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Coast  = ret.pop();
var hllr__0: Province  = ret.pop();
		var retret: Location  = ({ { province : hllr__0, coast : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R328(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Province  = ret.pop();
		var retret: Array<Province>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R329(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Province  = ret.pop();
var hllr__0: Array<Province>  = ret.pop();
		var retret: Array<Province>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R330(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: UnitType  = ({ TU.unitType(hllr__0); });
		ret.push(retret);
	}
	private static inline function R331(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: UnitType  = ({ TU.unitType(hllr__0); });
		ret.push(retret);
	}
	private static inline function R332(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: UnitWithLoc  = ret.pop();
		var retret: UnitWithLocAndMRT  = ({ { unitloc : hllr__0, locs : null }; });
		ret.push(retret);
	}
	private static inline function R333(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Location>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: UnitWithLoc  = ret.pop();
		var retret: UnitWithLocAndMRT  = ({ { unitloc : hllr__0, locs : hllr__3 }; });
		ret.push(retret);
	}
	private static inline function R334(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<UnitWithLoc>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R335(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLoc  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<UnitWithLoc>  = ret.pop();
		var retret: Array<UnitWithLoc>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R336(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLocAndMRT  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<UnitWithLocAndMRT>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R337(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLocAndMRT  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<UnitWithLocAndMRT>  = ret.pop();
		var retret: Array<UnitWithLocAndMRT>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R338(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: VariantOption  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Variant  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R339(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: VariantOption  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Variant  = ret.pop();
		var retret: Variant  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R340(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R341(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R342(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R343(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R344(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R345(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R346(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R347(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Int  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : (hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R348(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R349(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R350(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R351(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R352(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R353(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R354(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R355(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R356(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R357(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R358(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R359(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R360(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R361(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R362(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R363(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R364(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R365(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R366(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R367(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R368(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R369(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R370(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R371(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R372(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R373(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R374(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R375(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R376(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R377(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R378(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R379(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R380(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R381(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R382(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R383(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R384(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R385(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R386(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R387(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R388(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R389(ret:Array<Dynamic>) {
		//assign arguments.
		var retret: Array<Token>  = ({ []; });
		ret.push(retret);
	}
	private static inline function R390(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R391(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: ReplyMsg  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Explanation  = ({ { turn : hllr__2, reply : hllr__5 }; });
		ret.push(retret);
	}
	private static inline function R392(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: FutureOffer  = ({ hllr__3.unshift(TU.power(hllr__2)); hllr__3; });
		ret.push(retret);
	}
	private static inline function R393(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__5:Token = ret.pop();
var hllr__4: Turn  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: Turn  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Period  = ({ { from : hllr__1, to : hllr__4 }; });
		ret.push(retret);
	}
	private static inline function R394(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScOwnershipList  = ({ { power : TU.power(hllr__0), locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R395(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScOwnershipList  = ({ { power : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R396(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: ScOwnershipList  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<ScOwnershipList>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R397(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ScOwnershipList  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<ScOwnershipList>  = ret.pop();
		var retret: Array<ScOwnershipList>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R398(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ hllr__3.unshift(TU.power(hllr__2)); arPeace(hllr__3); });
		ret.push(retret);
	}
	private static inline function R399(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arAlly(hllr__2,hllr__6); });
		ret.push(retret);
	}
	private static inline function R400(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arDraw; });
		ret.push(retret);
	}
	private static inline function R401(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSolo(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R402(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R403(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arNAR(hllr__2); });
		ret.push(retret);
	}
	private static inline function R404(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arXDo(hllr__2); });
		ret.push(retret);
	}
	private static inline function R405(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: Array<Province>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arDMZ(hllr__2,hllr__5); });
		ret.push(retret);
	}
	private static inline function R406(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<ScOwnershipList>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSCD(hllr__1); });
		ret.push(retret);
	}
	private static inline function R407(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<UnitWithLoc>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arOCC(hllr__1); });
		ret.push(retret);
	}
	private static inline function R408(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arAND(hllr__1); });
		ret.push(retret);
	}
	private static inline function R409(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arOR(hllr__1); });
		ret.push(retret);
	}
	private static inline function R410(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__5: Array<Arrangement>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3: Int  = ret.pop();
var hllr__2: Int  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arCHO((hllr__2),(hllr__3),hllr__5); });
		ret.push(retret);
	}
	private static inline function R411(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: FutureOffer  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arFOR(hllr__2,null,hllr__5); });
		ret.push(retret);
	}
	private static inline function R412(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: FutureOffer  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Period  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arFOR(null,hllr__2,hllr__5); });
		ret.push(retret);
	}
	private static inline function R413(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arXOY(TU.power(hllr__2),TU.power(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R414(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<UnitWithLoc>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arYDO(TU.power(hllr__2),hllr__4); });
		ret.push(retret);
	}
	private static inline function R415(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: PressMsg  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Array<Int>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSND(TU.power(hllr__2),hllr__5,hllr__8,null); });
		ret.push(retret);
	}
	private static inline function R416(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: ReplyMsg  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Array<Int>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSND(TU.power(hllr__2),hllr__5,null,hllr__8); });
		ret.push(retret);
	}
	private static inline function R417(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arFWD(hllr__2,TU.power(hllr__5),TU.power(hllr__8)); });
		ret.push(retret);
	}
	private static inline function R418(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Array<Int>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arBCC(TU.power(hllr__2),hllr__5,TU.power(hllr__8)); });
		ret.push(retret);
	}
	private static inline function R419(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Arrangement  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<Arrangement>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R420(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<Arrangement>  = ret.pop();
		var retret: Array<Arrangement>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R421(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmPRP(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R422(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmTRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R423(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmCCL(hllr__2); });
		ret.push(retret);
	}
	private static inline function R424(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: LogicalOp  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmPRP(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R425(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmINS(hllr__2); });
		ret.push(retret);
	}
	private static inline function R426(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmQRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R427(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmSUG(hllr__2); });
		ret.push(retret);
	}
	private static inline function R428(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmTHK(hllr__2); });
		ret.push(retret);
	}
	private static inline function R429(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFCT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R430(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLoc  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmWHT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R431(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Province  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmHOW(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R432(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmHOW(null,TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R433(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: ReplyMsg  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmEXP(hllr__2,hllr__5); });
		ret.push(retret);
	}
	private static inline function R434(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__7:Token = ret.pop();
var hllr__6: PressMsg  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmIFF(hllr__2,hllr__6,null); });
		ret.push(retret);
	}
	private static inline function R435(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__11:Token = ret.pop();
var hllr__10: PressMsg  = ret.pop();
var hllr__9:Token = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: PressMsg  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmIFF(hllr__2,hllr__6,hllr__10); });
		ret.push(retret);
	}
	private static inline function R436(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: PressMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3: Int  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFRM(TU.power(hllr__2),(hllr__3),hllr__6,hllr__9,null); });
		ret.push(retret);
	}
	private static inline function R437(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: ReplyMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3: Int  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFRM(TU.power(hllr__2), (hllr__3), hllr__6, null, hllr__9); });
		ret.push(retret);
	}
	private static inline function R438(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmText(TU.text(hllr__0)); });
		ret.push(retret);
	}
	private static inline function R439(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ hllr__2; });
		ret.push(retret);
	}
	private static inline function R440(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: NegQuery  = ({ negQRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R441(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: NegQuery  = ({ negNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R442(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: LogicalOp  = ({ { and:true, list:hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R443(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: LogicalOp  = ({ { and:false,list:hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R444(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmYes(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R445(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmYes(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R446(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmRej(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R447(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmRej(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R448(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmBWX(hllr__2); });
		ret.push(retret);
	}
	private static inline function R449(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmHUH(hllr__2); });
		ret.push(retret);
	}
	private static inline function R450(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: NegQuery  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmTHK(hllr__2); });
		ret.push(retret);
	}
	private static inline function R451(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: NegQuery  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmFCT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R452(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmSRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R453(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmPOB(hllr__2); });
		ret.push(retret);
	}
	private static inline function R454(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmWHY(whyThinkFact(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R455(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmWHY(whySug(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R456(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmWHY(whyPRP(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R457(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmWHY(whyINS(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R458(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyQry(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R459(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyExp(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R460(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyPRP(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R461(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyINS(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R462(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4: Arrangement  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whySug(hllr__4)); });
		ret.push(retret);
	}
	private static inline function R463(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: PressMsg  = ret.pop();
		var retret: ReplyMsg  = ({ rmPress(hllr__0); });
		ret.push(retret);
	}
	private static inline function R464(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: PressMsg  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSend(null,hllr__2,hllr__5,null); });
		ret.push(retret);
	}
	private static inline function R465(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5: ReplyMsg  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Array<Int>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSend(null,hllr__2,null,hllr__5); });
		ret.push(retret);
	}
	private static inline function R466(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: PressMsg  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Array<Int>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSend(hllr__2,hllr__5,hllr__8,null); });
		ret.push(retret);
	}
	private static inline function R467(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: ReplyMsg  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5: Array<Int>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSend(hllr__2,hllr__5,null,hllr__8); });
		ret.push(retret);
	}
	private static inline function R468(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ { thk:true, arr:hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R469(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ { thk:false,arr:hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R470(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ hllr__2; });
		ret.push(retret);
	}
}
