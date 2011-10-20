package daide;

class TokenUtil {
	public static function decode(token:Int):Token {
		var cat = token>>8;
		var kind = (token&0xff);
		return switch(cat) {
			case 0x40: [tLeftParen,tRightParen][kind];
			case 0x41: tPower(kind);
			case 0x42: tUnitType([utArmy,utFleet][kind]);
			case 0x43: tOrder(switch(kind) {
					case 0x20: oMoveByConvoy;
					case 0x21: oConvoy;
					case 0x22: oHold;
					case 0x23: oMove;
					case 0x24: oSupport;
					case 0x25: oVia;
					case 0x40: oDisband;
					case 0x41: oRetreat;
					case 0x80: oBuild;
					case 0x81: oRemove;
					case 0x82: oWaive;
				});
			case 0x44: tOrderNote([
					onOkay,onBPR,onNoCoastSpecified,onNotEmptySupply,onNotAdjacent,
					onNotHomeSupply,onNotAtSea,onNoMoreBuilds,onNoMoreRemovals,
					onNoRetreatNeeded,onNotRightSeason,onNoSuchArmy,onNotSupply,
					onNoSuchFleet,onNoSuchProvince,onNST,onNoSuchUnit,onNotValidRetreat,
					onNotYourUnit,onNotYourSupply
				][kind]);
			case 0x45: tResult([
					rSuccess,rMoveBounced,rSupportCut,rConvoyDisrupted,rFLD,rNoSuchOrder,
					rDislodged
				][kind]);
			case 0x46: tCoast([
					cNorth,cNorthEast,cEast,cSouthEast,cSouth,cSouthWest,cWest,cNorthWest
				][kind>>1]);
			case 0x47: tPhase([
					pSpring,pSummer,pFall,pAutumn,pWinter
				][kind]);
			case 0x48: tCommand([
					coPowerInCivilDisorder,coDraw,coMessageFrom,coGoFlag,coHello,coHistory,
					coHuh,coIAm,coLoadGame,coMap,coMapDefinition,coMissingOrders,coName,
					coNOT,coCurrentPosition,coObserver,coTurnOff,coOrderResult,
					coPowerEliminated,coParenthesisError,coReject,coSupplyOwnership,
					coSolo,coSendMessage,coSubmitOrder,coSaveGame,coThink,coTimeToDeadline,
					coAccept,coAdmin
				][kind]);
			case 0x49: tParameter([
					paAnyOrder,paBuildTimeLimit,paLocationError,paLevel,paMustRetreat,
					paMoveTimeLimit,paNoPressDuringBuild,paNoPressDuringRetreat,
					paPartialDrawsAllowed,paPressTimeLimit,paRetreatTimeLimit,paUnowned,
					null, paDeadlineDisconnect
				][kind]);
			case 0x4a: tPress([
					prAlly,prAND,prNoneOfYourBusiness,prDemiliterisedZone,prELSE,prExplain,
					prRequestForward,prFact,prForTurn,prHowToAttack,prIDontKnow,prIF,
					prInsist,prIOU,prOccupy,prOR,prPeace,prPosition,prPPT,prPropose,
					prQuery,prSupplyDistro,prSorry,prSuggest,prThink,prThen,prTry,prUOM,
					prVersus,prWhat,prWhy,prDo,prOwes,prTellMe,prWRT
				][kind]);
			case 0x4b: tText(String.fromCharCode(kind));
			case 0x50: tProvince(proInland   (kind,false));
			case 0x51: tProvince(proInland   (kind,true));
			case 0x52: tProvince(proSea      (kind,false));
			case 0x53: tProvince(proSea      (kind,true));
			case 0x54: tProvince(proCoastal  (kind,false));
			case 0x55: tProvince(proCoastal  (kind,true));
			case 0x56: tProvince(proBiCoastal(kind,false));
			case 0x57: tProvince(proBiCoastal(kind,true));
			default:
				if(cat<=0x3f) tInteger(token);
		}
	}

