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
	mSupplyOwnership(scos:Array<ScoEntry>);
	mHistory(turn:Turn);
	mTimeToDeadline(time:Null<Int>);
	mAdmin(a:String,b:String);
//	mBadBracketedSequence(...);
//	mHuh(...);
	mHello(power:Null<Int>,x:Int,v:Variant);
	mSubmit(turn:Turn,orders:Array<MsgOrder>);
	mDraw(powers:Array<Int>);
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

typedef ScoEntry = { power : Int, locs : Array<Location> };
typedef Turn = { phase : Phase, turn : Int };
typedef Location = { province : Province, coast : Coast };
typedef UnitWithLoc = { power : Int, type : UnitType, location : Location };
typedef VariantOption = { par : Parameter, val : Null<Int> };
typedef Variant = Array<VariantOption>;
typedef UnitWithLocAndMRT = { unitloc : UnitWithLoc, locs : Array<Location> };
typedef MdfCentreList = { powers : Array<Int>, locs : Array<Location> }; 
