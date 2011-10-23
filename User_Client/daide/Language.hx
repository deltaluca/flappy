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
//	mMapDefinition(...);
	mAccept(m:Message);
	mReject(m:Message);
	mCurrentLocation(turn:Turn,unitlocs:Array<UnitWithLocAndMRT>);
//	mSupplyOwnership(...);
	mHistory(turn:Turn);
	mTimeToDeadline(time:Null<Int>);
	mAdmin(a:String,b:String);
//	mBadBracketedSequence(...);
//	mHuh(...);
	mHello;
	mSubmit(turn:Turn,orders:Array<MsgOrder>);
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

typedef Turn = { phase : Phase, turn : Int };
typedef Location = { province : Province, coast : Coast };
typedef UnitWithLoc = { power : Int, type : UnitType, location : Location };
typedef VariantOption = { par : Parameter, val : Null<Int> };
typedef Variant = Array<VariantOption>;
typedef UnitWithLocAndMRT = { unitloc : UnitWithLoc, locs : Array<Location> };
typedef MdfCentreList = { powers : Array<Int>, locs : Array<Location> }; 
/*
enum ObsMessage {
	obsName(name:String,version:String);
	obsObserver;
	obsIAm(power:Int,passcode:Int);
	obsMap_0;
	obsMap(name:String);
	obsMapDefinition_0;
	//obsMapDefinition(...);
	obsAccept(msg:Message);
	obsReject(msg:Message);
	//obsNow(...);
	//obsSCO??(...);
	obsHistory(turn:Turn);
	obsTimeToDeadline_0;
	obsTimeToDeadline(time:Int);
	obsAdmin(name:String,msg:String);
	//obsPRN??(...);
	//obsHUH??(...);
	obsSaveGame(name:String);
	obsGoFlag_0;
	obsDraw_0;
	obsDraw(powers:Array<Int>);
	obsCurrentPosition_0;
	obsSupplyOwnership_0;
	obsSubmit_0;
	obsSubmit(x:RealOrder);
}

enum RealOrder {
	roHold(uloc:UnitWithLoc);
	roDisband(uloc:UnitWithLoc);
	roBuild(uloc:UnitWithLoc);
	roRemove(uloc:UnitWithLoc);
}

enum Lvl0Message {
	lvl0Hello_0;
	lvl0Hello(power:Int,num:Int,v:Variant);
	lvl0MissingOrders_0;
	lvl0GoFlag_0;
	lvl0OrderResult_0;
	lvl0Draw_0;
	lvl0Not(msg:Message);
	lvl0Submit(turn:Turn,orders:Array<RealOrder>);
}

enum Lvl10Message {
	lvl10Draw(powers:Array<Int>);
}

typedef Turn = { phase : Phase, turn : Int };
typedef Variant = Array<{ par : Parameter, val : Null<Int> }>;
typedef Location = { province : Province, coast : Coast };
typedef UnitWithLoc = { power : Int, type : UnitType, location : Location };

enum Message {
	mObs(msg:ObsMessage);
	mLvl0(msg:Lvl0Message);
	mLvl10(msg:Lvl10Message);
}*/
