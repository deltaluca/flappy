package daide;




import daide.Tokens;
import daide.Language;
import Type;

class TU {

	static public function text(t:Token) {
		return switch(t) { case tText(x): x; default: null; };
	}
	static public function integer(t:Token) {
		return switch(t) { case tInteger(x): x; default: -1; };
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
		ret.push(new ActionRule(58,aS(73)));
		ret.push(new ActionRule(59,aS(3)));
		ret.push(new ActionRule(60,aS(77)));
		ret.push(new ActionRule(61,aS(8),true,63));
		ret.push(new ActionRule(64,aS(14)));
		ret.push(new ActionRule(65,aS(18)));
		ret.push(new ActionRule(66,aS(99)));
		ret.push(new ActionRule(67,aS(25),true,70));
		ret.push(new ActionRule(71,aS(35)));
		ret.push(new ActionRule(72,aS(39),true,73));
		ret.push(new ActionRule(74,aS(125)));
		ret.push(new ActionRule(75,aS(41)));
		ret.push(new ActionRule(76,aS(135)));
		ret.push(new ActionRule(77,aS(42)));
		ret.push(new ActionRule(78,aS(46)));
		ret.push(new ActionRule(79,aS(50)));
		ret.push(new ActionRule(80,aS(144)));
		ret.push(new ActionRule(81,aS(244)));
		ret.push(new ActionRule(82,aS(51)));
		ret.push(new ActionRule(83,aS(148)));
		ret.push(new ActionRule(84,aS(152)));
		ret.push(new ActionRule(85,aS(57)));
		ret.push(new ActionRule(86,aS(61)));
		ret.push(new ActionRule(87,aS(65)));
		ret.push(new ActionRule(143,aG(979)));
		ret.push(new ActionRule(144,aG(1),true,145));
		ret.push(new ActionRule(153,aG(72)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(0)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(1)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(24)));
		ret.push(new ActionRule(3,aS(4)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(5)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(6)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(7)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(25)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(22)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(17)));
		ret.push(new ActionRule(3,aS(90)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(11)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(12)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(13)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(11)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(15)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(183)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(149,aG(16)));
		ret.push(new ActionRule(169,aG(192)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(184)));
		ret.push(new ActionRule(4,aS(17)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(169,aG(191)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(16)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(19)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(20)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(21)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(22)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(23)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(24)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(4)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(5)));
		ret.push(new ActionRule(3,aS(103)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(6)));
		ret.push(new ActionRule(3,aS(106)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(21)));
		ret.push(new ActionRule(3,aS(115)));
		ret.push(new ActionRule(160,aG(118)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(29)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(30)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(31)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(32)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(34)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(2)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(58,aS(373)));
		ret.push(new ActionRule(59,aS(201)));
		ret.push(new ActionRule(61,aS(206)));
		ret.push(new ActionRule(82,aS(207)));
		ret.push(new ActionRule(85,aS(211)));
		ret.push(new ActionRule(151,aG(37)));
		ret.push(new ActionRule(165,aG(119)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(38)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(20)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(9)));
		ret.push(new ActionRule(3,aS(121)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(3)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(23)));
		ret.push(new ActionRule(3,aS(126)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(43)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(678),true,4));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(148,aG(44)));
		ret.push(new ActionRule(169,aG(680)));
		ret.push(new ActionRule(170,aG(182)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(678)));
		ret.push(new ActionRule(4,aS(45)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(169,aG(680)));
		ret.push(new ActionRule(170,aG(181)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(15)));
		ret.push(new ActionRule(2,aR(224),87));
		ret.push(new ActionRule(89,aR(224),135));
		ret.push(new ActionRule(138,aR(224),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(47)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(264)));
		ret.push(new ActionRule(61,aS(267)));
		ret.push(new ActionRule(62,aS(294),true,63));
		ret.push(new ActionRule(65,aS(268)));
		ret.push(new ActionRule(67,aS(163)));
		ret.push(new ActionRule(70,aS(275)));
		ret.push(new ActionRule(71,aS(282)));
		ret.push(new ActionRule(72,aS(298)));
		ret.push(new ActionRule(75,aS(299)));
		ret.push(new ActionRule(79,aS(300)));
		ret.push(new ActionRule(81,aS(244)));
		ret.push(new ActionRule(82,aS(193)));
		ret.push(new ActionRule(83,aS(167)));
		ret.push(new ActionRule(85,aS(289)));
		ret.push(new ActionRule(87,aS(301)));
		ret.push(new ActionRule(146,aG(48)));
		ret.push(new ActionRule(153,aG(293)));
		ret.push(new ActionRule(155,aG(139)));
		ret.push(new ActionRule(156,aG(141)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(49)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(8)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(10)));
		ret.push(new ActionRule(3,aS(332)));
		ret.push(new ActionRule(161,aG(143)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(52)));
		ret.push(new ActionRule(150,aG(56)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(53)));
		ret.push(new ActionRule(162,aG(195)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(54)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(194)));
		ret.push(new ActionRule(150,aG(55)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(19)));
		ret.push(new ActionRule(3,aS(198)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(18)));
		ret.push(new ActionRule(3,aS(198)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(13)));
		ret.push(new ActionRule(3,aS(58)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(59)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(12)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(62)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(264)));
		ret.push(new ActionRule(61,aS(267)));
		ret.push(new ActionRule(65,aS(268)));
		ret.push(new ActionRule(67,aS(163)));
		ret.push(new ActionRule(70,aS(275)));
		ret.push(new ActionRule(71,aS(259)));
		ret.push(new ActionRule(73,aS(263)));
		ret.push(new ActionRule(81,aS(244)));
		ret.push(new ActionRule(83,aS(167)));
		ret.push(new ActionRule(85,aS(288)));
		ret.push(new ActionRule(146,aG(63)));
		ret.push(new ActionRule(153,aG(293)));
		ret.push(new ActionRule(154,aG(159)));
		ret.push(new ActionRule(155,aG(161)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(64)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(7)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(66)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(67)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(68)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(69)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(70)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(71)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(14)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(26)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(74)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(75)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(76)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(46)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(78)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(79)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(80)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(81)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(82)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(83)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(84)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(85)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(86)));
		ret.push(new ActionRule(167,aG(88)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(87)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(53)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(89)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(54)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(91)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(92)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(93)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(94)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(95)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(96)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(320)));
		ret.push(new ActionRule(159,aG(97)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(323)));
		ret.push(new ActionRule(4,aS(98)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(33)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(100)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(101)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(102)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(41)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(104)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(105)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(31)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(107)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(108)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(109)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(308)));
		ret.push(new ActionRule(157,aG(110)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(111)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(112)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(314)));
		ret.push(new ActionRule(158,aG(113)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(317)));
		ret.push(new ActionRule(4,aS(114)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(32)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(116)));
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(778)));
		ret.push(new ActionRule(190,aG(327)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(117)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(38)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(37)));
		ret.push(new ActionRule(3,aS(329)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(120)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(47)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(122)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(123)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(326)));
		ret.push(new ActionRule(160,aG(124)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(34)));
		ret.push(new ActionRule(3,aS(329)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(42)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(127)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(128)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(129)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(130)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(131)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(132)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(19,aS(734)));
		ret.push(new ActionRule(21,aS(735),true,41));
		ret.push(new ActionRule(43,aS(756)));
		ret.push(new ActionRule(163,aG(369)));
		ret.push(new ActionRule(164,aG(133)));
		ret.push(new ActionRule(172,aG(371)));
		ret.push(new ActionRule(179,aG(368)));
		ret.push(new ActionRule(180,aG(691)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(134)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(39)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(136)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(137)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(138)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(51)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(140)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(29)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(142)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(30)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(35)));
		ret.push(new ActionRule(3,aS(335)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(145)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(146)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(147)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(49)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(149)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(150)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(151)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(40)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(153)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(154)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(155)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(156)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(19,aS(734)));
		ret.push(new ActionRule(21,aS(735),true,37));
		ret.push(new ActionRule(163,aG(157)));
		ret.push(new ActionRule(179,aG(368)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(158)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(36)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(160)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(27)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(162)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(28)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(164)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(165)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(166)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(55)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(168)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(169)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(170)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(56)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(245)));
		ret.push(new ActionRule(152,aG(230)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(296)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(400)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(401)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(845)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(177)));
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(912)));
		ret.push(new ActionRule(175,aG(179)));
		ret.push(new ActionRule(197,aG(916)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(854)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(53,aS(710),true,57));
		ret.push(new ActionRule(147,aG(856)));
		ret.push(new ActionRule(175,aG(179)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(180)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(226),87));
		ret.push(new ActionRule(89,aR(226),135));
		ret.push(new ActionRule(138,aR(226),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(225),87));
		ret.push(new ActionRule(89,aR(225),135));
		ret.push(new ActionRule(138,aR(225),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(183)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(149,aG(186)));
		ret.push(new ActionRule(169,aG(192)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(183)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(149,aG(188)));
		ret.push(new ActionRule(169,aG(192)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(183)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(149,aG(189)));
		ret.push(new ActionRule(169,aG(192)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(184)));
		ret.push(new ActionRule(4,aS(187)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(169,aG(191)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(82),87));
		ret.push(new ActionRule(89,aR(82),135));
		ret.push(new ActionRule(138,aR(82),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(184)));
		ret.push(new ActionRule(4,aS(190)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(169,aG(191)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(542)));
		ret.push(new ActionRule(3,aS(184)));
		ret.push(new ActionRule(4,aS(467)));
		ret.push(new ActionRule(5,aS(543),true,87));
		ret.push(new ActionRule(89,aS(626),true,135));
		ret.push(new ActionRule(138,aS(673),true,142));
		ret.push(new ActionRule(169,aG(191)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(84),87));
		ret.push(new ActionRule(89,aR(84),135));
		ret.push(new ActionRule(138,aR(84),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(83),87));
		ret.push(new ActionRule(89,aR(83),135));
		ret.push(new ActionRule(138,aR(83),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(81),87));
		ret.push(new ActionRule(89,aR(81),135));
		ret.push(new ActionRule(138,aR(81),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(194)));
		ret.push(new ActionRule(150,aG(197)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(195)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(196)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(265)));
		ret.push(new ActionRule(3,aR(265),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(198)));
		ret.push(new ActionRule(4,aR(77)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(199)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(200)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(266)));
		ret.push(new ActionRule(3,aR(266),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(202)));
		ret.push(new ActionRule(4,aR(314)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(203)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(204)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(205)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(315)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(313)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(208)));
		ret.push(new ActionRule(4,aR(312)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(209)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(210)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(311)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(212)));
		ret.push(new ActionRule(4,aR(316)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(213)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(214)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(71)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(229)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(231)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(232)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(233)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(234)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(235)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(236)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(237)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(238)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(239)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(240)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(241)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(228)));
		ret.push(new ActionRule(152,aG(242)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(253),5));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(247)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(253)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(266)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(393)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(537)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(696)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(853)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(888)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(893)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(895)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(901)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(904)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(926)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(950)));
		ret.push(new ActionRule(5,aS(243)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(254),5));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(171)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(246)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(215)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(248)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(249)));
		ret.push(new ActionRule(167,aG(251)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(250)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(457)));
		ret.push(new ActionRule(4,aR(457)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(252)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(458)));
		ret.push(new ActionRule(4,aR(458)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(254)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(255)));
		ret.push(new ActionRule(167,aG(257)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(256)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(455)));
		ret.push(new ActionRule(4,aR(455)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(258)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(456)));
		ret.push(new ActionRule(4,aR(456)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(260)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(535)));
		ret.push(new ActionRule(61,aS(284)));
		ret.push(new ActionRule(85,aS(261)));
		ret.push(new ActionRule(168,aG(286)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(539)));
		ret.push(new ActionRule(4,aS(262)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(58)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(57)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(265)));
		ret.push(new ActionRule(4,aR(64)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(216)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(66)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(62)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(269)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(270)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(271)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(272)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(273)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(274)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(60)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(276)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(277)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(278)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(279)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(280)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(281)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(59)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(283)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(535)));
		ret.push(new ActionRule(61,aS(284)));
		ret.push(new ActionRule(85,aS(538)));
		ret.push(new ActionRule(168,aG(286)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(285)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(61)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(287)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(65)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(290)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(290)));
		ret.push(new ActionRule(4,aR(79)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(291)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(292)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(63)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(67)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(73)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(172)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(297)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(76)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(74)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(78)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(75)));
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
		ret.push(new ActionRule(3,aS(305)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(138,aS(306)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(307)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(80)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(771)));
		ret.push(new ActionRule(188,aG(309)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(772)));
		ret.push(new ActionRule(4,aS(310)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(311)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(312)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(313)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(306)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(761)));
		ret.push(new ActionRule(182,aG(315)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(316)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(293),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(761)));
		ret.push(new ActionRule(182,aG(318)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(319)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(294),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(89,aS(789),true,90));
		ret.push(new ActionRule(92,aS(792)));
		ret.push(new ActionRule(94,aS(794)));
		ret.push(new ActionRule(95,aS(796),true,98));
		ret.push(new ActionRule(99,aS(801)));
		ret.push(new ActionRule(101,aS(803)));
		ret.push(new ActionRule(192,aG(321)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(322)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(329),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(89,aS(789),true,90));
		ret.push(new ActionRule(92,aS(792)));
		ret.push(new ActionRule(94,aS(794)));
		ret.push(new ActionRule(95,aS(796),true,98));
		ret.push(new ActionRule(99,aS(801)));
		ret.push(new ActionRule(101,aS(803)));
		ret.push(new ActionRule(192,aG(324)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(325)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(330),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(778)));
		ret.push(new ActionRule(190,aG(327)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(328)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(327)));
		ret.push(new ActionRule(3,aR(327)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(778)));
		ret.push(new ActionRule(190,aG(330)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(331)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(328)));
		ret.push(new ActionRule(3,aR(328)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(692)));
		ret.push(new ActionRule(100,aS(694)));
		ret.push(new ActionRule(173,aG(333)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(334)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(241)));
		ret.push(new ActionRule(3,aR(241)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(692)));
		ret.push(new ActionRule(100,aS(694)));
		ret.push(new ActionRule(173,aG(336)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(337)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aR(242)));
		ret.push(new ActionRule(3,aR(242)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(339)));
		ret.push(new ActionRule(162,aG(928)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(340)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(341)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(8,aS(342)));
		ret.push(new ActionRule(9,aS(348)));
		ret.push(new ActionRule(10,aS(354),true,11));
		ret.push(new ActionRule(12,aS(357)));
		ret.push(new ActionRule(14,aS(363),true,15));
		ret.push(new ActionRule(16,aS(366),true,17));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(343)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(13,aS(344)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(345)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(346)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(347)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(264)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(349)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(350)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(351)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(8,aS(352)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(353)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(263)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(255)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(356)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(260)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(358)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(359)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(360)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(261)));
		ret.push(new ActionRule(11,aS(361)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(362)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(262)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(256)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(365)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(259)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(257)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(258)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(267)));
		ret.push(new ActionRule(44,aR(267)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(235)));
		ret.push(new ActionRule(44,aS(370)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(237)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(236)));
		ret.push(new ActionRule(44,aS(372)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(238)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(374)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(375)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(376)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(72)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(394)));
		ret.push(new ActionRule(167,aG(396)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(533)));
		ret.push(new ActionRule(167,aG(404)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(533)));
		ret.push(new ActionRule(167,aG(405)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(425)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(428)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(463)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(533)));
		ret.push(new ActionRule(167,aG(847)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(64,aS(466)));
		ret.push(new ActionRule(78,aS(468)));
		ret.push(new ActionRule(86,aS(473)));
		ret.push(new ActionRule(104,aS(478)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(409)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(112,aS(483)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(118,aS(504)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(122,aS(508)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(449)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(129,aS(514)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(534)));
		ret.push(new ActionRule(167,aG(890)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(399)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(469)));
		ret.push(new ActionRule(195,aG(471)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(399)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(474)));
		ret.push(new ActionRule(195,aG(476)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(60,aS(388)));
		ret.push(new ActionRule(107,aS(398)));
		ret.push(new ActionRule(109,aS(408)));
		ret.push(new ActionRule(111,aS(414)));
		ret.push(new ActionRule(113,aS(420)));
		ret.push(new ActionRule(114,aS(430)));
		ret.push(new ActionRule(119,aS(434)));
		ret.push(new ActionRule(120,aS(440)));
		ret.push(new ActionRule(123,aS(444)));
		ret.push(new ActionRule(124,aS(448)));
		ret.push(new ActionRule(126,aS(454)));
		ret.push(new ActionRule(128,aS(458)));
		ret.push(new ActionRule(136,aS(462)));
		ret.push(new ActionRule(138,aS(465)));
		ret.push(new ActionRule(166,aG(479)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(389)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(390)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(391)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(392)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(217)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(377)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(395)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(427)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(397)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(428)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(173)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(174)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(402)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(403)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(378)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(379)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(406)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(407)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(424)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(382)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(411)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(410)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(877)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(120,aS(966)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(412)));
		ret.push(new ActionRule(204,aG(481)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(412)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(413)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(420)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(415)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(416)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(418)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(417)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(423)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(419)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(422)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(421)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(422)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(423)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(125,aS(424)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(380)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(426)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(425)));
		ret.push(new ActionRule(106,aS(427)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(381)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(429)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(426)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(431)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(432)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(433)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(416)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(435)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(897)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(921)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(436)));
		ret.push(new ActionRule(202,aG(438)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(437)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(412)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(439)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(415)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(441)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(442)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(443)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(417)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(445)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(446)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(447)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(418)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(451)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(450)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(877)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(120,aS(966)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(452)));
		ret.push(new ActionRule(204,aG(512)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(452)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(453)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(419)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(455)));
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
		ret.push(new ActionRule(194,aG(456)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(457)));
		ret.push(new ActionRule(59,aS(804),true,60));
		ret.push(new ActionRule(71,aS(806)));
		ret.push(new ActionRule(78,aS(807)));
		ret.push(new ActionRule(80,aS(808),true,81));
		ret.push(new ActionRule(86,aS(810)));
		ret.push(new ActionRule(102,aS(811),true,125));
		ret.push(new ActionRule(127,aS(835),true,132));
		ret.push(new ActionRule(136,aS(841),true,137));
		ret.push(new ActionRule(193,aG(843)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(413)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(459)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(460)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(461)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(421)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(382)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(464)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(414)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(429)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(185)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(440)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(385)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(470)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(437)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(472)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(438)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(386)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(475)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(435)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(477)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(436)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(387)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(480)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(439)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(482)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(442)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(484)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(107,aS(844)));
		ret.push(new ActionRule(114,aS(485)));
		ret.push(new ActionRule(119,aS(490)));
		ret.push(new ActionRule(120,aS(961)));
		ret.push(new ActionRule(123,aS(495)));
		ret.push(new ActionRule(195,aG(500)));
		ret.push(new ActionRule(203,aG(502)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(486)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(487)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(488)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(489)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(452)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(491)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(492)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(493)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(494)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(451)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(496)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(497)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(498)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(499)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(453)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(501)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(450)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(503)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(449)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(505)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(129,aS(969)));
		ret.push(new ActionRule(205,aG(506)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(507)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(444)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(509)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(107,aS(844)));
		ret.push(new ActionRule(195,aG(510)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(511)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(443)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(513)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(441)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(515)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(109,aS(973)));
		ret.push(new ActionRule(114,aS(516)));
		ret.push(new ActionRule(119,aS(521)));
		ret.push(new ActionRule(123,aS(526)));
		ret.push(new ActionRule(124,aS(976)));
		ret.push(new ActionRule(206,aG(531)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(517)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(518)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(519)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(520)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(448)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(522)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(523)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(524)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(525)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(447)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(527)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(528)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(529)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(530)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(446)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(532)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(445)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(454)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(889)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(536)));
		ret.push(new ActionRule(4,aR(69)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(218)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(70)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(539)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(540)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(541)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(68)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(86),87));
		ret.push(new ActionRule(89,aR(86),135));
		ret.push(new ActionRule(138,aR(86),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(87),87));
		ret.push(new ActionRule(89,aR(87),135));
		ret.push(new ActionRule(138,aR(87),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(88),87));
		ret.push(new ActionRule(89,aR(88),135));
		ret.push(new ActionRule(138,aR(88),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(89),87));
		ret.push(new ActionRule(89,aR(89),135));
		ret.push(new ActionRule(138,aR(89),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(90),87));
		ret.push(new ActionRule(89,aR(90),135));
		ret.push(new ActionRule(138,aR(90),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(91),87));
		ret.push(new ActionRule(89,aR(91),135));
		ret.push(new ActionRule(138,aR(91),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(92),87));
		ret.push(new ActionRule(89,aR(92),135));
		ret.push(new ActionRule(138,aR(92),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(93),87));
		ret.push(new ActionRule(89,aR(93),135));
		ret.push(new ActionRule(138,aR(93),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(94),87));
		ret.push(new ActionRule(89,aR(94),135));
		ret.push(new ActionRule(138,aR(94),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(95),87));
		ret.push(new ActionRule(89,aR(95),135));
		ret.push(new ActionRule(138,aR(95),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(96),87));
		ret.push(new ActionRule(89,aR(96),135));
		ret.push(new ActionRule(138,aR(96),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(97),87));
		ret.push(new ActionRule(89,aR(97),135));
		ret.push(new ActionRule(138,aR(97),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(98),87));
		ret.push(new ActionRule(89,aR(98),135));
		ret.push(new ActionRule(138,aR(98),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(99),87));
		ret.push(new ActionRule(89,aR(99),135));
		ret.push(new ActionRule(138,aR(99),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(100),87));
		ret.push(new ActionRule(89,aR(100),135));
		ret.push(new ActionRule(138,aR(100),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(101),87));
		ret.push(new ActionRule(89,aR(101),135));
		ret.push(new ActionRule(138,aR(101),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(102),87));
		ret.push(new ActionRule(89,aR(102),135));
		ret.push(new ActionRule(138,aR(102),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(103),87));
		ret.push(new ActionRule(89,aR(103),135));
		ret.push(new ActionRule(138,aR(103),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(104),87));
		ret.push(new ActionRule(89,aR(104),135));
		ret.push(new ActionRule(138,aR(104),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(105),87));
		ret.push(new ActionRule(89,aR(105),135));
		ret.push(new ActionRule(138,aR(105),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(106),87));
		ret.push(new ActionRule(89,aR(106),135));
		ret.push(new ActionRule(138,aR(106),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(107),87));
		ret.push(new ActionRule(89,aR(107),135));
		ret.push(new ActionRule(138,aR(107),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(108),87));
		ret.push(new ActionRule(89,aR(108),135));
		ret.push(new ActionRule(138,aR(108),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(109),87));
		ret.push(new ActionRule(89,aR(109),135));
		ret.push(new ActionRule(138,aR(109),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(110),87));
		ret.push(new ActionRule(89,aR(110),135));
		ret.push(new ActionRule(138,aR(110),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(111),87));
		ret.push(new ActionRule(89,aR(111),135));
		ret.push(new ActionRule(138,aR(111),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(112),87));
		ret.push(new ActionRule(89,aR(112),135));
		ret.push(new ActionRule(138,aR(112),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(113),87));
		ret.push(new ActionRule(89,aR(113),135));
		ret.push(new ActionRule(138,aR(113),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(114),87));
		ret.push(new ActionRule(89,aR(114),135));
		ret.push(new ActionRule(138,aR(114),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(115),87));
		ret.push(new ActionRule(89,aR(115),135));
		ret.push(new ActionRule(138,aR(115),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(116),87));
		ret.push(new ActionRule(89,aR(116),135));
		ret.push(new ActionRule(138,aR(116),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(117),87));
		ret.push(new ActionRule(89,aR(117),135));
		ret.push(new ActionRule(138,aR(117),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(118),87));
		ret.push(new ActionRule(89,aR(118),135));
		ret.push(new ActionRule(138,aR(118),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(119),87));
		ret.push(new ActionRule(89,aR(119),135));
		ret.push(new ActionRule(138,aR(119),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(120),87));
		ret.push(new ActionRule(89,aR(120),135));
		ret.push(new ActionRule(138,aR(120),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(121),87));
		ret.push(new ActionRule(89,aR(121),135));
		ret.push(new ActionRule(138,aR(121),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(122),87));
		ret.push(new ActionRule(89,aR(122),135));
		ret.push(new ActionRule(138,aR(122),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(123),87));
		ret.push(new ActionRule(89,aR(123),135));
		ret.push(new ActionRule(138,aR(123),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(124),87));
		ret.push(new ActionRule(89,aR(124),135));
		ret.push(new ActionRule(138,aR(124),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(125),87));
		ret.push(new ActionRule(89,aR(125),135));
		ret.push(new ActionRule(138,aR(125),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(126),87));
		ret.push(new ActionRule(89,aR(126),135));
		ret.push(new ActionRule(138,aR(126),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(127),87));
		ret.push(new ActionRule(89,aR(127),135));
		ret.push(new ActionRule(138,aR(127),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(128),87));
		ret.push(new ActionRule(89,aR(128),135));
		ret.push(new ActionRule(138,aR(128),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(129),87));
		ret.push(new ActionRule(89,aR(129),135));
		ret.push(new ActionRule(138,aR(129),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(130),87));
		ret.push(new ActionRule(89,aR(130),135));
		ret.push(new ActionRule(138,aR(130),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(131),87));
		ret.push(new ActionRule(89,aR(131),135));
		ret.push(new ActionRule(138,aR(131),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(132),87));
		ret.push(new ActionRule(89,aR(132),135));
		ret.push(new ActionRule(138,aR(132),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(133),87));
		ret.push(new ActionRule(89,aR(133),135));
		ret.push(new ActionRule(138,aR(133),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(134),87));
		ret.push(new ActionRule(89,aR(134),135));
		ret.push(new ActionRule(138,aR(134),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(135),87));
		ret.push(new ActionRule(89,aR(135),135));
		ret.push(new ActionRule(138,aR(135),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(136),87));
		ret.push(new ActionRule(89,aR(136),135));
		ret.push(new ActionRule(138,aR(136),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(137),87));
		ret.push(new ActionRule(89,aR(137),135));
		ret.push(new ActionRule(138,aR(137),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(138),87));
		ret.push(new ActionRule(89,aR(138),135));
		ret.push(new ActionRule(138,aR(138),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(139),87));
		ret.push(new ActionRule(89,aR(139),135));
		ret.push(new ActionRule(138,aR(139),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(140),87));
		ret.push(new ActionRule(89,aR(140),135));
		ret.push(new ActionRule(138,aR(140),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(141),87));
		ret.push(new ActionRule(89,aR(141),135));
		ret.push(new ActionRule(138,aR(141),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(142),87));
		ret.push(new ActionRule(89,aR(142),135));
		ret.push(new ActionRule(138,aR(142),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(143),87));
		ret.push(new ActionRule(89,aR(143),135));
		ret.push(new ActionRule(138,aR(143),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(144),87));
		ret.push(new ActionRule(89,aR(144),135));
		ret.push(new ActionRule(138,aR(144),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(145),87));
		ret.push(new ActionRule(89,aR(145),135));
		ret.push(new ActionRule(138,aR(145),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(146),87));
		ret.push(new ActionRule(89,aR(146),135));
		ret.push(new ActionRule(138,aR(146),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(147),87));
		ret.push(new ActionRule(89,aR(147),135));
		ret.push(new ActionRule(138,aR(147),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(148),87));
		ret.push(new ActionRule(89,aR(148),135));
		ret.push(new ActionRule(138,aR(148),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(149),87));
		ret.push(new ActionRule(89,aR(149),135));
		ret.push(new ActionRule(138,aR(149),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(150),87));
		ret.push(new ActionRule(89,aR(150),135));
		ret.push(new ActionRule(138,aR(150),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(151),87));
		ret.push(new ActionRule(89,aR(151),135));
		ret.push(new ActionRule(138,aR(151),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(152),87));
		ret.push(new ActionRule(89,aR(152),135));
		ret.push(new ActionRule(138,aR(152),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(153),87));
		ret.push(new ActionRule(89,aR(153),135));
		ret.push(new ActionRule(138,aR(153),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(154),87));
		ret.push(new ActionRule(89,aR(154),135));
		ret.push(new ActionRule(138,aR(154),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(155),87));
		ret.push(new ActionRule(89,aR(155),135));
		ret.push(new ActionRule(138,aR(155),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(156),87));
		ret.push(new ActionRule(89,aR(156),135));
		ret.push(new ActionRule(138,aR(156),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(157),87));
		ret.push(new ActionRule(89,aR(157),135));
		ret.push(new ActionRule(138,aR(157),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(158),87));
		ret.push(new ActionRule(89,aR(158),135));
		ret.push(new ActionRule(138,aR(158),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(159),87));
		ret.push(new ActionRule(89,aR(159),135));
		ret.push(new ActionRule(138,aR(159),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(160),87));
		ret.push(new ActionRule(89,aR(160),135));
		ret.push(new ActionRule(138,aR(160),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(161),87));
		ret.push(new ActionRule(89,aR(161),135));
		ret.push(new ActionRule(138,aR(161),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(162),87));
		ret.push(new ActionRule(89,aR(162),135));
		ret.push(new ActionRule(138,aR(162),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(163),87));
		ret.push(new ActionRule(89,aR(163),135));
		ret.push(new ActionRule(138,aR(163),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(164),87));
		ret.push(new ActionRule(89,aR(164),135));
		ret.push(new ActionRule(138,aR(164),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(165),87));
		ret.push(new ActionRule(89,aR(165),135));
		ret.push(new ActionRule(138,aR(165),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(166),87));
		ret.push(new ActionRule(89,aR(166),135));
		ret.push(new ActionRule(138,aR(166),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(167),87));
		ret.push(new ActionRule(89,aR(167),135));
		ret.push(new ActionRule(138,aR(167),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(168),87));
		ret.push(new ActionRule(89,aR(168),135));
		ret.push(new ActionRule(138,aR(168),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(169),87));
		ret.push(new ActionRule(89,aR(169),135));
		ret.push(new ActionRule(138,aR(169),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(170),87));
		ret.push(new ActionRule(89,aR(170),135));
		ret.push(new ActionRule(138,aR(170),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(171),87));
		ret.push(new ActionRule(89,aR(171),135));
		ret.push(new ActionRule(138,aR(171),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(172),87));
		ret.push(new ActionRule(89,aR(172),135));
		ret.push(new ActionRule(138,aR(172),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(173),87));
		ret.push(new ActionRule(89,aR(173),135));
		ret.push(new ActionRule(138,aR(173),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(174),87));
		ret.push(new ActionRule(89,aR(174),135));
		ret.push(new ActionRule(138,aR(174),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(175),87));
		ret.push(new ActionRule(89,aR(175),135));
		ret.push(new ActionRule(138,aR(175),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(176),87));
		ret.push(new ActionRule(89,aR(176),135));
		ret.push(new ActionRule(138,aR(176),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(177),87));
		ret.push(new ActionRule(89,aR(177),135));
		ret.push(new ActionRule(138,aR(177),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(178),87));
		ret.push(new ActionRule(89,aR(178),135));
		ret.push(new ActionRule(138,aR(178),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(179),87));
		ret.push(new ActionRule(89,aR(179),135));
		ret.push(new ActionRule(138,aR(179),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(180),87));
		ret.push(new ActionRule(89,aR(180),135));
		ret.push(new ActionRule(138,aR(180),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(181),87));
		ret.push(new ActionRule(89,aR(181),135));
		ret.push(new ActionRule(138,aR(181),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(182),87));
		ret.push(new ActionRule(89,aR(182),135));
		ret.push(new ActionRule(138,aR(182),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(183),87));
		ret.push(new ActionRule(89,aR(183),135));
		ret.push(new ActionRule(138,aR(183),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(184),87));
		ret.push(new ActionRule(89,aR(184),135));
		ret.push(new ActionRule(138,aR(184),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(185),87));
		ret.push(new ActionRule(89,aR(185),135));
		ret.push(new ActionRule(138,aR(185),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(186),87));
		ret.push(new ActionRule(89,aR(186),135));
		ret.push(new ActionRule(138,aR(186),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(187),87));
		ret.push(new ActionRule(89,aR(187),135));
		ret.push(new ActionRule(138,aR(187),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(188),87));
		ret.push(new ActionRule(89,aR(188),135));
		ret.push(new ActionRule(138,aR(188),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(189),87));
		ret.push(new ActionRule(89,aR(189),135));
		ret.push(new ActionRule(138,aR(189),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(190),87));
		ret.push(new ActionRule(89,aR(190),135));
		ret.push(new ActionRule(138,aR(190),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(191),87));
		ret.push(new ActionRule(89,aR(191),135));
		ret.push(new ActionRule(138,aR(191),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(192),87));
		ret.push(new ActionRule(89,aR(192),135));
		ret.push(new ActionRule(138,aR(192),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(193),87));
		ret.push(new ActionRule(89,aR(193),135));
		ret.push(new ActionRule(138,aR(193),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(194),87));
		ret.push(new ActionRule(89,aR(194),135));
		ret.push(new ActionRule(138,aR(194),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(195),87));
		ret.push(new ActionRule(89,aR(195),135));
		ret.push(new ActionRule(138,aR(195),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(196),87));
		ret.push(new ActionRule(89,aR(196),135));
		ret.push(new ActionRule(138,aR(196),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(197),87));
		ret.push(new ActionRule(89,aR(197),135));
		ret.push(new ActionRule(138,aR(197),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(198),87));
		ret.push(new ActionRule(89,aR(198),135));
		ret.push(new ActionRule(138,aR(198),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(199),87));
		ret.push(new ActionRule(89,aR(199),135));
		ret.push(new ActionRule(138,aR(199),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(200),87));
		ret.push(new ActionRule(89,aR(200),135));
		ret.push(new ActionRule(138,aR(200),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(201),87));
		ret.push(new ActionRule(89,aR(201),135));
		ret.push(new ActionRule(138,aR(201),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(202),87));
		ret.push(new ActionRule(89,aR(202),135));
		ret.push(new ActionRule(138,aR(202),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(203),87));
		ret.push(new ActionRule(89,aR(203),135));
		ret.push(new ActionRule(138,aR(203),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(204),87));
		ret.push(new ActionRule(89,aR(204),135));
		ret.push(new ActionRule(138,aR(204),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(205),87));
		ret.push(new ActionRule(89,aR(205),135));
		ret.push(new ActionRule(138,aR(205),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(206),87));
		ret.push(new ActionRule(89,aR(206),135));
		ret.push(new ActionRule(138,aR(206),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(207),87));
		ret.push(new ActionRule(89,aR(207),135));
		ret.push(new ActionRule(138,aR(207),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(208),87));
		ret.push(new ActionRule(89,aR(208),135));
		ret.push(new ActionRule(138,aR(208),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(209),87));
		ret.push(new ActionRule(89,aR(209),135));
		ret.push(new ActionRule(138,aR(209),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(210),87));
		ret.push(new ActionRule(89,aR(210),135));
		ret.push(new ActionRule(138,aR(210),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(211),87));
		ret.push(new ActionRule(89,aR(211),135));
		ret.push(new ActionRule(138,aR(211),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(212),87));
		ret.push(new ActionRule(89,aR(212),135));
		ret.push(new ActionRule(138,aR(212),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(213),87));
		ret.push(new ActionRule(89,aR(213),135));
		ret.push(new ActionRule(138,aR(213),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(214),87));
		ret.push(new ActionRule(89,aR(214),135));
		ret.push(new ActionRule(138,aR(214),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(215),87));
		ret.push(new ActionRule(89,aR(215),135));
		ret.push(new ActionRule(138,aR(215),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(216),87));
		ret.push(new ActionRule(89,aR(216),135));
		ret.push(new ActionRule(138,aR(216),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(217),87));
		ret.push(new ActionRule(89,aR(217),135));
		ret.push(new ActionRule(138,aR(217),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(218),87));
		ret.push(new ActionRule(89,aR(218),135));
		ret.push(new ActionRule(138,aR(218),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(219),87));
		ret.push(new ActionRule(89,aR(219),135));
		ret.push(new ActionRule(138,aR(219),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(220),87));
		ret.push(new ActionRule(89,aR(220),135));
		ret.push(new ActionRule(138,aR(220),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(221),87));
		ret.push(new ActionRule(89,aR(221),135));
		ret.push(new ActionRule(138,aR(221),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(223),87));
		ret.push(new ActionRule(89,aR(223),135));
		ret.push(new ActionRule(138,aR(223),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(224),87));
		ret.push(new ActionRule(89,aR(224),135));
		ret.push(new ActionRule(138,aR(224),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(222),87));
		ret.push(new ActionRule(89,aR(222),135));
		ret.push(new ActionRule(138,aR(222),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(45,aS(683),true,52));
		ret.push(new ActionRule(171,aG(768)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(45,aS(683),true,52));
		ret.push(new ActionRule(171,aG(777)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(227)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(228)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(229)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(230)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(231)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(232)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(233)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(234)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(286)));
		ret.push(new ActionRule(44,aR(286)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(693)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(239)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(695)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(240)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(702)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(703)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(704)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(705)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(706)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(174,aG(707)));
		ret.push(new ActionRule(176,aG(709)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(303)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(301)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(302)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(385)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(386)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(902)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(708)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(320)));
		ret.push(new ActionRule(139,aR(320),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(319)));
		ret.push(new ActionRule(139,aR(319),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(244)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(245)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(246)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(247)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aR(248)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(730)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(769)));
		ret.push(new ActionRule(186,aG(717)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(4,aR(298)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(770)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(769)));
		ret.push(new ActionRule(186,aG(719)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(4,aR(297)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(770)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(769)));
		ret.push(new ActionRule(186,aG(721)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(722)));
		ret.push(new ActionRule(4,aS(780)));
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(733)));
		ret.push(new ActionRule(178,aG(770)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(139,aS(723),true,142));
		ret.push(new ActionRule(176,aG(682)));
		ret.push(new ActionRule(189,aG(731)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(249),4));
		ret.push(new ActionRule(13,aR(249)));
		ret.push(new ActionRule(45,aR(249),52));
		ret.push(new ActionRule(93,aR(249)));
		ret.push(new ActionRule(139,aR(249),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(250),4));
		ret.push(new ActionRule(13,aR(250)));
		ret.push(new ActionRule(45,aR(250),52));
		ret.push(new ActionRule(93,aR(250)));
		ret.push(new ActionRule(139,aR(250),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(251),4));
		ret.push(new ActionRule(13,aR(251)));
		ret.push(new ActionRule(45,aR(251),52));
		ret.push(new ActionRule(93,aR(251)));
		ret.push(new ActionRule(139,aR(251),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(252),4));
		ret.push(new ActionRule(13,aR(252)));
		ret.push(new ActionRule(45,aR(252),52));
		ret.push(new ActionRule(93,aR(252)));
		ret.push(new ActionRule(139,aR(252),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(783)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(729)));
		ret.push(new ActionRule(177,aG(787)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(6,aS(759),true,7));
		ret.push(new ActionRule(181,aG(715)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(292)));
		ret.push(new ActionRule(93,aR(292)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(732)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(308),4));
		ret.push(new ActionRule(93,aR(308)));
		ret.push(new ActionRule(139,aR(308),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(307),4));
		ret.push(new ActionRule(93,aR(307)));
		ret.push(new ActionRule(139,aR(307),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(268)));
		ret.push(new ActionRule(44,aR(268)));
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
		ret.push(new ActionRule(4,aR(269)));
		ret.push(new ActionRule(44,aR(269)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(280)));
		ret.push(new ActionRule(44,aR(280)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(272)));
		ret.push(new ActionRule(44,aR(272)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(283)));
		ret.push(new ActionRule(44,aR(283)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(284)));
		ret.push(new ActionRule(44,aR(284)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(276)));
		ret.push(new ActionRule(44,aR(276)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(285)));
		ret.push(new ActionRule(44,aR(285)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(274)));
		ret.push(new ActionRule(44,aR(274)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(281)));
		ret.push(new ActionRule(44,aR(281)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(273)));
		ret.push(new ActionRule(44,aR(273)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(270)));
		ret.push(new ActionRule(44,aR(270)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(271)));
		ret.push(new ActionRule(44,aR(271)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(277)));
		ret.push(new ActionRule(44,aR(277)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(275)));
		ret.push(new ActionRule(44,aR(275)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(278)));
		ret.push(new ActionRule(44,aR(278)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(287)));
		ret.push(new ActionRule(44,aR(287)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(288)));
		ret.push(new ActionRule(44,aR(288)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(289)));
		ret.push(new ActionRule(44,aR(289)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(290)));
		ret.push(new ActionRule(44,aR(290)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(291)));
		ret.push(new ActionRule(44,aR(291)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(767)));
		ret.push(new ActionRule(6,aS(759),true,7));
		ret.push(new ActionRule(181,aG(718)));
		ret.push(new ActionRule(185,aG(763)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(767)));
		ret.push(new ActionRule(6,aS(759),true,7));
		ret.push(new ActionRule(181,aG(718)));
		ret.push(new ActionRule(185,aG(765)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(321)));
		ret.push(new ActionRule(139,aR(321),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(322)));
		ret.push(new ActionRule(139,aR(322),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(757)));
		ret.push(new ActionRule(183,aG(762)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(758)));
		ret.push(new ActionRule(4,aR(295)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(764)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(299),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(766)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(300),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(7,aS(681)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(716)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(309),4));
		ret.push(new ActionRule(139,aR(309),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(310),4));
		ret.push(new ActionRule(139,aR(310),142));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(219)));
		ret.push(new ActionRule(5,aS(697)));
		ret.push(new ActionRule(100,aS(698)));
		ret.push(new ActionRule(187,aG(773)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(219)));
		ret.push(new ActionRule(5,aS(697)));
		ret.push(new ActionRule(100,aS(698)));
		ret.push(new ActionRule(187,aG(775)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(774)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(304),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(776)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(305),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(318)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(323)));
		ret.push(new ActionRule(93,aS(779)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(720)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(324)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(727)));
		ret.push(new ActionRule(191,aG(785)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(727)));
		ret.push(new ActionRule(191,aG(786)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(784)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(325),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(728)));
		ret.push(new ActionRule(4,aR(398)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(728)));
		ret.push(new ActionRule(4,aR(405)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(788)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(326),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(335)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(791)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(334)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(793)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(331)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(795)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(332)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(340)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(339)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(337)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(800)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(338)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(802)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(333)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(336)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(345)));
		ret.push(new ActionRule(59,aR(345),60));
		ret.push(new ActionRule(71,aR(345)));
		ret.push(new ActionRule(78,aR(345)));
		ret.push(new ActionRule(80,aR(345),81));
		ret.push(new ActionRule(86,aR(345)));
		ret.push(new ActionRule(102,aR(345),125));
		ret.push(new ActionRule(127,aR(345),132));
		ret.push(new ActionRule(136,aR(345),137));
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
		ret.push(new ActionRule(4,aR(347)));
		ret.push(new ActionRule(59,aR(347),60));
		ret.push(new ActionRule(71,aR(347)));
		ret.push(new ActionRule(78,aR(347)));
		ret.push(new ActionRule(80,aR(347),81));
		ret.push(new ActionRule(86,aR(347)));
		ret.push(new ActionRule(102,aR(347),125));
		ret.push(new ActionRule(127,aR(347),132));
		ret.push(new ActionRule(136,aR(347),137));
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
		ret.push(new ActionRule(4,aR(346)));
		ret.push(new ActionRule(59,aR(346),60));
		ret.push(new ActionRule(71,aR(346)));
		ret.push(new ActionRule(78,aR(346)));
		ret.push(new ActionRule(80,aR(346),81));
		ret.push(new ActionRule(86,aR(346)));
		ret.push(new ActionRule(102,aR(346),125));
		ret.push(new ActionRule(127,aR(346),132));
		ret.push(new ActionRule(136,aR(346),137));
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
		ret.push(new ActionRule(4,aR(349)));
		ret.push(new ActionRule(59,aR(349),60));
		ret.push(new ActionRule(71,aR(349)));
		ret.push(new ActionRule(78,aR(349)));
		ret.push(new ActionRule(80,aR(349),81));
		ret.push(new ActionRule(86,aR(349)));
		ret.push(new ActionRule(102,aR(349),125));
		ret.push(new ActionRule(127,aR(349),132));
		ret.push(new ActionRule(136,aR(349),137));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(343)));
		ret.push(new ActionRule(59,aR(343),60));
		ret.push(new ActionRule(71,aR(343)));
		ret.push(new ActionRule(78,aR(343)));
		ret.push(new ActionRule(80,aR(343),81));
		ret.push(new ActionRule(86,aR(343)));
		ret.push(new ActionRule(102,aR(343),125));
		ret.push(new ActionRule(127,aR(343),132));
		ret.push(new ActionRule(136,aR(343),137));
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
		ret.push(new ActionRule(4,aR(342)));
		ret.push(new ActionRule(59,aR(342),60));
		ret.push(new ActionRule(71,aR(342)));
		ret.push(new ActionRule(78,aR(342)));
		ret.push(new ActionRule(80,aR(342),81));
		ret.push(new ActionRule(86,aR(342)));
		ret.push(new ActionRule(102,aR(342),125));
		ret.push(new ActionRule(127,aR(342),132));
		ret.push(new ActionRule(136,aR(342),137));
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
		ret.push(new ActionRule(4,aR(341)));
		ret.push(new ActionRule(59,aR(341),60));
		ret.push(new ActionRule(71,aR(341)));
		ret.push(new ActionRule(78,aR(341)));
		ret.push(new ActionRule(80,aR(341),81));
		ret.push(new ActionRule(86,aR(341)));
		ret.push(new ActionRule(102,aR(341),125));
		ret.push(new ActionRule(127,aR(341),132));
		ret.push(new ActionRule(136,aR(341),137));
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
		ret.push(new ActionRule(4,aR(344)));
		ret.push(new ActionRule(59,aR(344),60));
		ret.push(new ActionRule(71,aR(344)));
		ret.push(new ActionRule(78,aR(344)));
		ret.push(new ActionRule(80,aR(344),81));
		ret.push(new ActionRule(86,aR(344)));
		ret.push(new ActionRule(102,aR(344),125));
		ret.push(new ActionRule(127,aR(344),132));
		ret.push(new ActionRule(136,aR(344),137));
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
		ret.push(new ActionRule(4,aR(348)));
		ret.push(new ActionRule(59,aR(348),60));
		ret.push(new ActionRule(71,aR(348)));
		ret.push(new ActionRule(78,aR(348)));
		ret.push(new ActionRule(80,aR(348),81));
		ret.push(new ActionRule(86,aR(348)));
		ret.push(new ActionRule(102,aR(348),125));
		ret.push(new ActionRule(127,aR(348),132));
		ret.push(new ActionRule(136,aR(348),137));
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
		ret.push(new ActionRule(3,aS(175)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(846)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(383)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(848)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(382)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(117,aS(851)));
		ret.push(new ActionRule(196,aG(914)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(117,aS(851)));
		ret.push(new ActionRule(196,aG(918)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(852)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(220)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(383)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(855)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(178)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(857)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(384)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(699)));
		ret.push(new ActionRule(100,aS(700)));
		ret.push(new ActionRule(198,aG(861)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(699)));
		ret.push(new ActionRule(100,aS(700)));
		ret.push(new ActionRule(198,aG(864)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(858)));
		ret.push(new ActionRule(199,aG(863)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(862)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(387),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(859)));
		ret.push(new ActionRule(4,aR(397)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(865)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(388),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(878)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(120,aS(961)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(878)));
		ret.push(new ActionRule(203,aG(964)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(955)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(957)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(959)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(962)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(967)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(974)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(59,aS(875)));
		ret.push(new ActionRule(71,aS(876)));
		ret.push(new ActionRule(80,aS(880)));
		ret.push(new ActionRule(81,aS(884)));
		ret.push(new ActionRule(102,aS(892)));
		ret.push(new ActionRule(103,aS(896)));
		ret.push(new ActionRule(105,aS(900)));
		ret.push(new ActionRule(108,aS(903)));
		ret.push(new ActionRule(110,aS(911)));
		ret.push(new ActionRule(115,aS(781)));
		ret.push(new ActionRule(116,aS(920)));
		ret.push(new ActionRule(117,aS(924)));
		ret.push(new ActionRule(121,aS(860)));
		ret.push(new ActionRule(130,aS(927)));
		ret.push(new ActionRule(131,aS(930)));
		ret.push(new ActionRule(132,aS(937)));
		ret.push(new ActionRule(133,aS(940)));
		ret.push(new ActionRule(134,aS(946)));
		ret.push(new ActionRule(137,aS(954)));
		ret.push(new ActionRule(200,aG(977)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(391)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(866)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(867)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(879)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(393)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(881)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(882)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(883)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(392)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(885)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(886)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(887)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(221)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(384)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(406)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(891)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(407)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(222)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(127,aS(894)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(223)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(390)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(869)));
		ret.push(new ActionRule(201,aG(898)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(869)));
		ret.push(new ActionRule(201,aG(899)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(870)));
		ret.push(new ActionRule(4,aR(399)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(870)));
		ret.push(new ActionRule(4,aR(399)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(224)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(701)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(396)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(225)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(905)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(906)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(907)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(908)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(909)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(910)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(408)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(176)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(913)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(849)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(915)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(402)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(917)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(850)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(919)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(403)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(869)));
		ret.push(new ActionRule(201,aG(922)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(869)));
		ret.push(new ActionRule(201,aG(923)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(870)));
		ret.push(new ActionRule(4,aR(400)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(870)));
		ret.push(new ActionRule(4,aR(400)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(925)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(226)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(389)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(338)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(929)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(395)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(931)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(932)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(933)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(934)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(935)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(936)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(404)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(938)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(939)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(782)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(941)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(942)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(2,aS(943)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(944)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(869)));
		ret.push(new ActionRule(201,aG(945)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(870)));
		ret.push(new ActionRule(4,aR(401)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(947)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(948)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(949)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(227)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(951)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(5,aS(952)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(953)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(409)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(868)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(956)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(394)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(958)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(410),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(960)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aR(411),4));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(871)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(963)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(430)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(965)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(432)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(872)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(968)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(431)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(970)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(109,aS(973)));
		ret.push(new ActionRule(124,aS(976)));
		ret.push(new ActionRule(206,aG(971)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(972)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(461)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(873)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(975)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(460)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(3,aS(874)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aS(978)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(4,aR(459)));
		actions.push(ret);
		var ret = [];
		ret.push(new ActionRule(0,aA));
		actions.push(ret);

		rules = new Array<{cb:Array<Dynamic>->Void,sym:Int,cnt:Int}>();
		rules.push({cb:R0, sym:143, cnt:1});
		rules.push({cb:R1, sym:143, cnt:1});
		rules.push({cb:R2, sym:144, cnt:7});
		rules.push({cb:R3, sym:144, cnt:1});
		rules.push({cb:R4, sym:144, cnt:7});
		rules.push({cb:R5, sym:144, cnt:1});
		rules.push({cb:R6, sym:144, cnt:1});
		rules.push({cb:R7, sym:144, cnt:4});
		rules.push({cb:R8, sym:144, cnt:4});
		rules.push({cb:R9, sym:144, cnt:1});
		rules.push({cb:R10, sym:144, cnt:1});
		rules.push({cb:R11, sym:144, cnt:4});
		rules.push({cb:R12, sym:144, cnt:4});
		rules.push({cb:R13, sym:144, cnt:1});
		rules.push({cb:R14, sym:144, cnt:7});
		rules.push({cb:R15, sym:144, cnt:4});
		rules.push({cb:R16, sym:144, cnt:4});
		rules.push({cb:R17, sym:144, cnt:1});
		rules.push({cb:R18, sym:144, cnt:2});
		rules.push({cb:R19, sym:144, cnt:5});
		rules.push({cb:R20, sym:144, cnt:4});
		rules.push({cb:R21, sym:144, cnt:1});
		rules.push({cb:R22, sym:144, cnt:1});
		rules.push({cb:R23, sym:144, cnt:1});
		rules.push({cb:R24, sym:144, cnt:1});
		rules.push({cb:R25, sym:144, cnt:5});
		rules.push({cb:R26, sym:144, cnt:1});
		rules.push({cb:R27, sym:145, cnt:4});
		rules.push({cb:R28, sym:145, cnt:4});
		rules.push({cb:R29, sym:145, cnt:4});
		rules.push({cb:R30, sym:145, cnt:4});
		rules.push({cb:R31, sym:145, cnt:4});
		rules.push({cb:R32, sym:145, cnt:10});
		rules.push({cb:R33, sym:145, cnt:10});
		rules.push({cb:R34, sym:145, cnt:5});
		rules.push({cb:R35, sym:145, cnt:2});
		rules.push({cb:R36, sym:145, cnt:7});
		rules.push({cb:R37, sym:145, cnt:2});
		rules.push({cb:R38, sym:145, cnt:4});
		rules.push({cb:R39, sym:145, cnt:10});
		rules.push({cb:R40, sym:145, cnt:4});
		rules.push({cb:R41, sym:145, cnt:4});
		rules.push({cb:R42, sym:145, cnt:1});
		rules.push({cb:R43, sym:145, cnt:4});
		rules.push({cb:R44, sym:145, cnt:4});
		rules.push({cb:R45, sym:145, cnt:4});
		rules.push({cb:R46, sym:145, cnt:4});
		rules.push({cb:R47, sym:145, cnt:4});
		rules.push({cb:R48, sym:145, cnt:7});
		rules.push({cb:R49, sym:145, cnt:4});
		rules.push({cb:R50, sym:145, cnt:1});
		rules.push({cb:R51, sym:145, cnt:4});
		rules.push({cb:R52, sym:145, cnt:5});
		rules.push({cb:R53, sym:145, cnt:11});
		rules.push({cb:R54, sym:145, cnt:11});
		rules.push({cb:R55, sym:146, cnt:4});
		rules.push({cb:R56, sym:146, cnt:4});
		rules.push({cb:R57, sym:154, cnt:1});
		rules.push({cb:R58, sym:154, cnt:4});
		rules.push({cb:R59, sym:155, cnt:7});
		rules.push({cb:R60, sym:155, cnt:7});
		rules.push({cb:R61, sym:155, cnt:4});
		rules.push({cb:R62, sym:155, cnt:1});
		rules.push({cb:R63, sym:155, cnt:4});
		rules.push({cb:R64, sym:155, cnt:1});
		rules.push({cb:R65, sym:155, cnt:4});
		rules.push({cb:R66, sym:155, cnt:5});
		rules.push({cb:R67, sym:155, cnt:1});
		rules.push({cb:R68, sym:168, cnt:4});
		rules.push({cb:R69, sym:168, cnt:1});
		rules.push({cb:R70, sym:168, cnt:5});
		rules.push({cb:R71, sym:165, cnt:4});
		rules.push({cb:R72, sym:165, cnt:4});
		rules.push({cb:R73, sym:156, cnt:1});
		rules.push({cb:R74, sym:156, cnt:1});
		rules.push({cb:R75, sym:156, cnt:1});
		rules.push({cb:R76, sym:156, cnt:4});
		rules.push({cb:R77, sym:156, cnt:2});
		rules.push({cb:R78, sym:156, cnt:1});
		rules.push({cb:R79, sym:156, cnt:1});
		rules.push({cb:R80, sym:156, cnt:7});
		rules.push({cb:R81, sym:149, cnt:1});
		rules.push({cb:R82, sym:149, cnt:3});
		rules.push({cb:R83, sym:149, cnt:2});
		rules.push({cb:R84, sym:149, cnt:4});
		rules.push({cb:R85, sym:169, cnt:1});
		rules.push({cb:R86, sym:169, cnt:1});
		rules.push({cb:R87, sym:169, cnt:1});
		rules.push({cb:R88, sym:169, cnt:1});
		rules.push({cb:R89, sym:169, cnt:1});
		rules.push({cb:R90, sym:169, cnt:1});
		rules.push({cb:R91, sym:169, cnt:1});
		rules.push({cb:R92, sym:169, cnt:1});
		rules.push({cb:R93, sym:169, cnt:1});
		rules.push({cb:R94, sym:169, cnt:1});
		rules.push({cb:R95, sym:169, cnt:1});
		rules.push({cb:R96, sym:169, cnt:1});
		rules.push({cb:R97, sym:169, cnt:1});
		rules.push({cb:R98, sym:169, cnt:1});
		rules.push({cb:R99, sym:169, cnt:1});
		rules.push({cb:R100, sym:169, cnt:1});
		rules.push({cb:R101, sym:169, cnt:1});
		rules.push({cb:R102, sym:169, cnt:1});
		rules.push({cb:R103, sym:169, cnt:1});
		rules.push({cb:R104, sym:169, cnt:1});
		rules.push({cb:R105, sym:169, cnt:1});
		rules.push({cb:R106, sym:169, cnt:1});
		rules.push({cb:R107, sym:169, cnt:1});
		rules.push({cb:R108, sym:169, cnt:1});
		rules.push({cb:R109, sym:169, cnt:1});
		rules.push({cb:R110, sym:169, cnt:1});
		rules.push({cb:R111, sym:169, cnt:1});
		rules.push({cb:R112, sym:169, cnt:1});
		rules.push({cb:R113, sym:169, cnt:1});
		rules.push({cb:R114, sym:169, cnt:1});
		rules.push({cb:R115, sym:169, cnt:1});
		rules.push({cb:R116, sym:169, cnt:1});
		rules.push({cb:R117, sym:169, cnt:1});
		rules.push({cb:R118, sym:169, cnt:1});
		rules.push({cb:R119, sym:169, cnt:1});
		rules.push({cb:R120, sym:169, cnt:1});
		rules.push({cb:R121, sym:169, cnt:1});
		rules.push({cb:R122, sym:169, cnt:1});
		rules.push({cb:R123, sym:169, cnt:1});
		rules.push({cb:R124, sym:169, cnt:1});
		rules.push({cb:R125, sym:169, cnt:1});
		rules.push({cb:R126, sym:169, cnt:1});
		rules.push({cb:R127, sym:169, cnt:1});
		rules.push({cb:R128, sym:169, cnt:1});
		rules.push({cb:R129, sym:169, cnt:1});
		rules.push({cb:R130, sym:169, cnt:1});
		rules.push({cb:R131, sym:169, cnt:1});
		rules.push({cb:R132, sym:169, cnt:1});
		rules.push({cb:R133, sym:169, cnt:1});
		rules.push({cb:R134, sym:169, cnt:1});
		rules.push({cb:R135, sym:169, cnt:1});
		rules.push({cb:R136, sym:169, cnt:1});
		rules.push({cb:R137, sym:169, cnt:1});
		rules.push({cb:R138, sym:169, cnt:1});
		rules.push({cb:R139, sym:169, cnt:1});
		rules.push({cb:R140, sym:169, cnt:1});
		rules.push({cb:R141, sym:169, cnt:1});
		rules.push({cb:R142, sym:169, cnt:1});
		rules.push({cb:R143, sym:169, cnt:1});
		rules.push({cb:R144, sym:169, cnt:1});
		rules.push({cb:R145, sym:169, cnt:1});
		rules.push({cb:R146, sym:169, cnt:1});
		rules.push({cb:R147, sym:169, cnt:1});
		rules.push({cb:R148, sym:169, cnt:1});
		rules.push({cb:R149, sym:169, cnt:1});
		rules.push({cb:R150, sym:169, cnt:1});
		rules.push({cb:R151, sym:169, cnt:1});
		rules.push({cb:R152, sym:169, cnt:1});
		rules.push({cb:R153, sym:169, cnt:1});
		rules.push({cb:R154, sym:169, cnt:1});
		rules.push({cb:R155, sym:169, cnt:1});
		rules.push({cb:R156, sym:169, cnt:1});
		rules.push({cb:R157, sym:169, cnt:1});
		rules.push({cb:R158, sym:169, cnt:1});
		rules.push({cb:R159, sym:169, cnt:1});
		rules.push({cb:R160, sym:169, cnt:1});
		rules.push({cb:R161, sym:169, cnt:1});
		rules.push({cb:R162, sym:169, cnt:1});
		rules.push({cb:R163, sym:169, cnt:1});
		rules.push({cb:R164, sym:169, cnt:1});
		rules.push({cb:R165, sym:169, cnt:1});
		rules.push({cb:R166, sym:169, cnt:1});
		rules.push({cb:R167, sym:169, cnt:1});
		rules.push({cb:R168, sym:169, cnt:1});
		rules.push({cb:R169, sym:169, cnt:1});
		rules.push({cb:R170, sym:169, cnt:1});
		rules.push({cb:R171, sym:169, cnt:1});
		rules.push({cb:R172, sym:169, cnt:1});
		rules.push({cb:R173, sym:169, cnt:1});
		rules.push({cb:R174, sym:169, cnt:1});
		rules.push({cb:R175, sym:169, cnt:1});
		rules.push({cb:R176, sym:169, cnt:1});
		rules.push({cb:R177, sym:169, cnt:1});
		rules.push({cb:R178, sym:169, cnt:1});
		rules.push({cb:R179, sym:169, cnt:1});
		rules.push({cb:R180, sym:169, cnt:1});
		rules.push({cb:R181, sym:169, cnt:1});
		rules.push({cb:R182, sym:169, cnt:1});
		rules.push({cb:R183, sym:169, cnt:1});
		rules.push({cb:R184, sym:169, cnt:1});
		rules.push({cb:R185, sym:169, cnt:1});
		rules.push({cb:R186, sym:169, cnt:1});
		rules.push({cb:R187, sym:169, cnt:1});
		rules.push({cb:R188, sym:169, cnt:1});
		rules.push({cb:R189, sym:169, cnt:1});
		rules.push({cb:R190, sym:169, cnt:1});
		rules.push({cb:R191, sym:169, cnt:1});
		rules.push({cb:R192, sym:169, cnt:1});
		rules.push({cb:R193, sym:169, cnt:1});
		rules.push({cb:R194, sym:169, cnt:1});
		rules.push({cb:R195, sym:169, cnt:1});
		rules.push({cb:R196, sym:169, cnt:1});
		rules.push({cb:R197, sym:169, cnt:1});
		rules.push({cb:R198, sym:169, cnt:1});
		rules.push({cb:R199, sym:169, cnt:1});
		rules.push({cb:R200, sym:169, cnt:1});
		rules.push({cb:R201, sym:169, cnt:1});
		rules.push({cb:R202, sym:169, cnt:1});
		rules.push({cb:R203, sym:169, cnt:1});
		rules.push({cb:R204, sym:169, cnt:1});
		rules.push({cb:R205, sym:169, cnt:1});
		rules.push({cb:R206, sym:169, cnt:1});
		rules.push({cb:R207, sym:169, cnt:1});
		rules.push({cb:R208, sym:169, cnt:1});
		rules.push({cb:R209, sym:169, cnt:1});
		rules.push({cb:R210, sym:169, cnt:1});
		rules.push({cb:R211, sym:169, cnt:1});
		rules.push({cb:R212, sym:169, cnt:1});
		rules.push({cb:R213, sym:169, cnt:1});
		rules.push({cb:R214, sym:169, cnt:1});
		rules.push({cb:R215, sym:169, cnt:1});
		rules.push({cb:R216, sym:169, cnt:1});
		rules.push({cb:R217, sym:169, cnt:1});
		rules.push({cb:R218, sym:169, cnt:1});
		rules.push({cb:R219, sym:169, cnt:1});
		rules.push({cb:R220, sym:169, cnt:1});
		rules.push({cb:R221, sym:169, cnt:1});
		rules.push({cb:R222, sym:170, cnt:1});
		rules.push({cb:R223, sym:170, cnt:1});
		rules.push({cb:R224, sym:170, cnt:1});
		rules.push({cb:R225, sym:148, cnt:1});
		rules.push({cb:R226, sym:148, cnt:2});
		rules.push({cb:R227, sym:171, cnt:1});
		rules.push({cb:R228, sym:171, cnt:1});
		rules.push({cb:R229, sym:171, cnt:1});
		rules.push({cb:R230, sym:171, cnt:1});
		rules.push({cb:R231, sym:171, cnt:1});
		rules.push({cb:R232, sym:171, cnt:1});
		rules.push({cb:R233, sym:171, cnt:1});
		rules.push({cb:R234, sym:171, cnt:1});
		rules.push({cb:R235, sym:164, cnt:1});
		rules.push({cb:R236, sym:164, cnt:1});
		rules.push({cb:R237, sym:164, cnt:2});
		rules.push({cb:R238, sym:164, cnt:2});
		rules.push({cb:R239, sym:173, cnt:2});
		rules.push({cb:R240, sym:173, cnt:2});
		rules.push({cb:R241, sym:161, cnt:3});
		rules.push({cb:R242, sym:161, cnt:4});
		rules.push({cb:R243, sym:147, cnt:2});
		rules.push({cb:R244, sym:175, cnt:1});
		rules.push({cb:R245, sym:175, cnt:1});
		rules.push({cb:R246, sym:175, cnt:1});
		rules.push({cb:R247, sym:175, cnt:1});
		rules.push({cb:R248, sym:175, cnt:1});
		rules.push({cb:R249, sym:176, cnt:1});
		rules.push({cb:R250, sym:176, cnt:1});
		rules.push({cb:R251, sym:176, cnt:1});
		rules.push({cb:R252, sym:176, cnt:1});
		rules.push({cb:R253, sym:152, cnt:1});
		rules.push({cb:R254, sym:152, cnt:2});
		rules.push({cb:R255, sym:162, cnt:4});
		rules.push({cb:R256, sym:162, cnt:4});
		rules.push({cb:R257, sym:162, cnt:4});
		rules.push({cb:R258, sym:162, cnt:4});
		rules.push({cb:R259, sym:162, cnt:5});
		rules.push({cb:R260, sym:162, cnt:5});
		rules.push({cb:R261, sym:162, cnt:7});
		rules.push({cb:R262, sym:162, cnt:9});
		rules.push({cb:R263, sym:162, cnt:9});
		rules.push({cb:R264, sym:162, cnt:9});
		rules.push({cb:R265, sym:150, cnt:3});
		rules.push({cb:R266, sym:150, cnt:4});
		rules.push({cb:R267, sym:163, cnt:1});
		rules.push({cb:R268, sym:179, cnt:1});
		rules.push({cb:R269, sym:179, cnt:1});
		rules.push({cb:R270, sym:179, cnt:1});
		rules.push({cb:R271, sym:179, cnt:1});
		rules.push({cb:R272, sym:179, cnt:1});
		rules.push({cb:R273, sym:179, cnt:1});
		rules.push({cb:R274, sym:179, cnt:1});
		rules.push({cb:R275, sym:179, cnt:1});
		rules.push({cb:R276, sym:179, cnt:1});
		rules.push({cb:R277, sym:179, cnt:1});
		rules.push({cb:R278, sym:179, cnt:1});
		rules.push({cb:R279, sym:179, cnt:1});
		rules.push({cb:R280, sym:179, cnt:1});
		rules.push({cb:R281, sym:179, cnt:1});
		rules.push({cb:R282, sym:179, cnt:1});
		rules.push({cb:R283, sym:179, cnt:1});
		rules.push({cb:R284, sym:179, cnt:1});
		rules.push({cb:R285, sym:179, cnt:1});
		rules.push({cb:R286, sym:172, cnt:1});
		rules.push({cb:R287, sym:180, cnt:1});
		rules.push({cb:R288, sym:180, cnt:1});
		rules.push({cb:R289, sym:180, cnt:1});
		rules.push({cb:R290, sym:180, cnt:1});
		rules.push({cb:R291, sym:180, cnt:1});
		rules.push({cb:R292, sym:177, cnt:3});
		rules.push({cb:R293, sym:158, cnt:3});
		rules.push({cb:R294, sym:158, cnt:4});
		rules.push({cb:R295, sym:182, cnt:2});
		rules.push({cb:R296, sym:184, cnt:2});
		rules.push({cb:R297, sym:185, cnt:2});
		rules.push({cb:R298, sym:185, cnt:5});
		rules.push({cb:R299, sym:183, cnt:3});
		rules.push({cb:R300, sym:183, cnt:4});
		rules.push({cb:R301, sym:187, cnt:2});
		rules.push({cb:R302, sym:187, cnt:2});
		rules.push({cb:R303, sym:187, cnt:4});
		rules.push({cb:R304, sym:188, cnt:3});
		rules.push({cb:R305, sym:188, cnt:4});
		rules.push({cb:R306, sym:157, cnt:6});
		rules.push({cb:R307, sym:178, cnt:1});
		rules.push({cb:R308, sym:178, cnt:3});
		rules.push({cb:R309, sym:186, cnt:1});
		rules.push({cb:R310, sym:186, cnt:2});
		rules.push({cb:R311, sym:151, cnt:4});
		rules.push({cb:R312, sym:151, cnt:1});
		rules.push({cb:R313, sym:151, cnt:1});
		rules.push({cb:R314, sym:151, cnt:1});
		rules.push({cb:R315, sym:151, cnt:5});
		rules.push({cb:R316, sym:151, cnt:1});
		rules.push({cb:R317, sym:151, cnt:4});
		rules.push({cb:R318, sym:189, cnt:2});
		rules.push({cb:R319, sym:174, cnt:1});
		rules.push({cb:R320, sym:174, cnt:2});
		rules.push({cb:R321, sym:181, cnt:1});
		rules.push({cb:R322, sym:181, cnt:1});
		rules.push({cb:R323, sym:190, cnt:1});
		rules.push({cb:R324, sym:190, cnt:5});
		rules.push({cb:R325, sym:191, cnt:3});
		rules.push({cb:R326, sym:191, cnt:4});
		rules.push({cb:R327, sym:160, cnt:3});
		rules.push({cb:R328, sym:160, cnt:4});
		rules.push({cb:R329, sym:159, cnt:3});
		rules.push({cb:R330, sym:159, cnt:4});
		rules.push({cb:R331, sym:192, cnt:2});
		rules.push({cb:R332, sym:192, cnt:2});
		rules.push({cb:R333, sym:192, cnt:2});
		rules.push({cb:R334, sym:192, cnt:2});
		rules.push({cb:R335, sym:192, cnt:1});
		rules.push({cb:R336, sym:192, cnt:1});
		rules.push({cb:R337, sym:192, cnt:1});
		rules.push({cb:R338, sym:192, cnt:2});
		rules.push({cb:R339, sym:192, cnt:1});
		rules.push({cb:R340, sym:192, cnt:1});
		rules.push({cb:R341, sym:193, cnt:1});
		rules.push({cb:R342, sym:193, cnt:1});
		rules.push({cb:R343, sym:193, cnt:1});
		rules.push({cb:R344, sym:193, cnt:1});
		rules.push({cb:R345, sym:193, cnt:1});
		rules.push({cb:R346, sym:193, cnt:1});
		rules.push({cb:R347, sym:193, cnt:1});
		rules.push({cb:R348, sym:193, cnt:1});
		rules.push({cb:R349, sym:193, cnt:1});
		rules.push({cb:R350, sym:193, cnt:1});
		rules.push({cb:R351, sym:193, cnt:1});
		rules.push({cb:R352, sym:193, cnt:1});
		rules.push({cb:R353, sym:193, cnt:1});
		rules.push({cb:R354, sym:193, cnt:1});
		rules.push({cb:R355, sym:193, cnt:1});
		rules.push({cb:R356, sym:193, cnt:1});
		rules.push({cb:R357, sym:193, cnt:1});
		rules.push({cb:R358, sym:193, cnt:1});
		rules.push({cb:R359, sym:193, cnt:1});
		rules.push({cb:R360, sym:193, cnt:1});
		rules.push({cb:R361, sym:193, cnt:1});
		rules.push({cb:R362, sym:193, cnt:1});
		rules.push({cb:R363, sym:193, cnt:1});
		rules.push({cb:R364, sym:193, cnt:1});
		rules.push({cb:R365, sym:193, cnt:1});
		rules.push({cb:R366, sym:193, cnt:1});
		rules.push({cb:R367, sym:193, cnt:1});
		rules.push({cb:R368, sym:193, cnt:1});
		rules.push({cb:R369, sym:193, cnt:1});
		rules.push({cb:R370, sym:193, cnt:1});
		rules.push({cb:R371, sym:193, cnt:1});
		rules.push({cb:R372, sym:193, cnt:1});
		rules.push({cb:R373, sym:193, cnt:1});
		rules.push({cb:R374, sym:193, cnt:1});
		rules.push({cb:R375, sym:193, cnt:1});
		rules.push({cb:R376, sym:193, cnt:1});
		rules.push({cb:R377, sym:193, cnt:1});
		rules.push({cb:R378, sym:193, cnt:1});
		rules.push({cb:R379, sym:193, cnt:1});
		rules.push({cb:R380, sym:194, cnt:0});
		rules.push({cb:R381, sym:194, cnt:2});
		rules.push({cb:R382, sym:195, cnt:7});
		rules.push({cb:R383, sym:196, cnt:5});
		rules.push({cb:R384, sym:197, cnt:6});
		rules.push({cb:R385, sym:198, cnt:2});
		rules.push({cb:R386, sym:198, cnt:2});
		rules.push({cb:R387, sym:199, cnt:3});
		rules.push({cb:R388, sym:199, cnt:4});
		rules.push({cb:R389, sym:200, cnt:5});
		rules.push({cb:R390, sym:200, cnt:8});
		rules.push({cb:R391, sym:200, cnt:1});
		rules.push({cb:R392, sym:200, cnt:4});
		rules.push({cb:R393, sym:200, cnt:4});
		rules.push({cb:R394, sym:200, cnt:4});
		rules.push({cb:R395, sym:200, cnt:4});
		rules.push({cb:R396, sym:200, cnt:7});
		rules.push({cb:R397, sym:200, cnt:2});
		rules.push({cb:R398, sym:200, cnt:2});
		rules.push({cb:R399, sym:200, cnt:2});
		rules.push({cb:R400, sym:200, cnt:2});
		rules.push({cb:R401, sym:200, cnt:6});
		rules.push({cb:R402, sym:200, cnt:7});
		rules.push({cb:R403, sym:200, cnt:7});
		rules.push({cb:R404, sym:200, cnt:7});
		rules.push({cb:R405, sym:200, cnt:5});
		rules.push({cb:R406, sym:200, cnt:10});
		rules.push({cb:R407, sym:200, cnt:10});
		rules.push({cb:R408, sym:200, cnt:10});
		rules.push({cb:R409, sym:200, cnt:10});
		rules.push({cb:R410, sym:201, cnt:3});
		rules.push({cb:R411, sym:201, cnt:4});
		rules.push({cb:R412, sym:166, cnt:4});
		rules.push({cb:R413, sym:166, cnt:4});
		rules.push({cb:R414, sym:166, cnt:4});
		rules.push({cb:R415, sym:166, cnt:4});
		rules.push({cb:R416, sym:166, cnt:4});
		rules.push({cb:R417, sym:166, cnt:4});
		rules.push({cb:R418, sym:166, cnt:4});
		rules.push({cb:R419, sym:166, cnt:4});
		rules.push({cb:R420, sym:166, cnt:4});
		rules.push({cb:R421, sym:166, cnt:4});
		rules.push({cb:R422, sym:166, cnt:4});
		rules.push({cb:R423, sym:166, cnt:4});
		rules.push({cb:R424, sym:166, cnt:7});
		rules.push({cb:R425, sym:166, cnt:8});
		rules.push({cb:R426, sym:166, cnt:12});
		rules.push({cb:R427, sym:166, cnt:11});
		rules.push({cb:R428, sym:166, cnt:11});
		rules.push({cb:R429, sym:166, cnt:1});
		rules.push({cb:R430, sym:203, cnt:4});
		rules.push({cb:R431, sym:204, cnt:4});
		rules.push({cb:R432, sym:204, cnt:4});
		rules.push({cb:R433, sym:202, cnt:2});
		rules.push({cb:R434, sym:202, cnt:2});
		rules.push({cb:R435, sym:167, cnt:4});
		rules.push({cb:R436, sym:167, cnt:4});
		rules.push({cb:R437, sym:167, cnt:4});
		rules.push({cb:R438, sym:167, cnt:4});
		rules.push({cb:R439, sym:167, cnt:4});
		rules.push({cb:R440, sym:167, cnt:4});
		rules.push({cb:R441, sym:167, cnt:4});
		rules.push({cb:R442, sym:167, cnt:4});
		rules.push({cb:R443, sym:167, cnt:4});
		rules.push({cb:R444, sym:167, cnt:4});
		rules.push({cb:R445, sym:167, cnt:4});
		rules.push({cb:R446, sym:167, cnt:7});
		rules.push({cb:R447, sym:167, cnt:7});
		rules.push({cb:R448, sym:167, cnt:7});
		rules.push({cb:R449, sym:167, cnt:4});
		rules.push({cb:R450, sym:167, cnt:4});
		rules.push({cb:R451, sym:167, cnt:7});
		rules.push({cb:R452, sym:167, cnt:7});
		rules.push({cb:R453, sym:167, cnt:7});
		rules.push({cb:R454, sym:167, cnt:1});
		rules.push({cb:R455, sym:153, cnt:7});
		rules.push({cb:R456, sym:153, cnt:7});
		rules.push({cb:R457, sym:153, cnt:10});
		rules.push({cb:R458, sym:153, cnt:10});
		rules.push({cb:R459, sym:206, cnt:4});
		rules.push({cb:R460, sym:206, cnt:4});
		rules.push({cb:R461, sym:205, cnt:4});
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
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R1(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R2(ret:Array<Dynamic>) {
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
	private static inline function R3(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mObserver; });
		ret.push(retret);
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
		var retret: Message  = ({ mIAm(TU.power(hllr__2),TU.integer(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R5(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(null); });
		ret.push(retret);
	}
	private static inline function R6(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMapDefinition(null,null,null); });
		ret.push(retret);
	}
	private static inline function R7(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R8(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R9(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(null,null); });
		ret.push(retret);
	}
	private static inline function R10(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(null); });
		ret.push(retret);
	}
	private static inline function R11(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHistory(hllr__2); });
		ret.push(retret);
	}
	private static inline function R12(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R13(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R14(ret:Array<Dynamic>) {
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
	private static inline function R15(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mBadBrackets(hllr__2); });
		ret.push(retret);
	}
	private static inline function R16(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHuh(hllr__2); });
		ret.push(retret);
	}
	private static inline function R17(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(null,null,null); });
		ret.push(retret);
	}
	private static inline function R18(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MsgOrder>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R19(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<MsgOrder>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(hllr__2,hllr__4); });
		ret.push(retret);
	}
	private static inline function R20(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R21(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders(null,null); });
		ret.push(retret);
	}
	private static inline function R22(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R23(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mOrderResult(null,null,null); });
		ret.push(retret);
	}
	private static inline function R24(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R25(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R26(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R27(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R28(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mAccept(hllr__2); });
		ret.push(retret);
	}
	private static inline function R29(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R30(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mReject(hllr__2); });
		ret.push(retret);
	}
	private static inline function R31(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R32(ret:Array<Dynamic>) {
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
	private static inline function R33(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__9:Token = ret.pop();
var hllr__8: Variant  = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(TU.power(hllr__2),TU.integer(hllr__5),hllr__8); });
		ret.push(retret);
	}
	private static inline function R34(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<UnitWithLocAndMRT>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(hllr__2,hllr__4); });
		ret.push(retret);
	}
	private static inline function R35(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<ScoEntry>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(hllr__1); });
		ret.push(retret);
	}
	private static inline function R36(ret:Array<Dynamic>) {
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
	private static inline function R37(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<UnitWithLocAndMRT>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R38(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMissingOrders(TU.integer(hllr__2),null); });
		ret.push(retret);
	}
	private static inline function R39(ret:Array<Dynamic>) {
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
	private static inline function R40(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSaveGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R41(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mLoadGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R42(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTurnOff; });
		ret.push(retret);
	}
	private static inline function R43(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R44(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mBadBrackets(hllr__2); });
		ret.push(retret);
	}
	private static inline function R45(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHuh(hllr__2); });
		ret.push(retret);
	}
	private static inline function R46(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerDisorder(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R47(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R48(ret:Array<Dynamic>) {
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
	private static inline function R49(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSolo(TU.integer(hllr__2));  });
		ret.push(retret);
	}
	private static inline function R50(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R51(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerEliminated(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R52(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R53(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: PressMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mFrom(TU.power(hllr__2),TU.integer(hllr__3),hllr__6,hllr__9,null); });
		ret.push(retret);
	}
	private static inline function R54(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: ReplyMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mFrom(TU.power(hllr__2),TU.integer(hllr__3),hllr__6,null,hllr__9); });
		ret.push(retret);
	}
	private static inline function R55(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mMap(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R56(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSaveGame(TU.text(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R57(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mObserver; });
		ret.push(retret);
	}
	private static inline function R58(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(mTimeToDeadline(null)); });
		ret.push(retret);
	}
	private static inline function R59(ret:Array<Dynamic>) {
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
	private static inline function R60(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__6:Token = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mIAm(TU.power(hllr__2),TU.integer(hllr__5)); });
		ret.push(retret);
	}
	private static inline function R61(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(mGoFlag); });
		ret.push(retret);
	}
	private static inline function R62(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R63(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R64(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R65(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Message  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R66(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R67(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R68(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R69(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R70(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R71(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R72(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mPowerDisorder(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R73(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHello(null,null,null); });
		ret.push(retret);
	}
	private static inline function R74(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mCurrentLocation(null,null); });
		ret.push(retret);
	}
	private static inline function R75(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSupplyOwnership(null); });
		ret.push(retret);
	}
	private static inline function R76(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Turn  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mHistory(hllr__2); });
		ret.push(retret);
	}
	private static inline function R77(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MsgOrder>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,hllr__1); });
		ret.push(retret);
	}
	private static inline function R78(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mOrderResult(null,null,null); });
		ret.push(retret);
	}
	private static inline function R79(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R80(ret:Array<Dynamic>) {
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
	private static inline function R81(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Array<Token>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R82(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Array<Token>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<Token>  = ({ hllr__1.unshift(hllr__0); hllr__1.push(hllr__2); hllr__1; });
		ret.push(retret);
	}
	private static inline function R83(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R84(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0 = hllr__0.concat(hllr__2); hllr__0.push(hllr__3); hllr__0; });
		ret.push(retret);
	}
	private static inline function R85(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R86(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R87(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R88(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R89(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R90(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R91(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R92(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R93(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
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
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Array<Token>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R226(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R227(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R228(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R229(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R230(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R231(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R232(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R233(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R234(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ TU.coast(hllr__0); });
		ret.push(retret);
	}
	private static inline function R235(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: OrderNote  = ret.pop();
		var retret: CompOrderResult  = ({ { note:hllr__0, result:null, ret:false }; });
		ret.push(retret);
	}
	private static inline function R236(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Result  = ret.pop();
		var retret: CompOrderResult  = ({ { note:null, result:hllr__0, ret:false }; });
		ret.push(retret);
	}
	private static inline function R237(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: OrderNote  = ret.pop();
		var retret: CompOrderResult  = ({ { note:hllr__0, result:null, ret:true }; });
		ret.push(retret);
	}
	private static inline function R238(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: Result  = ret.pop();
		var retret: CompOrderResult  = ({ { note:null, result:hllr__0, ret:true }; });
		ret.push(retret);
	}
	private static inline function R239(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScoEntry  = ({ { power : TU.power(hllr__0), locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R240(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScoEntry  = ({ { power : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R241(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: ScoEntry  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<ScoEntry>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R242(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ScoEntry  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<ScoEntry>  = ret.pop();
		var retret: Array<ScoEntry>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R243(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: Phase  = ret.pop();
		var retret: Turn  = ({ { phase : hllr__0, turn : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R244(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R245(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R246(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R247(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R248(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Phase  = ({ TU.phase(hllr__0); });
		ret.push(retret);
	}
	private static inline function R249(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R250(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R251(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R252(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Province  = ({ TU.province(hllr__0); });
		ret.push(retret);
	}
	private static inline function R253(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Array<Int>  = ({ [TU.power(hllr__0)]; });
		ret.push(retret);
	}
	private static inline function R254(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0: Array<Int>  = ret.pop();
		var retret: Array<Int>  = ({ hllr__0.push(TU.power(hllr__1)); hllr__0; });
		ret.push(retret);
	}
	private static inline function R255(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moHold(hllr__1); });
		ret.push(retret);
	}
	private static inline function R256(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moDisband(hllr__1); });
		ret.push(retret);
	}
	private static inline function R257(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moBuild(hllr__1); });
		ret.push(retret);
	}
	private static inline function R258(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moRemove(hllr__1); });
		ret.push(retret);
	}
	private static inline function R259(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Location  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moRetreat(hllr__1,hllr__4); });
		ret.push(retret);
	}
	private static inline function R260(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Location  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MsgOrder  = ({ moMove(hllr__1,hllr__4); });
		ret.push(retret);
	}
	private static inline function R261(ret:Array<Dynamic>) {
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
	private static inline function R262(ret:Array<Dynamic>) {
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
	private static inline function R263(ret:Array<Dynamic>) {
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
	private static inline function R264(ret:Array<Dynamic>) {
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
	private static inline function R265(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MsgOrder  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MsgOrder>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R266(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MsgOrder>  = ret.pop();
		var retret: Array<MsgOrder>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R267(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: OrderNote  = ({ switch(cast(hllr__0,Token)) { case tOrderNote(x): x; default : null; } });
		ret.push(retret);
	}
	private static inline function R268(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R269(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R270(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R271(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R272(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R273(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R274(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R275(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R276(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
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
		//assign arguments.
var hllr__0: Token  = ret.pop();
		var retret: Result  = ({ switch(cast(hllr__0,Token)) { case tResult(x): x; default : null; } });
		ret.push(retret);
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
		//assign arguments.
var hllr__2: Location  = ret.pop();
var hllr__1: UnitType  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: UnitWithLoc  = ({ { power : TU.power(hllr__0), type : hllr__1, location : hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R293(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfProAdjacencies  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfProAdjacencies>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R294(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfProAdjacencies  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfProAdjacencies>  = ret.pop();
		var retret: Array<MdfProAdjacencies>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R295(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<MdfCoastAdjacencies>  = ret.pop();
var hllr__0: Province  = ret.pop();
		var retret: MdfProAdjacencies  = ({ { pro : hllr__0, coasts : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R296(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Coast  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Coast  = ({ hllr__1; });
		ret.push(retret);
	}
	private static inline function R297(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Location>  = ret.pop();
var hllr__0: UnitType  = ret.pop();
		var retret: MdfCoastAdjacencies  = ({ { unit : hllr__0, coast : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R298(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<Location>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2: Coast  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCoastAdjacencies  = ({ { unit : TU.unitType(hllr__1), coast : hllr__2, locs : hllr__4 }; });
		ret.push(retret);
	}
	private static inline function R299(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfCoastAdjacencies  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfCoastAdjacencies>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R300(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfCoastAdjacencies  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfCoastAdjacencies>  = ret.pop();
		var retret: Array<MdfCoastAdjacencies>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R301(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: [TU.power(hllr__0)], locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R302(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: [], locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R303(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3: Array<Province>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1: Array<Int>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: MdfCentreList  = ({ { powers: hllr__1, locs : hllr__3 }; });
		ret.push(retret);
	}
	private static inline function R304(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: MdfCentreList  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<MdfCentreList>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R305(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MdfCentreList  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<MdfCentreList>  = ret.pop();
		var retret: Array<MdfCentreList>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R306(ret:Array<Dynamic>) {
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
	private static inline function R307(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Province  = ret.pop();
		var retret: Location  = ({ { province : hllr__0, coast : null }; });
		ret.push(retret);
	}
	private static inline function R308(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Location  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Location  = ({ hllr__1; });
		ret.push(retret);
	}
	private static inline function R309(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Location  = ret.pop();
		var retret: Array<Location>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R310(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Location  = ret.pop();
var hllr__0: Array<Location>  = ret.pop();
		var retret: Array<Location>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R311(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,cast [hllr__2]); });
		ret.push(retret);
	}
	private static inline function R312(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mSubmit(null,null); });
		ret.push(retret);
	}
	private static inline function R313(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mGoFlag; });
		ret.push(retret);
	}
	private static inline function R314(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mDraw(null); });
		ret.push(retret);
	}
	private static inline function R315(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ hllr__3.unshift(TU.power(hllr__2)); mDraw(hllr__3); });
		ret.push(retret);
	}
	private static inline function R316(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(null); });
		ret.push(retret);
	}
	private static inline function R317(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Message  = ({ mTimeToDeadline(TU.integer(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R318(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Coast  = ret.pop();
var hllr__0: Province  = ret.pop();
		var retret: Location  = ({ { province : hllr__0, coast : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R319(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: Province  = ret.pop();
		var retret: Array<Province>  = ({ [hllr__0]; });
		ret.push(retret);
	}
	private static inline function R320(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Province  = ret.pop();
var hllr__0: Array<Province>  = ret.pop();
		var retret: Array<Province>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R321(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: UnitType  = ({ TU.unitType(hllr__0); });
		ret.push(retret);
	}
	private static inline function R322(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: UnitType  = ({ TU.unitType(hllr__0); });
		ret.push(retret);
	}
	private static inline function R323(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: UnitWithLoc  = ret.pop();
		var retret: UnitWithLocAndMRT  = ({ { unitloc : hllr__0, locs : null }; });
		ret.push(retret);
	}
	private static inline function R324(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Location>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: UnitWithLoc  = ret.pop();
		var retret: UnitWithLocAndMRT  = ({ { unitloc : hllr__0, locs : hllr__3 }; });
		ret.push(retret);
	}
	private static inline function R325(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLoc  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<UnitWithLoc>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R326(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLoc  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<UnitWithLoc>  = ret.pop();
		var retret: Array<UnitWithLoc>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R327(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: UnitWithLocAndMRT  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<UnitWithLocAndMRT>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R328(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLocAndMRT  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<UnitWithLocAndMRT>  = ret.pop();
		var retret: Array<UnitWithLocAndMRT>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R329(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: VariantOption  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Variant  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R330(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: VariantOption  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Variant  = ret.pop();
		var retret: Variant  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R331(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R332(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R333(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R334(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R335(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R336(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R337(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R338(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : TU.integer(hllr__1) }; });
		ret.push(retret);
	}
	private static inline function R339(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R340(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: VariantOption  = ({ { par : TU.parameter(hllr__0), val : null           }; });
		ret.push(retret);
	}
	private static inline function R341(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R342(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R343(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R344(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R345(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R346(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R347(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R348(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
	}
	private static inline function R349(ret:Array<Dynamic>) {
		//default action. (do nothing in particular)
		// --> keep on stack <-- ret.pop();
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
		//assign arguments.
		var retret: Array<Token>  = ({ []; });
		ret.push(retret);
	}
	private static inline function R381(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Token  = ret.pop();
var hllr__0: Array<Token>  = ret.pop();
		var retret: Array<Token>  = ({ hllr__0.push(hllr__1); hllr__0; });
		ret.push(retret);
	}
	private static inline function R382(ret:Array<Dynamic>) {
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
	private static inline function R383(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: FutureOffer  = ({ hllr__3.unshift(TU.power(hllr__2)); hllr__3; });
		ret.push(retret);
	}
	private static inline function R384(ret:Array<Dynamic>) {
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
	private static inline function R385(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScOwnershipList  = ({ { power : TU.power(hllr__0), locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R386(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Province>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ScOwnershipList  = ({ { power : null, locs : hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R387(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: ScOwnershipList  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<ScOwnershipList>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R388(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ScOwnershipList  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<ScOwnershipList>  = ret.pop();
		var retret: Array<ScOwnershipList>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R389(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4:Token = ret.pop();
var hllr__3: Array<Int>  = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ hllr__3.unshift(TU.power(hllr__2)); arPeace(hllr__3); });
		ret.push(retret);
	}
	private static inline function R390(ret:Array<Dynamic>) {
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
	private static inline function R391(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arDraw; });
		ret.push(retret);
	}
	private static inline function R392(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSolo(TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R393(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R394(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arNAR(hllr__2); });
		ret.push(retret);
	}
	private static inline function R395(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: MsgOrder  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arXDo(hllr__2); });
		ret.push(retret);
	}
	private static inline function R396(ret:Array<Dynamic>) {
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
	private static inline function R397(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<ScOwnershipList>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arSCD(hllr__1); });
		ret.push(retret);
	}
	private static inline function R398(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<UnitWithLoc>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arOCC(hllr__1); });
		ret.push(retret);
	}
	private static inline function R399(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arAND(hllr__1); });
		ret.push(retret);
	}
	private static inline function R400(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arOR(hllr__1); });
		ret.push(retret);
	}
	private static inline function R401(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__5: Array<Arrangement>  = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arCHO(TU.integer(hllr__2),TU.integer(hllr__3),hllr__5); });
		ret.push(retret);
	}
	private static inline function R402(ret:Array<Dynamic>) {
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
	private static inline function R403(ret:Array<Dynamic>) {
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
	private static inline function R404(ret:Array<Dynamic>) {
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
	private static inline function R405(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__4: Array<UnitWithLoc>  = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ arYDO(TU.power(hllr__2),hllr__4); });
		ret.push(retret);
	}
	private static inline function R406(ret:Array<Dynamic>) {
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
	private static inline function R407(ret:Array<Dynamic>) {
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
	private static inline function R408(ret:Array<Dynamic>) {
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
	private static inline function R409(ret:Array<Dynamic>) {
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
	private static inline function R410(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__2:Token = ret.pop();
var hllr__1: Arrangement  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Array<Arrangement>  = ({ [hllr__1]; });
		ret.push(retret);
	}
	private static inline function R411(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0: Array<Arrangement>  = ret.pop();
		var retret: Array<Arrangement>  = ({ hllr__0.push(hllr__2); hllr__0; });
		ret.push(retret);
	}
	private static inline function R412(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmPRP(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R413(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmTRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R414(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmCCL(hllr__2); });
		ret.push(retret);
	}
	private static inline function R415(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: LogicalOp  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmPRP(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R416(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmINS(hllr__2); });
		ret.push(retret);
	}
	private static inline function R417(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmQRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R418(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmSUG(hllr__2); });
		ret.push(retret);
	}
	private static inline function R419(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmTHK(hllr__2); });
		ret.push(retret);
	}
	private static inline function R420(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFCT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R421(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: UnitWithLoc  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmWHT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R422(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Province  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmHOW(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R423(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmHOW(null,TU.power(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R424(ret:Array<Dynamic>) {
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
	private static inline function R425(ret:Array<Dynamic>) {
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
	private static inline function R426(ret:Array<Dynamic>) {
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
	private static inline function R427(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: PressMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFRM(TU.power(hllr__2),TU.integer(hllr__3),hllr__6,hllr__9,null); });
		ret.push(retret);
	}
	private static inline function R428(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__10:Token = ret.pop();
var hllr__9: ReplyMsg  = ret.pop();
var hllr__8:Token = ret.pop();
var hllr__7:Token = ret.pop();
var hllr__6: Array<Int>  = ret.pop();
var hllr__5:Token = ret.pop();
var hllr__4:Token = ret.pop();
var hllr__3:Token = ret.pop();
var hllr__2:Token = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmFRM(TU.power(hllr__2), TU.integer(hllr__3), hllr__6, null, hllr__9); });
		ret.push(retret);
	}
	private static inline function R429(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0:Token = ret.pop();
		var retret: PressMsg  = ({ pmText(TU.text(hllr__0)); });
		ret.push(retret);
	}
	private static inline function R430(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: Arrangement  = ({ hllr__2; });
		ret.push(retret);
	}
	private static inline function R431(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: NegQuery  = ({ negQRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R432(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: NegQuery  = ({ negNOT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R433(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: LogicalOp  = ({ { and:true, list:hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R434(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__1: Array<Arrangement>  = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: LogicalOp  = ({ { and:false,list:hllr__1 }; });
		ret.push(retret);
	}
	private static inline function R435(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmYes(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R436(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmYes(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R437(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmRej(hllr__2,null); });
		ret.push(retret);
	}
	private static inline function R438(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmRej(null,hllr__2); });
		ret.push(retret);
	}
	private static inline function R439(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: PressMsg  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmBWX(hllr__2); });
		ret.push(retret);
	}
	private static inline function R440(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Array<Token>  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmHUH(hllr__2); });
		ret.push(retret);
	}
	private static inline function R441(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: NegQuery  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmTHK(hllr__2); });
		ret.push(retret);
	}
	private static inline function R442(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: NegQuery  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmFCT(hllr__2); });
		ret.push(retret);
	}
	private static inline function R443(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmSRY(hllr__2); });
		ret.push(retret);
	}
	private static inline function R444(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmPOB(hllr__2); });
		ret.push(retret);
	}
	private static inline function R445(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmWHY(whyThinkFact(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R446(ret:Array<Dynamic>) {
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
	private static inline function R447(ret:Array<Dynamic>) {
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
	private static inline function R448(ret:Array<Dynamic>) {
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
	private static inline function R449(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyQry(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R450(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Explanation  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ReplyMsg  = ({ rmIDK(whyExp(hllr__2)); });
		ret.push(retret);
	}
	private static inline function R451(ret:Array<Dynamic>) {
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
	private static inline function R452(ret:Array<Dynamic>) {
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
	private static inline function R453(ret:Array<Dynamic>) {
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
	private static inline function R454(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__0: PressMsg  = ret.pop();
		var retret: ReplyMsg  = ({ rmPress(hllr__0); });
		ret.push(retret);
	}
	private static inline function R455(ret:Array<Dynamic>) {
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
	private static inline function R456(ret:Array<Dynamic>) {
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
	private static inline function R457(ret:Array<Dynamic>) {
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
	private static inline function R458(ret:Array<Dynamic>) {
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
	private static inline function R459(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ { thk:true, arr:hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R460(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: Arrangement  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ { thk:false,arr:hllr__2 }; });
		ret.push(retret);
	}
	private static inline function R461(ret:Array<Dynamic>) {
		//assign arguments.
var hllr__3:Token = ret.pop();
var hllr__2: ThinkAndFact  = ret.pop();
var hllr__1:Token = ret.pop();
var hllr__0:Token = ret.pop();
		var retret: ThinkAndFact  = ({ hllr__2; });
		ret.push(retret);
	}
}
