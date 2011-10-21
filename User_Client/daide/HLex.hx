package daide;


	import daide.Tokens;
	class HLexLog {
		public static var logger:String->Void = null;
		public static function log(x:String) {
			logger(x);
		}
	}

class HLex {
		static inline var entry_state:Int = 104;

	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([84,84,265]);
transitions.push(cur);
var cur = [];
cur.push([79,79,264]);
transitions.push(cur);
var cur = [];
cur.push([89,89,263]);
transitions.push(cur);
var cur = [];
cur.push([79,79,262]);
transitions.push(cur);
var cur = [];
cur.push([84,84,260]);
cur.push([89,89,261]);
transitions.push(cur);
var cur = [];
cur.push([83,83,259]);
transitions.push(cur);
var cur = [];
cur.push([77,77,258]);
transitions.push(cur);
var cur = [];
cur.push([89,89,257]);
transitions.push(cur);
var cur = [];
cur.push([89,89,253]);
transitions.push(cur);
var cur = [];
cur.push([89,89,251]);
transitions.push(cur);
var cur = [];
cur.push([84,84,249]);
transitions.push(cur);
var cur = [];
cur.push([66,66,248]);
transitions.push(cur);
var cur = [];
cur.push([69,69,247]);
transitions.push(cur);
var cur = [];
cur.push([67,67,245]);
transitions.push(cur);
var cur = [];
cur.push([85,85,244]);
transitions.push(cur);
var cur = [];
cur.push([83,83,243]);
transitions.push(cur);
var cur = [];
cur.push([70,70,242]);
transitions.push(cur);
var cur = [];
cur.push([75,75,241]);
transitions.push(cur);
var cur = [];
cur.push([87,87,240]);
transitions.push(cur);
var cur = [];
cur.push([82,82,239]);
transitions.push(cur);
var cur = [];
cur.push([84,84,238]);
transitions.push(cur);
var cur = [];
cur.push([68,68,237]);
transitions.push(cur);
var cur = [];
cur.push([80,80,236]);
transitions.push(cur);
var cur = [];
cur.push([83,83,235]);
transitions.push(cur);
var cur = [];
cur.push([90,90,234]);
transitions.push(cur);
var cur = [];
cur.push([88,88,233]);
transitions.push(cur);
var cur = [];
cur.push([68,68,232]);
transitions.push(cur);
var cur = [];
cur.push([89,89,231]);
transitions.push(cur);
var cur = [];
cur.push([79,79,229]);
transitions.push(cur);
var cur = [];
cur.push([76,76,227]);
transitions.push(cur);
var cur = [];
cur.push([65,65,226]);
transitions.push(cur);
var cur = [];
cur.push([66,66,224]);
cur.push([82,82,225]);
transitions.push(cur);
var cur = [];
cur.push([84,84,222]);
transitions.push(cur);
var cur = [];
cur.push([76,76,221]);
transitions.push(cur);
var cur = [];
cur.push([82,82,220]);
transitions.push(cur);
var cur = [];
cur.push([76,76,219]);
transitions.push(cur);
var cur = [];
cur.push([65,65,218]);
transitions.push(cur);
var cur = [];
cur.push([77,77,217]);
transitions.push(cur);
var cur = [];
cur.push([83,83,216]);
transitions.push(cur);
var cur = [];
cur.push([69,69,215]);
transitions.push(cur);
var cur = [];
cur.push([75,75,255]);
cur.push([78,78,256]);
cur.push([88,88,214]);
transitions.push(cur);
var cur = [];
cur.push([69,69,213]);
transitions.push(cur);
var cur = [];
cur.push([68,68,211]);
transitions.push(cur);
var cur = [];
cur.push([79,79,210]);
transitions.push(cur);
var cur = [];
cur.push([78,78,207]);
cur.push([80,80,250]);
transitions.push(cur);
var cur = [];
cur.push([84,84,206]);
transitions.push(cur);
var cur = [];
cur.push([68,68,205]);
cur.push([82,82,246]);
transitions.push(cur);
var cur = [];
cur.push([70,70,204]);
transitions.push(cur);
var cur = [];
cur.push([83,83,203]);
transitions.push(cur);
var cur = [];
cur.push([84,84,201]);
cur.push([87,87,202]);
transitions.push(cur);
var cur = [];
cur.push([83,83,199]);
transitions.push(cur);
var cur = [];
cur.push([70,70,198]);
transitions.push(cur);
var cur = [];
cur.push([80,80,197]);
transitions.push(cur);
var cur = [];
cur.push([68,68,196]);
transitions.push(cur);
var cur = [];
cur.push([77,77,195]);
transitions.push(cur);
var cur = [];
cur.push([72,72,194]);
transitions.push(cur);
var cur = [];
cur.push([70,70,191]);
transitions.push(cur);
var cur = [];
cur.push([77,77,190]);
transitions.push(cur);
var cur = [];
cur.push([87,87,189]);
transitions.push(cur);
var cur = [];
cur.push([68,68,188]);
transitions.push(cur);
var cur = [];
cur.push([78,78,187]);
transitions.push(cur);
var cur = [];
cur.push([84,84,186]);
transitions.push(cur);
var cur = [];
cur.push([82,82,183]);
transitions.push(cur);
var cur = [];
cur.push([67,67,182]);
transitions.push(cur);
var cur = [];
cur.push([83,83,181]);
transitions.push(cur);
var cur = [];
cur.push([67,67,180]);
transitions.push(cur);
var cur = [];
cur.push([68,68,252]);
cur.push([79,79,209]);
cur.push([83,83,179]);
transitions.push(cur);
var cur = [];
cur.push([67,67,178]);
transitions.push(cur);
var cur = [];
cur.push([83,83,177]);
transitions.push(cur);
var cur = [];
cur.push([67,67,176]);
transitions.push(cur);
var cur = [];
cur.push([83,83,175]);
transitions.push(cur);
var cur = [];
cur.push([84,84,170]);
transitions.push(cur);
var cur = [];
cur.push([67,67,169]);
transitions.push(cur);
var cur = [];
cur.push([67,67,167]);
transitions.push(cur);
var cur = [];
cur.push([85,85,166]);
transitions.push(cur);
var cur = [];
cur.push([82,82,165]);
transitions.push(cur);
var cur = [];
cur.push([65,65,159]);
cur.push([67,67,160]);
cur.push([70,70,161]);
cur.push([79,79,173]);
cur.push([80,80,162]);
cur.push([84,84,163]);
cur.push([85,85,164]);
transitions.push(cur);
var cur = [];
cur.push([78,78,157]);
cur.push([83,83,158]);
transitions.push(cur);
var cur = [];
cur.push([66,66,155]);
cur.push([69,69,200]);
cur.push([82,82,156]);
transitions.push(cur);
var cur = [];
cur.push([83,83,154]);
transitions.push(cur);
var cur = [];
cur.push([67,67,153]);
cur.push([84,84,193]);
transitions.push(cur);
var cur = [];
cur.push([76,76,185]);
cur.push([82,82,152]);
transitions.push(cur);
var cur = [];
cur.push([67,67,151]);
transitions.push(cur);
var cur = [];
cur.push([84,84,150]);
transitions.push(cur);
var cur = [];
cur.push([82,82,149]);
transitions.push(cur);
var cur = [];
cur.push([86,86,148]);
transitions.push(cur);
var cur = [];
cur.push([69,69,147]);
transitions.push(cur);
var cur = [];
cur.push([74,74,208]);
cur.push([77,77,146]);
cur.push([84,84,174]);
transitions.push(cur);
var cur = [];
cur.push([68,68,145]);
transitions.push(cur);
var cur = [];
cur.push([76,76,228]);
cur.push([79,79,144]);
transitions.push(cur);
var cur = [];
cur.push([66,66,143]);
cur.push([68,68,230]);
cur.push([82,82,171]);
transitions.push(cur);
var cur = [];
cur.push([65,65,142]);
transitions.push(cur);
var cur = [];
cur.push([66,66,212]);
cur.push([67,67,168]);
cur.push([71,71,254]);
cur.push([77,77,184]);
cur.push([80,80,141]);
transitions.push(cur);
var cur = [];
cur.push([76,76,223]);
cur.push([79,79,140]);
transitions.push(cur);
var cur = [];
cur.push([68,68,139]);
cur.push([79,79,192]);
transitions.push(cur);
var cur = [];
cur.push([89,89,138]);
transitions.push(cur);
var cur = [];
cur.push([79,79,137]);
transitions.push(cur);
var cur = [];
cur.push([68,68,172]);
cur.push([84,84,136]);
transitions.push(cur);
var cur = [];
cur.push([89,89,135]);
transitions.push(cur);
var cur = [];
cur.push([48,57,130]);
cur.push([65,70,130]);
cur.push([97,102,130]);
transitions.push(cur);
var cur = [];
cur.push([1,9,103]);
cur.push([11,12,103]);
cur.push([14,128,103]);
transitions.push(cur);
var cur = [];
cur.push([1,9,102]);
cur.push([11,12,102]);
cur.push([14,128,102]);
transitions.push(cur);
var cur = [];
cur.push([1,9,102]);
cur.push([11,12,102]);
cur.push([14,38,102]);
cur.push([40,91,102]);
cur.push([93,128,102]);
cur.push([39,39,132]);
cur.push([92,92,101]);
transitions.push(cur);
var cur = [];
cur.push([1,9,103]);
cur.push([11,12,103]);
cur.push([14,33,103]);
cur.push([35,91,103]);
cur.push([93,128,103]);
cur.push([34,34,132]);
cur.push([92,92,100]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([34,34,103]);
cur.push([39,39,102]);
cur.push([40,40,133]);
cur.push([41,41,134]);
cur.push([48,48,131]);
cur.push([49,57,129]);
cur.push([65,65,116]);
cur.push([66,66,121]);
cur.push([67,67,114]);
cur.push([68,68,123]);
cur.push([69,69,113]);
cur.push([70,70,107]);
cur.push([71,71,125]);
cur.push([72,72,122]);
cur.push([73,73,108]);
cur.push([76,76,126]);
cur.push([77,77,105]);
cur.push([78,78,106]);
cur.push([79,79,109]);
cur.push([80,80,110]);
cur.push([81,81,127]);
cur.push([82,82,118]);
cur.push([83,83,111]);
cur.push([84,84,119]);
cur.push([85,85,124]);
cur.push([86,86,120]);
cur.push([87,87,112]);
cur.push([88,88,117]);
cur.push([89,89,115]);
transitions.push(cur);
var cur = [];
cur.push([65,65,52]);
cur.push([66,66,85]);
cur.push([68,68,51]);
cur.push([73,73,50]);
cur.push([82,82,32]);
cur.push([84,84,93]);
transitions.push(cur);
var cur = [];
cur.push([65,65,79]);
cur.push([67,67,70]);
cur.push([69,69,69]);
cur.push([77,77,78]);
cur.push([79,79,49]);
cur.push([80,80,31]);
cur.push([82,82,77]);
cur.push([83,83,76]);
cur.push([86,86,75]);
cur.push([87,87,63]);
cur.push([89,89,74]);
transitions.push(cur);
var cur = [];
cur.push([65,65,81]);
cur.push([67,67,20]);
cur.push([76,76,97]);
cur.push([79,79,19]);
cur.push([82,82,57]);
cur.push([87,87,21]);
transitions.push(cur);
var cur = [];
cur.push([65,65,54]);
cur.push([68,68,17]);
cur.push([70,70,16]);
cur.push([78,78,15]);
cur.push([79,79,14]);
transitions.push(cur);
var cur = [];
cur.push([66,66,48]);
cur.push([67,67,13]);
cur.push([70,70,47]);
cur.push([82,82,46]);
cur.push([85,85,45]);
transitions.push(cur);
var cur = [];
cur.push([67,67,12]);
cur.push([68,68,30]);
cur.push([79,79,11]);
cur.push([80,80,10]);
cur.push([82,82,44]);
cur.push([84,84,29]);
transitions.push(cur);
var cur = [];
cur.push([67,67,66]);
cur.push([69,69,67]);
cur.push([76,76,43]);
cur.push([78,78,42]);
cur.push([80,80,62]);
cur.push([82,82,8]);
cur.push([85,85,92]);
cur.push([86,86,41]);
cur.push([87,87,65]);
transitions.push(cur);
var cur = [];
cur.push([67,67,64]);
cur.push([72,72,4]);
cur.push([73,73,60]);
cur.push([82,82,0]);
cur.push([86,86,86]);
transitions.push(cur);
var cur = [];
cur.push([67,67,68]);
cur.push([76,76,23]);
cur.push([82,82,34]);
cur.push([83,83,82]);
cur.push([88,88,22]);
transitions.push(cur);
var cur = [];
cur.push([67,67,59]);
cur.push([83,83,83]);
cur.push([84,84,96]);
cur.push([85,85,71]);
cur.push([86,86,95]);
transitions.push(cur);
var cur = [];
cur.push([68,68,1]);
cur.push([69,69,38]);
cur.push([83,83,73]);
transitions.push(cur);
var cur = [];
cur.push([68,68,37]);
cur.push([76,76,27]);
cur.push([77,77,98]);
cur.push([78,78,26]);
cur.push([79,79,36]);
cur.push([85,85,61]);
transitions.push(cur);
var cur = [];
cur.push([68,68,3]);
cur.push([79,79,2]);
transitions.push(cur);
var cur = [];
cur.push([69,69,87]);
cur.push([84,84,89]);
transitions.push(cur);
var cur = [];
cur.push([72,72,40]);
cur.push([77,77,39]);
cur.push([82,82,7]);
transitions.push(cur);
var cur = [];
cur.push([73,73,91]);
cur.push([83,83,5]);
transitions.push(cur);
var cur = [];
cur.push([76,76,88]);
cur.push([78,78,72]);
cur.push([80,80,84]);
cur.push([84,84,35]);
cur.push([87,87,25]);
transitions.push(cur);
var cur = [];
cur.push([76,76,94]);
cur.push([79,79,18]);
cur.push([83,83,80]);
cur.push([85,85,55]);
transitions.push(cur);
var cur = [];
cur.push([77,77,24]);
cur.push([82,82,58]);
cur.push([83,83,90]);
transitions.push(cur);
var cur = [];
cur.push([78,78,28]);
cur.push([79,79,6]);
transitions.push(cur);
var cur = [];
cur.push([79,79,56]);
transitions.push(cur);
var cur = [];
cur.push([79,79,53]);
cur.push([86,86,33]);
transitions.push(cur);
var cur = [];
cur.push([82,82,9]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([48,57,129]);
transitions.push(cur);
var cur = [];
cur.push([48,57,130]);
cur.push([65,70,130]);
cur.push([97,102,130]);
transitions.push(cur);
var cur = [];
cur.push([48,57,129]);
cur.push([120,120,99]);
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

        static var accepting = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false].concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]);

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
	static inline function errtok(hxl_match:String) {
return ({ HLexLog.log("Error: Unknown char sequence '"+ hxl_match +"'"); null; });
	}
	static function tokenof(id:Int, hxl_match:String) {
		switch(id) {
			default: return null;
            case 129:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 130:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 131:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 132:
				return ({ tText( hxl_match .substr(1, hxl_match .length-2)); });
            case 133:
				return ({ tLeftParen; });
            case 134:
				return ({ tRightParen; });
            case 135:
				return ({ tUnitType(utArmy); });
            case 136:
				return ({ tUnitType(utFleet); });
            case 137:
				return ({ tOrder(oMoveByConvoy); });
            case 138:
				return ({ tOrder(oConvoy); });
            case 139:
				return ({ tOrder(oHold); });
            case 140:
				return ({ tOrder(oMove); });
            case 141:
				return ({ tOrder(oSupport); });
            case 142:
				return ({ tOrder(oVia); });
            case 143:
				return ({ tOrder(oDisband); });
            case 144:
				return ({ tOrder(oRetreat); });
            case 145:
				return ({ tOrder(oBuild); });
            case 146:
				return ({ tOrder(oRemove); });
            case 147:
				return ({ tOrder(oWaive); });
            case 148:
				return ({ tOrderNote(onOkay); });
            case 149:
				return ({ tOrderNote(onBPR); });
            case 150:
				return ({ tOrderNote(onNoCoastSpecified); });
            case 151:
				return ({ tOrderNote(onNotEmptySupply); });
            case 152:
				return ({ tOrderNote(onNotAdjacent); });
            case 153:
				return ({ tOrderNote(onNotHomeSupply); });
            case 154:
				return ({ tOrderNote(onNotAtSea); });
            case 155:
				return ({ tOrderNote(onNoMoreBuilds); });
            case 156:
				return ({ tOrderNote(onNoMoreRemovals); });
            case 157:
				return ({ tOrderNote(onNoRetreatNeeded); });
            case 158:
				return ({ tOrderNote(onNotRightSeason); });
            case 159:
				return ({ tOrderNote(onNoSuchArmy); });
            case 160:
				return ({ tOrderNote(onNotSupply); });
            case 161:
				return ({ tOrderNote(onNoSuchFleet); });
            case 162:
				return ({ tOrderNote(onNoSuchProvince); });
            case 163:
				return ({ tOrderNote(onNST); });
            case 164:
				return ({ tOrderNote(onNoSuchUnit); });
            case 165:
				return ({ tOrderNote(onNotValidRetreat); });
            case 166:
				return ({ tOrderNote(onNotYourUnit); });
            case 167:
				return ({ tOrderNote(onNotYourSupply); });
            case 168:
				return ({ tResult(rSuccess); });
            case 169:
				return ({ tResult(rMoveBounced); });
            case 170:
				return ({ tResult(rSupportCut); });
            case 171:
				return ({ tResult(rConvoyDisrupted); });
            case 172:
				return ({ tResult(rFLD); });
            case 173:
				return ({ tResult(rNoSuchOrder); });
            case 174:
				return ({ tResult(rDislodged); });
            case 175:
				return ({ tCoast(cNorth); });
            case 176:
				return ({ tCoast(cNorthEast); });
            case 177:
				return ({ tCoast(cEast); });
            case 178:
				return ({ tCoast(cSouthEast); });
            case 179:
				return ({ tCoast(cSouth); });
            case 180:
				return ({ tCoast(cSouthWest); });
            case 181:
				return ({ tCoast(cWest); });
            case 182:
				return ({ tCoast(cNorthWest); });
            case 183:
				return ({ tPhase(pSpring); });
            case 184:
				return ({ tPhase(pSummer); });
            case 185:
				return ({ tPhase(pFall); });
            case 186:
				return ({ tPhase(pAutumn); });
            case 187:
				return ({ tPhase(pWinter); });
            case 188:
				return ({ tCommand(coPowerInCivilDisorder); });
            case 189:
				return ({ tCommand(coDraw); });
            case 190:
				return ({ tCommand(coMessageFrom); });
            case 191:
				return ({ tCommand(coGoFlag); });
            case 192:
				return ({ tCommand(coHello); });
            case 193:
				return ({ tCommand(coHistory); });
            case 194:
				return ({ tCommand(coHuh); });
            case 195:
				return ({ tCommand(coIAm); });
            case 196:
				return ({ tCommand(coLoadGame); });
            case 197:
				return ({ tCommand(coMap); });
            case 198:
				return ({ tCommand(coMapDefinition); });
            case 199:
				return ({ tCommand(coMissingOrders); });
            case 200:
				return ({ tCommand(coName); });
            case 201:
				return ({ tCommand(coNOT); });
            case 202:
				return ({ tCommand(coCurrentPosition); });
            case 203:
				return ({ tCommand(coObserver); });
            case 204:
				return ({ tCommand(coTurnOff); });
            case 205:
				return ({ tCommand(coOrderResult); });
            case 206:
				return ({ tCommand(coPowerEliminated); });
            case 207:
				return ({ tCommand(coParenthesisError); });
            case 208:
				return ({ tCommand(coReject); });
            case 209:
				return ({ tCommand(coSupplyOwnership); });
            case 210:
				return ({ tCommand(coSolo); });
            case 211:
				return ({ tCommand(coSendMessage); });
            case 212:
				return ({ tCommand(coSubmitOrder); });
            case 213:
				return ({ tCommand(coSaveGame); });
            case 214:
				return ({ tCommand(coThink); });
            case 215:
				return ({ tCommand(coTimeToDeadline); });
            case 216:
				return ({ tCommand(coAccept); });
            case 217:
				return ({ tCommand(coAdmin); });
            case 218:
				return ({ tParameter(paAnyOrder); });
            case 219:
				return ({ tParameter(paBuildTimeLimit); });
            case 220:
				return ({ tParameter(paLocationError); });
            case 221:
				return ({ tParameter(paLevel); });
            case 222:
				return ({ tParameter(paMustRetreat); });
            case 223:
				return ({ tParameter(paMoveTimeLimit); });
            case 224:
				return ({ tParameter(paNoPressDuringBuild); });
            case 225:
				return ({ tParameter(paNoPressDuringRetreat); });
            case 226:
				return ({ tParameter(paPartialDrawsAllowed); });
            case 227:
				return ({ tParameter(paPressTimeLimit); });
            case 228:
				return ({ tParameter(paRetreatTimeLimit); });
            case 229:
				return ({ tParameter(paUnowned); });
            case 230:
				return ({ tParameter(paDeadlineDisconnect); });
            case 231:
				return ({ tPress(prAlly); });
            case 232:
				return ({ tPress(prAND); });
            case 233:
				return ({ tPress(prNoneOfYourBusiness); });
            case 234:
				return ({ tPress(prDemiliterisedZone); });
            case 235:
				return ({ tPress(prELSE); });
            case 236:
				return ({ tPress(prExplain); });
            case 237:
				return ({ tPress(prRequestForward); });
            case 238:
				return ({ tPress(prFact); });
            case 239:
				return ({ tPress(prForTurn); });
            case 240:
				return ({ tPress(prHowToAttack); });
            case 241:
				return ({ tPress(prIDontKnow); });
            case 242:
				return ({ tPress(prIF); });
            case 243:
				return ({ tPress(prInsist); });
            case 244:
				return ({ tPress(prIOU); });
            case 245:
				return ({ tPress(prOccupy); });
            case 246:
				return ({ tPress(prOR); });
            case 247:
				return ({ tPress(prPeace); });
            case 248:
				return ({ tPress(prPosition); });
            case 249:
				return ({ tPress(prPPT); });
            case 250:
				return ({ tPress(prPropose); });
            case 251:
				return ({ tPress(prQuery); });
            case 252:
				return ({ tPress(prSupplyDistro); });
            case 253:
				return ({ tPress(prSorry); });
            case 254:
				return ({ tPress(prSuggest); });
            case 255:
				return ({ tPress(prThink); });
            case 256:
				return ({ tPress(prThen); });
            case 257:
				return ({ tPress(prTry); });
            case 258:
				return ({ tPress(prUOM); });
            case 259:
				return ({ tPress(prVersus); });
            case 260:
				return ({ tPress(prWhat); });
            case 261:
				return ({ tPress(prWhy); });
            case 262:
				return ({ tPress(prDo); });
            case 263:
				return ({ tPress(prOwes); });
            case 264:
				return ({ tPress(prTellMe); });
            case 265:
				return ({ tPress(prWRT); });
        }
	}
}
