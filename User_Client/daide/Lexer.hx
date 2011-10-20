package daide;

import daide.Tokens;

class Lexer {

	//yeeeeh, this could be made faster with my lexer generator maybe
	//but speed on user GUI isn't so important.
	static public function lex(source:String):Array<Token> {
		var ind = 0;
		function grab() {
			function digit(char) {
				var code = char.charCodeAt(0);
				return code >= ("0".charCodeAt(0)) && code <= "9".charCodeAt(0);
			}

			while(ind<source.length && source.charAt(ind)==" ")
				ind++;
			if(ind>=source.length) return null;

			if(source.charAt(ind)=="\"") {
				var ret = "";
				while(source.charAt(++ind)!="\"") ret += source.charAt(ind);
				ind++;
				return lexString(ret);
			}else if(digit(source.charAt(ind)) || source.charAt(ind)=="-") {
				var ret = source.charAt(ind);
				while(digit(source.charAt(++ind))) ret += source.charAt(ind);
				return lexInt(Std.parseInt(ret));
			}else if(source.charAt(ind)=="(") {
				ind++;
				return lexLPar;
			}else if(source.charAt(ind)==")") {
				ind++;
				return lexRPar;
			}else {
				var arc = source.substr(ind,3);
				ind += 3;
				return lexAcronym(arc);
			}
		}

		var ret = [];
		var cur:Lex;
		while((cur=grab())!=null) {
			switch(cur) {
				case lexLPar: ret.push(tLeftParen);
				case lexRPar: ret.push(tRightParen);
				case lexInt(val):  ret.push(tInteger(val));
				case lexString(val): ret = ret.concat(TokenUtils.fromString(val));
				case lexAcronym(val):
					ret.push(switch(val) {
						case "AMY": tUnitType(utArmy); 
						case "FLT": tUnitType(utFleet);
						
						case "CTO":	tOrder(oMoveByConvoy);
						case "CVY": tOrder(oConvoy);
						case "HLD": tOrder(oHold);
						
						case "IAM": tCommand(coIAm);
						case "LOD": tCommand(coLoadGame);
						case "MAP": tCommand(coMap);
						case "MDF": tCommand(coMapDefinition);
						case "MIS": tCommand(coMissingOrders);
						case "NME": tCommand(coName);
						//...
						case "REJ": tCommand(coReject);
						//...
						case "YES": tCommand(coAccept);

						default:
							throw "fuck @ "+val;
							null;
					});
			};
		}
		return ret;
	}

}

enum Lex {
	lexLPar;
	lexRPar;
	lexInt    (val:Int);
	lexString (val:String);
	lexAcronym(val:String);
}
