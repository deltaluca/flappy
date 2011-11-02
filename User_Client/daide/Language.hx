package daide;

import daide.Tokens;
import daide.HLlr;

enum Message {
	mName(name:String,version:String);
	mObserver;
	mIAm(power:Int,passcode:Int);
	mMap(name:String);
	mSaveGame(name:String);
	mLoadGame(name:String);
	mMapDefinition(powers:Array<Int>,provinces:MdfProvinces,adj:Array<MdfProAdjacencies>);
	mAccept(m:Message);
	mReject(m:Message);
	mCurrentLocation(turn:Turn,unitlocs:Array<UnitWithLocAndMRT>);
	mSupplyOwnership(scos:Array<ScoEntry>);
	mHistory(turn:Turn);
	mTimeToDeadline(time:Null<Int>);
	mAdmin(a:String,b:String);
	mBadBrackets(seq:Array<Token>);
	mHuh(seq:Array<Token>);
	mHello(power:Null<Int>,x:Int,v:Variant);
	mSubmit(turn:Turn,orders:Array<MsgOrder>);
	mDraw(powers:Array<Int>);
	mMissingOrders(x:Null<Int>,units:Array<UnitWithLocAndMRT>);
	mThink(order:MsgOrder, note:OrderNote);
	mOrderResult(turn:Turn, order:MsgOrder, result:CompOrderResult);
	mSolo(power:Int);
	mGoFlag;
	mNOT(msg:Message);
	mPowerDisorder(power:Int);
	mTurnOff;
	mPowerEliminated(power:Int);
	mSend(t:Turn,powers:Array<Int>,press:PressMsg,reply:ReplyMsg);
}

enum MsgOrder {
	moHold(unit:UnitWithLoc);
	moDisband(unit:UnitWithLoc);
	moBuild(unit:UnitWithLoc);
	moRemove(unit:UnitWithLoc);
	moRetreat(unit:UnitWithLoc, loc:Location);
	moMove(unit:UnitWithLoc, loc:Location);
	moSupport(unit:UnitWithLoc, unit2:UnitWithLoc, move:Province);
	moConvoy(unit:UnitWithLoc, unit2:UnitWithLoc, to:Province);
	moMoveByConvoy(unit:UnitWithLoc, from:Province, via:Array<Province>); 
}

enum Arrangement {
	arPeace(powers:Array<Int>);
	arAlly(powers:Array<Int>, versus:Array<Int>);
	arDraw;
	arSolo(power:Int);
	arNOT(arr:Arrangement);
	arNAR(arr:Arrangement);
	arXDo(arr:MsgOrder);
	arDMZ(powers:Array<Int>, locs:Array<Location>);
	arAND(list:Array<Arrangement>);
	arOR(list:Array<Arrangement>);
	arSCD(list:Array<ScOwnershipList>);
	arOCC(list:Array<UnitWithLoc>);
	arCHO(a:Int,b:Int,list:Array<Arrangement>);	
	arFOR(t:Turn,p:Period,offer:FutureOffer);
	arXOY(a:Int,b:Int);
	arYDO(a:Int,units:Array<UnitWithLoc>);
	arSND(a:Int,b:Array<Int>,press:PressMsg,reply:ReplyMsg);
	arFWD(a:Array<Int>,b:Int,c:Int);
	arBCC(a:Int,b:Array<Int>,c:Int);
}

enum PressMsg {
	pmPRP(a:Arrangement,b:LogicalOp);
	pmTRY(toks:Array<Token>);
	pmCCL(pm:PressMsg);
	pmINS(a:Arrangement);
	pmQRY(a:Arrangement);
	pmSUG(a:Arrangement);
	pmTHK(a:Arrangement);
	pmFCT(a:Arrangement);
	pmWHT(unit:UnitWithLoc);
	pmHOW(p:Province,pow:Null<Int>);
	pmEXP(t:Turn,r:ReplyMsg);
	pmIFF(a:Arrangement, p:PressMsg, els:PressMsg);
	pmFRM(a:Int, b:Int, c:Array<Int>, p:PressMsg, r:ReplyMsg);
	pmText(x:String);
}

enum ReplyMsg {
	rmYes(p:PressMsg,e:Explanation);
	rmRej(p:PressMsg,e:Explanation);
	rmBWX(p:PressMsg);
	rmHUH(x:Array<Token>);
	rmTHK(x:NegQuery);
	rmFCT(x:NegQuery);
	rmSRY(e:Explanation);
	rmPress(p:PressMsg);
	rmPOB(x:ThinkAndFact);
	rmWHY(x:WhyIDK);
	rmIDK(x:WhyIDK);
}

enum WhyIDK {
	whyQry(q:Arrangement);
	whyExp(e:Explanation);
	whyPRP(a:Arrangement);
	whyINS(a:Arrangement);
	whySug(a:Arrangement);
	whyThinkFact(a:ThinkAndFact);
}

enum NegQuery {
	negQRY(a:Arrangement);
	negNOT(a:Arrangement);
}

typedef ScoEntry = { power : Int, locs : Array<Location> };
typedef Turn = { phase : Phase, turn : Int };
typedef Location = { province : Province, coast : Coast };
typedef UnitWithLoc = { power : Int, type : UnitType, location : Location };
typedef VariantOption = { par : Parameter, val : Null<Int> };
typedef Variant = Array<VariantOption>;
typedef UnitWithLocAndMRT = { unitloc : UnitWithLoc, locs : Array<Location> };
typedef MdfCentreList = { powers : Array<Int>, locs : Array<Location> }; 
typedef MdfProvinces = { slocs : Array<MdfCentreList>, locs : Array<Location> };
typedef MdfCoastAdjacencies = { unit : UnitType, locs : Array<Location> };
typedef MdfProAdjacencies = { pro : Province, coasts : Array<MdfCoastAdjacencies> }; 
typedef CompOrderResult = { note : OrderNote, result:Result, ret:Bool };
typedef Explanation = { turn : Turn, reply : Message/*TBC: Reply*/ };
typedef Period = { from : Turn, to : Turn };
typedef ScOwnershipList = { power : Null<Int>, locs : Array<Location> };
typedef FutureOffer = Array<Int/*Power*/>;
typedef LogicalOp = { and:Bool, list:Array<Arrangement>}; 
typedef ThinkAndFact = { thk:Bool, arr:Arrangement};
