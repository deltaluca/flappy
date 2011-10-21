package daide;


	import daide.Tokens;
	class HLexLog {
		public static var logger:String->Void = null;
		public static function log(x:String) {
			logger(x);
		}
	}

class HLex {
		static inline var entry_state:Int = 67;

	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([77,77,177]);
transitions.push(cur);
var cur = [];
cur.push([83,83,176]);
transitions.push(cur);
var cur = [];
cur.push([69,69,175]);
transitions.push(cur);
var cur = [];
cur.push([88,88,174]);
transitions.push(cur);
var cur = [];
cur.push([69,69,173]);
transitions.push(cur);
var cur = [];
cur.push([68,68,171]);
transitions.push(cur);
var cur = [];
cur.push([79,79,170]);
transitions.push(cur);
var cur = [];
cur.push([78,78,167]);
transitions.push(cur);
var cur = [];
cur.push([84,84,166]);
transitions.push(cur);
var cur = [];
cur.push([68,68,165]);
transitions.push(cur);
var cur = [];
cur.push([70,70,164]);
transitions.push(cur);
var cur = [];
cur.push([83,83,163]);
transitions.push(cur);
var cur = [];
cur.push([84,84,161]);
cur.push([87,87,162]);
transitions.push(cur);
var cur = [];
cur.push([83,83,159]);
transitions.push(cur);
var cur = [];
cur.push([70,70,158]);
transitions.push(cur);
var cur = [];
cur.push([80,80,157]);
transitions.push(cur);
var cur = [];
cur.push([68,68,156]);
transitions.push(cur);
var cur = [];
cur.push([77,77,155]);
transitions.push(cur);
var cur = [];
cur.push([72,72,154]);
transitions.push(cur);
var cur = [];
cur.push([70,70,151]);
transitions.push(cur);
var cur = [];
cur.push([77,77,150]);
transitions.push(cur);
var cur = [];
cur.push([87,87,149]);
transitions.push(cur);
var cur = [];
cur.push([68,68,148]);
transitions.push(cur);
var cur = [];
cur.push([78,78,147]);
transitions.push(cur);
var cur = [];
cur.push([84,84,146]);
transitions.push(cur);
var cur = [];
cur.push([82,82,143]);
transitions.push(cur);
var cur = [];
cur.push([67,67,142]);
transitions.push(cur);
var cur = [];
cur.push([83,83,141]);
transitions.push(cur);
var cur = [];
cur.push([67,67,140]);
transitions.push(cur);
var cur = [];
cur.push([79,79,169]);
cur.push([83,83,139]);
transitions.push(cur);
var cur = [];
cur.push([67,67,138]);
transitions.push(cur);
var cur = [];
cur.push([83,83,137]);
transitions.push(cur);
var cur = [];
cur.push([67,67,136]);
transitions.push(cur);
var cur = [];
cur.push([83,83,135]);
transitions.push(cur);
var cur = [];
cur.push([84,84,130]);
transitions.push(cur);
var cur = [];
cur.push([67,67,129]);
transitions.push(cur);
var cur = [];
cur.push([67,67,127]);
transitions.push(cur);
var cur = [];
cur.push([85,85,126]);
transitions.push(cur);
var cur = [];
cur.push([82,82,125]);
transitions.push(cur);
var cur = [];
cur.push([65,65,119]);
cur.push([67,67,120]);
cur.push([70,70,121]);
cur.push([79,79,133]);
cur.push([80,80,122]);
cur.push([84,84,123]);
cur.push([85,85,124]);
transitions.push(cur);
var cur = [];
cur.push([78,78,117]);
cur.push([83,83,118]);
transitions.push(cur);
var cur = [];
cur.push([66,66,115]);
cur.push([69,69,160]);
cur.push([82,82,116]);
transitions.push(cur);
var cur = [];
cur.push([83,83,114]);
transitions.push(cur);
var cur = [];
cur.push([67,67,113]);
cur.push([84,84,153]);
transitions.push(cur);
var cur = [];
cur.push([76,76,145]);
cur.push([82,82,112]);
transitions.push(cur);
var cur = [];
cur.push([67,67,111]);
transitions.push(cur);
var cur = [];
cur.push([84,84,110]);
transitions.push(cur);
var cur = [];
cur.push([82,82,109]);
transitions.push(cur);
var cur = [];
cur.push([86,86,108]);
transitions.push(cur);
var cur = [];
cur.push([69,69,107]);
transitions.push(cur);
var cur = [];
cur.push([74,74,168]);
cur.push([77,77,106]);
cur.push([84,84,134]);
transitions.push(cur);
var cur = [];
cur.push([68,68,105]);
transitions.push(cur);
var cur = [];
cur.push([79,79,104]);
transitions.push(cur);
var cur = [];
cur.push([66,66,103]);
cur.push([82,82,131]);
transitions.push(cur);
var cur = [];
cur.push([65,65,102]);
transitions.push(cur);
var cur = [];
cur.push([66,66,172]);
cur.push([67,67,128]);
cur.push([77,77,144]);
cur.push([80,80,101]);
transitions.push(cur);
var cur = [];
cur.push([79,79,100]);
transitions.push(cur);
var cur = [];
cur.push([68,68,99]);
cur.push([79,79,152]);
transitions.push(cur);
var cur = [];
cur.push([89,89,98]);
transitions.push(cur);
var cur = [];
cur.push([79,79,97]);
transitions.push(cur);
var cur = [];
cur.push([68,68,132]);
cur.push([84,84,96]);
transitions.push(cur);
var cur = [];
cur.push([89,89,95]);
transitions.push(cur);
var cur = [];
cur.push([48,57,90]);
cur.push([65,70,90]);
cur.push([97,102,90]);
transitions.push(cur);
var cur = [];
cur.push([1,9,66]);
cur.push([11,12,66]);
cur.push([14,128,66]);
transitions.push(cur);
var cur = [];
cur.push([1,9,65]);
cur.push([11,12,65]);
cur.push([14,128,65]);
transitions.push(cur);
var cur = [];
cur.push([1,9,65]);
cur.push([11,12,65]);
cur.push([14,38,65]);
cur.push([40,91,65]);
cur.push([93,128,65]);
cur.push([39,39,92]);
cur.push([92,92,64]);
transitions.push(cur);
var cur = [];
cur.push([1,9,66]);
cur.push([11,12,66]);
cur.push([14,33,66]);
cur.push([35,91,66]);
cur.push([93,128,66]);
cur.push([34,34,92]);
cur.push([92,92,63]);
transitions.push(cur);
var cur = [];
cur.push([9,10,88]);
cur.push([13,13,88]);
cur.push([32,32,88]);
cur.push([34,34,66]);
cur.push([39,39,65]);
cur.push([40,40,93]);
cur.push([41,41,94]);
cur.push([48,48,91]);
cur.push([49,57,89]);
cur.push([65,65,77]);
cur.push([66,66,82]);
cur.push([67,67,76]);
cur.push([68,68,87]);
cur.push([69,69,75]);
cur.push([70,70,71]);
cur.push([71,71,84]);
cur.push([72,72,83]);
cur.push([73,73,68]);
cur.push([76,76,85]);
cur.push([77,77,69]);
cur.push([78,78,70]);
cur.push([79,79,72]);
cur.push([80,80,86]);
cur.push([82,82,79]);
cur.push([83,83,73]);
cur.push([84,84,80]);
cur.push([86,86,81]);
cur.push([87,87,74]);
cur.push([89,89,78]);
transitions.push(cur);
var cur = [];
cur.push([65,65,17]);
transitions.push(cur);
var cur = [];
cur.push([65,65,15]);
cur.push([66,66,48]);
cur.push([68,68,14]);
cur.push([73,73,13]);
cur.push([84,84,56]);
transitions.push(cur);
var cur = [];
cur.push([65,65,42]);
cur.push([67,67,33]);
cur.push([69,69,32]);
cur.push([77,77,41]);
cur.push([79,79,12]);
cur.push([82,82,40]);
cur.push([83,83,39]);
cur.push([86,86,38]);
cur.push([87,87,26]);
cur.push([89,89,37]);
transitions.push(cur);
var cur = [];
cur.push([65,65,44]);
cur.push([76,76,60]);
cur.push([82,82,20]);
transitions.push(cur);
var cur = [];
cur.push([66,66,11]);
cur.push([70,70,10]);
cur.push([82,82,9]);
cur.push([85,85,8]);
transitions.push(cur);
var cur = [];
cur.push([67,67,29]);
cur.push([69,69,30]);
cur.push([76,76,6]);
cur.push([78,78,5]);
cur.push([80,80,25]);
cur.push([85,85,55]);
cur.push([86,86,4]);
cur.push([87,87,28]);
transitions.push(cur);
var cur = [];
cur.push([67,67,27]);
cur.push([73,73,23]);
cur.push([86,86,49]);
transitions.push(cur);
var cur = [];
cur.push([67,67,31]);
cur.push([83,83,45]);
transitions.push(cur);
var cur = [];
cur.push([67,67,22]);
cur.push([83,83,46]);
cur.push([84,84,59]);
cur.push([85,85,34]);
cur.push([86,86,58]);
transitions.push(cur);
var cur = [];
cur.push([68,68,0]);
cur.push([77,77,61]);
cur.push([85,85,24]);
transitions.push(cur);
var cur = [];
cur.push([69,69,1]);
cur.push([83,83,36]);
transitions.push(cur);
var cur = [];
cur.push([69,69,50]);
cur.push([84,84,52]);
transitions.push(cur);
var cur = [];
cur.push([72,72,3]);
cur.push([77,77,2]);
transitions.push(cur);
var cur = [];
cur.push([73,73,54]);
transitions.push(cur);
var cur = [];
cur.push([76,76,51]);
cur.push([78,78,35]);
cur.push([80,80,47]);
transitions.push(cur);
var cur = [];
cur.push([76,76,57]);
cur.push([83,83,43]);
cur.push([85,85,18]);
transitions.push(cur);
var cur = [];
cur.push([79,79,19]);
transitions.push(cur);
var cur = [];
cur.push([79,79,16]);
transitions.push(cur);
var cur = [];
cur.push([82,82,7]);
transitions.push(cur);
var cur = [];
cur.push([82,82,21]);
cur.push([83,83,53]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([48,57,89]);
transitions.push(cur);
var cur = [];
cur.push([48,57,90]);
cur.push([65,70,90]);
cur.push([97,102,90]);
transitions.push(cur);
var cur = [];
cur.push([48,57,89]);
cur.push([120,120,62]);
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
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
}

