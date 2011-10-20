package daide;

class TokenUtil {
	public static function encode(token:Token):Int {
		return switch(token) {
			case tInteger(val):
				if(val<-8192 || val>8191) throw "Error: Integer OUB";
				val&0x3FFF;
			case tLeftParen: 0x4000;
			case tRigtParen: 0x4001;
			case tPower(power):
				if(power<0) || power>0xff) throw "Error: Power OUB";
				0x4100 | power;
			case tUnitType(unit):
				0x4200 | switch(unit) { case utArmy: 0x00; default: 0x01 };
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
					case onBRP:					0x01;
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
				};
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

enun Phase {
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
	/* XDO */ prDo;
	/* XOY */ prOwes;
	/* YDO */ prTellMe;
	/* WRT */ prWRT; //doesn't exist in daide syntax?
}

enum Province {
	proInlandNonSC   (val:Int);
	proInlandSC      (val:Int);
	proSeaNonSC      (val:Int);
	proSeaSC         (val:Int);
	proCoastalNonSC  (val:Int);
	proCoastalSC     (val:Int);
	proBiCoastalNoNSC(val:Int);
	proBiCoastalSC   (val:Int);
}

