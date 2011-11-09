package daide;
import Match;
import daide.Language;
import daide.Tokens;
class Unparser{
    public static function unparse(x:Message):Array<Token>{
        return Match.match(x,mName(x,y)=[tCommand(coName),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mObserver=[tCommand(coObserver)],mIAm(x,y)=[tCommand(coIAm),tLeftParen,tPower(x),tRightParen,tLeftParen,tInteger(y),tRightParen],mMap(null)=[tCommand(coMap)],mMapDefinition(null,null,null)=[tCommand(coMapDefinition)],mAccept(x)=[tCommand(coAccept),tLeftParen].concat(unparse(x)).concat([tRightParen]),mReject(x)=[tCommand(coReject),tLeftParen].concat(unparse(x)).concat([tRightParen]),mCurrentLocation(null,null)=[tCommand(coCurrentPosition)],mSupplyOwnership(null)=[tCommand(coSupplyOwnership)],mHistory(turn)=[tCommand(coHistory),tLeftParen].concat(unturn(turn)).concat([tRightParen]),mTimeToDeadline(null)=[tCommand(coTimeToDeadline)],mTimeToDeadline(x)=[tCommand(coTimeToDeadline),tLeftParen,tInteger(x),tRightParen],mAdmin(x,y)=[tCommand(coAdmin),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mBadBrackets(xs)=[tCommand(coParenthesisError),tLeftParen].concat(xs).concat([tRightParen]),mHuh(xs)=[tCommand(coHuh),tLeftParen].concat(xs).concat([tRightParen]),mHello(null,null,null)=[tCommand(coHello)],mSubmit(null,xs)=[tCommand(coSubmitOrder)].concat(unorder_list(xs)),mSubmit(turn,xs)=[tCommand(coSubmitOrder),tLeftParen].concat(unturn(turn)).concat([tRightParen]).concat(unorder_list(xs)),mNOT(x)=[tCommand(coNOT),tLeftParen].concat(unparse(x)).concat([tRightParen]),mMissingOrders(null,null)=[tCommand(coMissingOrders)],mGoFlag=[tCommand(coGoFlag)],mOrderResult(null,null,null)=[tCommand(coOrderResult)],mDraw(null)=[tCommand(coDraw)],mDraw(xs)=[tCommand(coDraw),tLeftParen].concat(unpower_list(xs)).concat([tRightParen]),mMap(x)=[tCommand(coMap),tLeftParen,tText(x),tRightParen],mHello(x,y,z)=[tCommand(coHello),tLeftParen,tPower(x),tRightParen,tLeftParen,tInteger(y),tRightParen,tLeftParen].concat(unvariant(z)).concat([tRightParen]),mCurrentLocation(x,y)=[tCommand(coCurrentPosition),tLeftParen].concat(unturn(x)).concat([tRightParen]).concat(ununit_with_location_and_mrt_list(y)),mMissingOrders(null,x)=[tCommand(coMissingOrders)].concat(ununit_with_location_and_mrt_list(x)),mMissingOrders(x,null)=[tCommand(coMissingOrders),tLeftParen,tInteger(x),tRightParen],mSaveGame(x)=[tCommand(coSaveGame),tLeftParen,tText(x),tRightParen],mLoadGame(x)=[tCommand(coLoadGame),tLeftParen,tText(x),tRightParen],mTurnOff=[tCommand(coTurnOff)],mPowerDisorder(x)=[tCommand(coPowerInCivilDisorder),tLeftParen,tPower(x),tRightParen],mNOT(x)=[tCommand(coNOT),tLeftParen].concat(unparse(x)).concat([tRightParen]),mSolo(x)=[tCommand(coSolo),tLeftParen,tInteger(x),tRightParen],mPowerEliminated(x)=[tCommand(coPowerEliminated),tLeftParen,tPower(x),tRightParen]);
        return[];
    }
    static function unmdf_province_list(xs:Array<Location>):Array<Token>{
        var ret=[];
        for(x in xs)ret=ret.concat(unmdf_province(x));
        return ret;
    }
    static function ununit_with_location_and_mrt(x:UnitWithLocAndMRT):Array<Token>{
        return if(x.locs==null)ununit_with_location(x.unitloc);
        else ununit_with_location(x.unitloc).concat([tParameter(paMustRetreat),tLeftParen]).concat(unmdf_province_list(x.locs)).concat([tRightParen]);
    }
    static function ununit_with_location_list(xs:Array<UnitWithLoc>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(ununit_with_location(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function ununit_with_location_and_mrt_list(xs:Array<UnitWithLocAndMRT>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(ununit_with_location_and_mrt(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unvariant(o:Variant):Array<Token>{
        var ret=[];
        for(v in o){
            ret.push(tLeftParen);
            ret=ret.concat(unvariant_option(v));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unvariant_option(o:VariantOption):Array<Token>{
        var ret=[tParameter(o.par)];
        if(o.val!=null)ret.push(tInteger(o.val));
        return ret;
    }
    static function unturn(t:Turn):Array<Token>return[tPhase(t.phase)].concat([tInteger(t.turn)])static function unorder_list(xs:Array<MsgOrder>):Array<Token>{
        var ret=[];
        for(i in xs)ret=ret.concat([tLeftParen]).concat(unorder(i)).concat([tRightParen]);
        return ret;
    }
    static function unorder(x:MsgOrder):Array<Token>{
        return Match.match(x,moHold(x)=[tLeftParen].concat(ununit_with_location(x)).concat([tRightParen,tOrder(oHold)]));
    }
    static function ununit_with_location(x:UnitWithLoc):Array<Token>{
        return[tPower(x.power),tUnitType(x.type)].concat(unmdf_province(x.location));
    }
    static function unmdf_province(x:Location):Array<Token>{
        if(x.coast==null)return[tProvince(x.province)];
        else return[tLeftParen].concat(unprovince_and_coast(x)).concat([tRightParen]);
    }
    static function unprovince_and_coast(x:Location):Array<Token>{
        return[tProvince(x.province),tCoast(x.coast)];
    }
    static function unpower_list(xs:Array<Int>):Array<Token>{
        var ret=[];
        for(i in xs)ret.push(tPower(i));
        return ret;
    }
}