	public static function encode(token:Token):Int {
		return switch(token) {
			case tInteger(val):
				if(val<-8192 || val>8191) throw "Error: Integer OUB";
				val&0x3FFF;
			case tLeftParen:  0x4000;
			case tRightParen: 0x4001;
			case tPower(power):
				if(power<0 || power>0xff) throw "Error: Power OUB";
				0x4100 | power;
			case tUnitType(unit):
				0x4200 | switch(unit) { case utArmy: 0x00; default: 0x01; };
			case tOrder(order):
				0x4300 | switch(order) {
					case oMoveByConvoy: 0x20;
					case oConvoy:		0x21;
					case oHold:			0x22;
					case oMove:			0x23;
					case oSupport:		0x24;
					case oVia:			0x25;
					case oDisband:		0x40;
					case oRetreat:		0x41;
					case oBuild:		0x80;
					case oRemove:		0x81;
					case oWaive:		0x82;
				};
			case tOrderNote(note):
				0x4400 | switch(note) {
					case onOkay:				0x00;
					case onBPR:					0x01;
					case onNoCoastSpecified:	0x02;
					case onNotEmptySupply:		0x03;
					case onNotAdjacent:			0x04;
					case onNotHomeSupply:		0x05;
					case onNotAtSea:			0x06;
					case onNoMoreBuilds:		0x07;
					case onNoMoreRemovals:		0x08;
					case onNoRetreatNeeded:		0x09;
					case onNotRightSeason:		0x0a;
					case onNoSuchArmy:			0x0b;
					case onNotSupply:			0x0c;
					case onNoSuchFleet:			0x0d;
					case onNoSuchProvince:		0x0e;
					case onNST:					0x0f;
					case onNoSuchUnit:			0x10;
					case onNotValidRetreat:		0x11;
					case onNotYourUnit:			0x12;
					case onNotYourSupply:		0x13;
				};
			case tResult(result):
				0x4500 | switch(result) {
					case rSuccess:			0x00;
					case rMoveBounced:		0x01;
					case rSupportCut:		0x02;
					case rConvoyDisrupted:	0x03;
					case rFLD:				0x04;
					case rNoSuchOrder:		0x05;
					case rDislodged:		0x06;
				};
			case tCoast(coast):
				0x4600 | switch(coast) {
					case cNorth:		0x00;
					case cNorthEast:	0x02;
					case cEast:			0x04;
					case cSouthEast:	0x06;
					case cSouth:		0x08;
					case cSouthWest:	0x0a;
					case cWest:			0x0c;
					case cNorthWest:	0x0e; 
				};
			case tPhase(phase):
				0x4700 | switch(phase) {
					case pSpring:	0x00;
					case pSummer:	0x01;
					case pFall:		0x02;
					case pAutumn:	0x03;
					case pWinter:	0x04;
				};
			case tCommand(cmd):
				0x4800 | switch(cmd) {
					case coPowerInCivilDisorder:	0x00;
					case coDraw:					0x01;
					case coMessageFrom:				0x02;
					case coGoFlag:					0x03;
					case coHello:					0x04;
					case coHistory:					0x05;
					case coHuh:						0x06;
					case coIAm:						0x07;
					case coLoadGame:				0x08;
					case coMap:						0x09;
					case coMapDefinition:			0x0a;
					case coMissingOrders:			0x0b;
					case coName:					0x0c;
					case coNOT:						0x0d;
					case coCurrentPosition:			0x0e;
					case coObserver:				0x0f;
					case coTurnOff:					0x10;
					case coOrderResult:				0x11;
					case coPowerEliminated:			0x12;
					case coParenthesisError:		0x13;
					case coReject:					0x14;
					case coSupplyOwnership:			0x15;
					case coSolo:					0x16;
					case coSendMessage:				0x17;
					case coSubmitOrder:				0x18;
					case coSaveGame:				0x19;
					case coThink:					0x1a;
					case coTimeToDeadline:			0x1b;
					case coAccept:					0x1c;
					case coAdmin:					0x1d;
				};
			case tParameter(par):
				0x4900 | switch(par) {
					case paAnyOrder:			0x00;
					case paBuildTimeLimit:		0x01;
					case paLocationError:		0x02;
					case paLevel:				0x03;
					case paMustRetreat:			0x04;
					case paMoveTimeLimit:		0x05;
					case paNoPressDuringBuild:	0x06;
					case paNoPressDuringRetreat:0x07;
					case paPartialDrawsAllowed:	0x08;
					case paPressTimeLimit:		0x09;
					case paRetreatTimeLimit:	0x0a;
					case paUnowned:				0x0b;
					case paDeadlineDisconnect:	0x0d;
				};
			case tPress(press):
				0x4a00 | switch(press) {
					case prAlly:				0x00;
					case prAND:					0x01;
					case prNoneOfYourBusiness:	0x02;
					case prDemiliterisedZone:	0x03;
					case prELSE:				0x04;
					case prExplain:				0x05;
					case prRequestForward:		0x06;
					case prFact:				0x07;
					case prForTurn:				0x08;
					case prHowToAttack:			0x09;
					case prIDontKnow:			0x0a;
					case prIF:					0x0b;
					case prInsist:				0x0c;
					case prIOU:					0x0d;
					case prOccupy:				0x0e;
					case prOR:					0x0f;
					case prPeace:				0x10;
					case prPosition:			0x11;
					case prPPT:					0x12;
					case prPropose:				0x13;
					case prQuery:				0x14;
					case prSupplyDistro:		0x15;
					case prSorry:				0x16;
					case prSuggest:				0x17;
					case prThink:				0x18;
					case prThen:				0x19;
					case prTry:					0x1a;
					case prUOM:					0x1b;
					case prVersus:				0x1c;
					case prWhat:				0x1d;
					case prWhy:					0x1e;
					case prDo:					0x1f;
					case prOwes:				0x20;
					case prTellMe:				0x21;
					case prWRT:					0x22;
				};
			case tText(str):
				if(str.length!=1) throw "Error: tText should be 1 char";
				0x4B | str.charCodeAt(0);	
			case tProvince(prov):
				switch(prov) {
					case proInland	  (val,sc): 0x5000|val|(sc ? 0x100 : 0);
					case proSea	  (val,sc): 0x5200|val|(sc ? 0x100 : 0);
					case proCoastal   (val,sc): 0x5400|val|(sc ? 0x100 : 0);
					case proBiCoastal (val,sc): 0x5600|val|(sc ? 0x100 : 0);
				}	
		}
	}
}

