package daide;
import Match;
import daide.Language;
import daide.Tokens;
class Unparser{
    public static function unparse(x:Message):Array<Token>{
        return Match.match(x,mName(x,y)=[tCommand(coName),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mObserver=[tCommand(coObserver)],mIAm(x,y)=[tCommand(coIAm),tLeftParen,tPower(x),tRightParen,tLeftParen,tInteger(y),tRightParen],mMap(null)=[tCommand(coMap)],MapDefinition(null,null,null)=[tCommand(coMapDefinition)],mAccept(x)=[tCommand(coAccept),tLeftParen].concat(unparse(x)).concat([tRightParen]),mReject(x)=[tCommand(coReject),tLeftParen].concat(unparse(x)).concat([tRightParen]),mCurrentLocation(null,null)=[tCommand(coCurrentPosition)],mSupplyOwnership(null)=[tCommand(coSupplyOwnership)],mHistory(turn)=[tCommand(coHistory),tLeftParen].concat(unturn(turn)).concat([tRightParen]),mTimeToDeadline(null)=[tCommand(coTimeToDeadline)],mTimeToDeadline(x)=[tCommand(coTimeToDeadline),tLeftParen,tInteger(x),tRightParen],mAdmin(x,y)=[tCommand(coAdmin),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mBadBrackets(xs)=[tCommand(coParenthesisError),tLeftParen].concat(xs).concat([tRightParen]),mHuh(xs)=[tCommand(coHuh),tLeftParen].concat(xs).concat([tRightParen]),mHello(null,null,null)=[tCommand(coHello)],mSubmit(null,xs)=[tCommand(coSubmitOrder)].concat(unorder_list(xs)),mSubmit(turn,xs)=[tCommand(coSubmitOrder),tLeftParen].concat(unturn(turn)).concat([tRightParen]).concat(unorder_list(xs)),mNOT(x)=[tCommand(coNOT),tLeftParen].concat(unparse(x)).concat([tRightParen]),mMissingOrders(null,null)=[tCommand(coMissingOrders)],mGoFlag=[tCommand(coGoFlag)],mOrderResult(null,null,null)=[tCommand(coOrderResult)],mDraw(null)=[tCommand(coDraw)],mDraw(xs)=[tCommand(coDraw),tLeftParen].concat(unpower_list(xs)).concat([tRightParen]),mMap(x)=[tCommand(coMap),tLeftParen,tText(x),tRightParen]);
        return[];
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
