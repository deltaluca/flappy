package daide;

import daide.Tokens;
using Tokens.TokenUtils;

class MessageUtils {
	static public function inflate(msg:Array<Token>,?ind=0): {outind:Int, msg:Message} {
		if(ind >= msg.length) return {outind:ind,msg:null};
		
		function accept(tok:Token) {
			if(Type.enumEq(tok,msg[ind])) {
				ind++;
				return true;
			}else
				return false;
		}
		
		function expect(tok:Token) {
			if(Type.enumEq(tok,msg[ind])) {
				ind++;
				return true;
			}
			throw "Error: Unexpected token, expected "+Std.string(tok)+" found "+Std.string(msg[ind])+" instead";
			return false;
		}

		function getString() {
			if(ind>=msg.length)
				throw "Error: Expected string, found null instead";
			var ret = "";
			while(ind<msg.length) {
				switch(msg[ind]) {
					case tText(char):
						ret += char;
						ind++;
					default:
						if(ret=="")
							throw "Error: Expected string, found "+Std.string(msg[ind])+" instead";
						break;
				}
			}
			return ret;
		}

		function getInt() {
			if(ind>=msg.length) 
				throw "Error: Expected integer, found null instead";

			var cur = msg[ind];
			switch(cur) {
				case tInteger(val):
					ind++;
					return val;
				default:
					throw "Error: Expected integer, found "+Std.string(cur)+" instead";
					return -1;
			}
		}

		var ret:Message = null;

		if(accept(tCommand(coName))) {
			expect(tLeftParen);
			var name = getString();
			expect(tRightParen);
			expect(tLeftParen);
			var version = getString();
			expect(tRightParen);
			ret = mObserver(obsName(name,version));
		}else if(accept(tCommand(coObserver))) {
			ret = mObserver(obsObserver);
		}else if(accept(tCommand(coIAm))) {
			expect(tLeftParen);
			var power = getInt();
			expect(tRightParen);
			expect(tLeftParen);
			var passcode = getInt();
			expect(tRightParen);
			ret = mObserver(obsIAm(power,passcode));
		}else if(accept(tCommand(coAccept))) {
			if(accept(tLeftParen)) {
				var mid = inflate(msg,ind);
				if(mid.msg==null) throw "Error: Expected Daide message in YES ( .. )";
				ind = mid.outind;
				expect(tRightParen);
				ret = mObserver(obsAccept(mid.msg));
			}else
				ret = mObserver(obsAccept(null));
		}else if(accept(tCommand(coReject))) {
			if(accept(tLeftParen)) {
				var mid = inflate(msg,ind);
				if(mid.msg==null) throw "Error: Expected Daide message in REJ ( .. )";
				ind = mid.outind;
				expect(tRightParen);
				ret = mObserver(obsReject(mid.msg));
			}else
				ret = mObserver(obsReject(null));
		}


		if(ret==null)
			throw "Unrecognised token stream :: "+msg.slice(ind).join(" ");
		return {outind:ind, msg:ret};
	}

	static public function flatten(msg:Message):Array<Token> {
		return switch(msg) {
		case mObserver(obs):
			switch(obs) {
			case obsName(name,version):
				[tCommand(coName),tLeftParen]
				.concat(name.fromString())
				.concat([tRightParen,tLeftParen])
				.concat(version.fromString())
				.concat([tRightParen]);
			case obsObserver:
				[tCommand(coObserver)];
			case obsIAm(power,passcode):
				[tCommand(coIAm),
				 tLeftParen,tInteger(power),tRightParen,
				 tLeftParen,tInteger(passcode),tRightParen];
			case obsMap(name):
				if(name==null)
					[tCommand(coMap)];
				else
					[tCommand(coMap),tLeftParen]
					.concat(name.fromString())
					.concat([tRightParen]);
			case obsAccept(msg):
				if(msg==null)
					[tCommand(coAccept)];
				else
					[tCommand(coAccept),tLeftParen]
					.concat(flatten(msg))
					.concat([tRightParen]);
			case obsReject(msg):
				if(msg==null)
					[tCommand(coReject)];
				else
					[tCommand(coReject),tLeftParen]
					.concat(flatten(msg))
					.concat([tRightParen]);
			case obsTimeToDeadline(time):
				if(time==null)
					[tCommand(coTimeToDeadline)];
				else
					[tCommand(coTimeToDeadline),
					 tLeftParen,tInteger(time),tRightParen];
			case obsAdmin(name,msg):
				[tCommand(coAdmin),tLeftParen]
				.concat(name.fromString())
				.concat([tRightParen,tLeftParen])
				.concat(msg.fromString())
				.concat([tRightParen]);
			default:
				throw "fuck";
			}
		default:
			throw "fuck";
		}	
	}	
}

enum ObserverMessage {
	obsName(name:String,version:String);
	obsObserver;
	obsIAm(power:Int,passcode:Int);
	obsMap(name:String);
	//obsMapDefinition(...);
	obsAccept(msg:Message);
	obsReject(msg:Message);
	//obsNow(...);
	//obsSCO??(...);
	//obsHST??(...);
	obsTimeToDeadline(time:Null<Int>);
	obsAdmin(name:String,msg:String);
	//obsPRN??(...);
	//obsHUH??(...);
}

enum Message {
	mObserver(msg:ObserverMessage);
}