//-----------------------------------------------------

enum Token {
	tInteger(value:Int);

	/* BRA */ tLeftParen;
	/* KET */ tRightParen;

	tPower(power:Int);
	tUnitType(unit:UnitType);
	tOrder(order:Order);
	tOrderNote(note:OrderNote);
	tResult(result:Result);
	tCoast(coast:Coast);
	tPhase(phase:Phase);
	tCommand(command:Command);
	tParameter(parameter:Parameter);
	tPress(press:Press);
	tText(text:String);
	tProvince(province:Province);
}

//-----------------------------------------------------

enum UnitType {
	/* AMY */ utArmy;
	/* FLT */ utFleet;
}

enum Order {
	/* CTO */ oMoveByConvoy;
	/* CVY */ oConvoy;
	/* HLD */ oHold;
	/* MTO */ oMove;
	/* SUP */ oSupport;
	/* VIA */ oVia;
	/* DSB */ oDisband;
	/* RTO */ oRetreat;
	/* BLD */ oBuild;
	/* REM */ oRemove;
	/* WVE */ oWaive;
}

enum OrderNote {
	/* MBV */ onOkay;
	/* BPR */ onBPR; //no longer used in Daide
	/* CST */ onNoCoastSpecified;
	/* ESC */ onNotEmptySupply;
	/* FAR */ onNotAdjacent;
	/* HSC */ onNotHomeSupply;
	/* NAS */ onNotAtSea;
	/* NMB */ onNoMoreBuilds;
	/* NMR */ onNoMoreRemovals;
	/* NRN */ onNoRetreatNeeded;
	/* NRS */ onNotRightSeason;
	/* NSA */ onNoSuchArmy;
	/* NSC */ onNotSupply;
	/* NSF */ onNoSuchFleet;
	/* NSP */ onNoSuchProvince;
	/* NST */ onNST; //doesn't seem to exist according to Daide Syntax?
	/* NSU */ onNoSuchUnit;
	/* NVR */ onNotValidRetreat;
	/* NYU */ onNotYourUnit;
	/* YSC */ onNotYourSupply;
}