        static var accepting = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false].concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]);

	public static function lexify(input:String):Array<Token> {
		init();
var ret = new Array<Token>();
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

/*	state = if(char>=trans.length) trans[trans.length-1];
	else trans[char];*/
	state = 1;
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
	static inline function errtok(hxl_match:String) {
return ({ HLexLog.log("Error: Unknown char sequence '"+ hxl_match +"'"); null; });
	}
	static function tokenof(id:Int, hxl_match:String) {
		switch(id) {
			default: return null;
            case 89:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 90:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 91:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 92:
				return ({ tText( hxl_match .substr(1, hxl_match .length-2)); });
            case 93:
				return ({ tLeftParen; });
            case 94:
				return ({ tRightParen; });
            case 95:
				return ({ tUnitType(utArmy); });
            case 96:
				return ({ tUnitType(utFleet); });
            case 97:
				return ({ tOrder(oMoveByConvoy); });
            case 98:
				return ({ tOrder(oConvoy); });
            case 99:
				return ({ tOrder(oHold); });
            case 100:
				return ({ tOrder(oMove); });
            case 101:
				return ({ tOrder(oSupport); });
            case 102:
				return ({ tOrder(oVia); });
            case 103:
				return ({ tOrder(oDisband); });
            case 104:
				return ({ tOrder(oRetreat); });
            case 105:
				return ({ tOrder(oBuild); });
            case 106:
				return ({ tOrder(oRemove); });
            case 107:
				return ({ tOrder(oWaive); });
            case 108:
				return ({ tOrderNote(onOkay); });
            case 109:
				return ({ tOrderNote(onBPR); });
            case 110:
				return ({ tOrderNote(onNoCoastSpecified); });
            case 111:
				return ({ tOrderNote(onNotEmptySupply); });
            case 112:
				return ({ tOrderNote(onNotAdjacent); });
            case 113:
				return ({ tOrderNote(onNotHomeSupply); });
            case 114:
				return ({ tOrderNote(onNotAtSea); });
            case 115:
				return ({ tOrderNote(onNoMoreBuilds); });
            case 116:
				return ({ tOrderNote(onNoMoreRemovals); });
            case 117:
				return ({ tOrderNote(onNoRetreatNeeded); });
            case 118:
				return ({ tOrderNote(onNotRightSeason); });
            case 119:
				return ({ tOrderNote(onNoSuchArmy); });
            case 120:
				return ({ tOrderNote(onNotSupply); });
            case 121:
				return ({ tOrderNote(onNoSuchFleet); });
            case 122:
				return ({ tOrderNote(onNoSuchProvince); });
            case 123:
				return ({ tOrderNote(onNST); });
            case 124:
				return ({ tOrderNote(onNoSuchUnit); });
            case 125:
				return ({ tOrderNote(onNotValidRetreat); });
            case 126:
				return ({ tOrderNote(onNotYourUnit); });
            case 127:
				return ({ tOrderNote(onNotYourSupply); });
            case 128:
				return ({ tResult(rSuccess); });
            case 129:
				return ({ tResult(rMoveBounced); });
            case 130:
				return ({ tResult(rSupportCut); });
            case 131:
				return ({ tResult(rConvoyDisrupted); });
            case 132:
				return ({ tResult(rFLD); });
            case 133:
				return ({ tResult(rNoSuchOrder); });
            case 134:
				return ({ tResult(rDislodged); });
            case 135:
				return ({ tCoast(cNorth); });
            case 136:
				return ({ tCoast(cNorthEast); });
            case 137:
				return ({ tCoast(cEast); });
            case 138:
				return ({ tCoast(cSouthEast); });
            case 139:
				return ({ tCoast(cSouth); });
            case 140:
				return ({ tCoast(cSouthWest); });
            case 141:
				return ({ tCoast(cWest); });
            case 142:
				return ({ tCoast(cNorthWest); });
            case 143:
				return ({ tPhase(pSpring); });
            case 144:
				return ({ tPhase(pSummer); });
            case 145:
				return ({ tPhase(pFall); });
            case 146:
				return ({ tPhase(pAutumn); });
            case 147:
				return ({ tPhase(pWinter); });
            case 148:
				return ({ tCommand(coPowerInCivilDisorder); });
            case 149:
				return ({ tCommand(coDraw); });
            case 150:
				return ({ tCommand(coMessageFrom); });
            case 151:
				return ({ tCommand(coGoFlag); });
            case 152:
				return ({ tCommand(coHello); });
            case 153:
				return ({ tCommand(coHistory); });
            case 154:
				return ({ tCommand(coHuh); });
            case 155:
				return ({ tCommand(coIAm); });
            case 156:
				return ({ tCommand(coLoadGame); });
            case 157:
				return ({ tCommand(coMap); });
            case 158:
				return ({ tCommand(coMapDefinition); });
            case 159:
				return ({ tCommand(coMissingOrders); });
            case 160:
				return ({ tCommand(coName); });
            case 161:
				return ({ tCommand(coNOT); });
            case 162:
				return ({ tCommand(coCurrentPosition); });
            case 163:
				return ({ tCommand(coObserver); });
            case 164:
				return ({ tCommand(coTurnOff); });
            case 165:
				return ({ tCommand(coOrderResult); });
            case 166:
				return ({ tCommand(coPowerEliminated); });
            case 167:
				return ({ tCommand(coParenthesisError); });
            case 168:
				return ({ tCommand(coReject); });
            case 169:
				return ({ tCommand(coSupplyOwnership); });
            case 170:
				return ({ tCommand(coSolo); });
            case 171:
				return ({ tCommand(coSendMessage); });
            case 172:
				return ({ tCommand(coSubmitOrder); });
            case 173:
				return ({ tCommand(coSaveGame); });
            case 174:
				return ({ tCommand(coThink); });
            case 175:
				return ({ tCommand(coTimeToDeadline); });
            case 176:
				return ({ tCommand(coAccept); });
            case 177:
				return ({ tCommand(coAdmin); });
        }
	}
}
