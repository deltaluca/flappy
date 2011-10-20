package daide;

import daide.Tokens;
using Tokens.TokenUtils;

class MessageUtils {
	public function inflate(msg:Array<Token>,?ind=0): {outind:Int, msg:Message} {
		if(msg.length==0) throw "Error: Empty message";
		
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
			throw "Error: Unexpected token";
			return false;
		}

		function getString() {
			var ret = "";
			while(true) {
				switch(msg[ind]) {
					case tText(char):
						ret += char;
						ind++;
					default:
						break;
				}
			}
			return ret;
		}

		function getInt() {
			var cur = msg[ind];
			switch(cur) {
				case tInteger(val):
					ind++;
					return val;
				default:
					throw "Error: Expected integer";
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
		}

		if(ret==null)
			throw "fuck";
		return {outind:ind, msg:ret};
	}

	public function flatten(msg:Message):Array<Token> {
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