enum Result {
	/* SUC */ rSuccess;
	/* BNC */ rMoveBounced;
	/* CUT */ rSupportCut;
	/* DSR */ rConvoyDisrupted;
	/* FLD */ rFLD; //no longer used in Daide
	/* NSO */ rNoSuchOrder;
	/* RET */ rDislodged;
}

enum Coast {
	/* NCS */ cNorth;
	/* NEC */ cNorthEast;
	/* ECS */ cEast;
	/* SEC */ cSouthEast;
	/* SCS */ cSouth;
	/* SWC */ cSouthWest;
	/* WCS */ cWest;
	/* NWC */ cNorthWest;
}

enum Phase {
	/* SPR */ pSpring;
	/* SUM */ pSummer;
	/* FAL */ pFall;
	/* AUT */ pAutumn;
	/* WIN */ pWinter;
}

enum Command {
	/* CCD */ coPowerInCivilDisorder;
	/* DRW */ coDraw;
	/* FRM */ coMessageFrom;
	/* GOF */ coGoFlag;
	/* HLO */ coHello;
	/* HST */ coHistory;
	/* HUH */ coHuh;
	/* IAM */ coIAm;
	/* LOD */ coLoadGame;
	/* MAP */ coMap;
	/* MDF */ coMapDefinition;
	/* MIS */ coMissingOrders;
	/* NME */ coName;
	/* NOT */ coNOT;
	/* NOW */ coCurrentPosition;
	/* OBS */ coObserver;
	/* OFF */ coTurnOff;
	/* ORD */ coOrderResult;
	/* OUT */ coPowerEliminated;
	/* PRN */ coParenthesisError;
	/* REJ */ coReject;
	/* SCO */ coSupplyOwnership;
	/* SLO */ coSolo;
	/* SND */ coSendMessage;
	/* SUB */ coSubmitOrder;
	/* SVE */ coSaveGame;
	/* THX */ coThink;
	/* TME */ coTimeToDeadline;
	/* YES */ coAccept;
	/* ADM */ coAdmin;
}

enum Parameter {
	/* AOA */ paAnyOrder;
	/* BTL */ paBuildTimeLimit;
	/* ERR */ paLocationError;
	/* LVL */ paLevel;
	/* MRT */ paMustRetreat;
	/* MTL */ paMoveTimeLimit;
	/* NPB */ paNoPressDuringBuild;
	/* NPR */ paNoPressDuringRetreat;
	/* PDA */ paPartialDrawsAllowed;
	/* PTL */ paPressTimeLimit;
	/* RTL */ paRetreatTimeLimit;
	/* UNO */ paUnowned;
	/* DSD */ paDeadlineDisconnect;
}

enum Press {
	/* ALY */ prAlly;
	/* AND */ prAND;
	/* BWX */ prNoneOfYourBusiness;
	/* DMZ */ prDemiliterisedZone;
	/* ELS */ prELSE;
	/* EXP */ prExplain;
	/* FWD */ prRequestForward;
	/* FCT */ prFact;
	/* FOR */ prForTurn;
	/* HOW */ prHowToAttack;
	/* IDK */ prIDontKnow;
	/* IFF */ prIF;
	/* INS */ prInsist;
	/* IOU */ prIOU; //doesn't exists in daide syntax?
	/* OCC */ prOccupy;
	/* ORR */ prOR;
	/* PCE */ prPeace;
	/* POB */ prPosition;
	/* PPT */ prPPT; //doesn't exists in daide syntax?
	/* PRP */ prPropose;
	/* QRY */ prQuery;
	/* SCD */ prSupplyDistro;
	/* SRY */ prSorry;
	/* SUG */ prSuggest;
	/* THK */ prThink;
	/* THN */ prThen;
	/* TRY */ prTry;
	/* UOM */ prUOM; //doesn't exist in daide syntax?
	/* VSS */ prVersus;
	/* WHT */ prWhat;
	/* WHY */ prWhy;
	/* XDO */ prDo;
	/* XOY */ prOwes;
	/* YDO */ prTellMe;
	/* WRT */ prWRT; //doesn't exist in daide syntax?
}

enum Province {
	proInland    (val:Int,supply:Bool);
	proSea       (val:Int,supply:Bool);
	proCoastal   (val:Int,supply:Bool);
	proBiCoastal (val:Int,supply:Bool);
}

