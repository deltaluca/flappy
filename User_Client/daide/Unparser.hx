package daide;
import scx.Match;
import daide.Language;
import daide.Tokens;
class Unparser{
    public static function unparse(x:Message):Array<Token>{
        return Match.match(x,mName(x,y)=[tCommand(coName),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mObserver=[tCommand(coObserver)],mIAm(x,y)=[tCommand(coIAm),tLeftParen,tPower(x),tRightParen,tLeftParen,tInteger(y),tRightParen],mMap(null)=[tCommand(coMap)],mMapDefinition(null,null,null)=[tCommand(coMapDefinition)],mAccept(x)=[tCommand(coAccept),tLeftParen].concat(unparse(x)).concat([tRightParen]),mReject(x)=[tCommand(coReject),tLeftParen].concat(unparse(x)).concat([tRightParen]),mCurrentLocation(null,null)=[tCommand(coCurrentPosition)],mSupplyOwnership(null)=[tCommand(coSupplyOwnership)],mHistory(turn)=[tCommand(coHistory),tLeftParen].concat(unturn(turn)).concat([tRightParen]),mTimeToDeadline(null)=[tCommand(coTimeToDeadline)],mTimeToDeadline(x)=[tCommand(coTimeToDeadline),tLeftParen,tInteger(x),tRightParen],mAdmin(x,y)=[tCommand(coAdmin),tLeftParen,tText(x),tRightParen,tLeftParen,tText(y),tRightParen],mBadBrackets(xs)=[tCommand(coParenthesisError),tLeftParen].concat(xs).concat([tRightParen]),mHuh(xs)=[tCommand(coHuh),tLeftParen].concat(xs).concat([tRightParen]),mHello(null,null,null)=[tCommand(coHello)],mSubmit(null,xs)=[tCommand(coSubmitOrder)].concat(unorder_list(xs)),mSubmit(turn,xs)=[tCommand(coSubmitOrder),tLeftParen].concat(unturn(turn)).concat([tRightParen]).concat(unorder_list(xs)),mNOT(x)=[tCommand(coNOT),tLeftParen].concat(unparse(x)).concat([tRightParen]),mMissingOrders(null,null)=[tCommand(coMissingOrders)],mGoFlag=[tCommand(coGoFlag)],mOrderResult(null,null,null)=[tCommand(coOrderResult)],mDraw(null)=[tCommand(coDraw)],mDraw(xs)=[tCommand(coDraw),tLeftParen].concat(unpower_list(xs)).concat([tRightParen]),mSend(turn,x,y,z)={
            var pre=[tCommand(coSendMessage),tLeftParen];
            if(turn!=null)pre=pre.concat(unturn(turn)).concat([tRightParen,tLeftParen]);
            pre=pre.concat(unpower_list(x)).concat([tRightParen,tLeftParen]);
            pre.concat(if(z==null)unpress_message(y)else unreply(z)).concat([tRightParen]);
        },
        mMap(x)=[tCommand(coMap),tLeftParen,tText(x),tRightParen],mMapDefinition(x,y,z)=[tCommand(coMapDefinition),tLeftParen].concat(unpower_list(x)).concat([tRightParen,tLeftParen]).concat(unmdf_provinces(y)).concat([tRightParen,tLeftParen]).concat(unmdf_adjacencies(z)).concat([tRightParen]),mHello(x,y,z)=[tCommand(coHello),tLeftParen,tPower(x),tRightParen,tLeftParen,tInteger(y),tRightParen,tLeftParen].concat(unvariant(z)).concat([tRightParen]),mCurrentLocation(x,y)=[tCommand(coCurrentPosition),tLeftParen].concat(unturn(x)).concat([tRightParen]).concat(ununit_with_location_and_mrt_list(y)),mSupplyOwnership(xs)=[tCommand(coSupplyOwnership)].concat(unsco_entry_list(xs)),mThink(x,y)=[tCommand(coThink),tLeftParen].concat(unorder(x)).concat([tRightParen,tLeftParen,tOrderNote(y),tRightParen]),mMissingOrders(null,x)=[tCommand(coMissingOrders)].concat(ununit_with_location_and_mrt_list(x)),mMissingOrders(x,null)=[tCommand(coMissingOrders),tLeftParen,tInteger(x),tRightParen],mOrderResult(x,y,z)=[tCommand(coOrderResult),tLeftParen].concat(unturn(x)).concat([tRightParen,tLeftParen]).concat(unorder(y)).concat([tRightParen,tLeftParen]).concat(uncompound_order_result(z)).concat([tRightParen]),mSaveGame(x)=[tCommand(coSaveGame),tLeftParen,tText(x),tRightParen],mLoadGame(x)=[tCommand(coLoadGame),tLeftParen,tText(x),tRightParen],mTurnOff=[tCommand(coTurnOff)],mPowerDisorder(x)=[tCommand(coPowerInCivilDisorder),tLeftParen,tPower(x),tRightParen],mNOT(x)=[tCommand(coNOT),tLeftParen].concat(unparse(x)).concat([tRightParen]),mSolo(x)=[tCommand(coSolo),tLeftParen,tInteger(x),tRightParen],mPowerEliminated(x)=[tCommand(coPowerEliminated),tLeftParen,tPower(x),tRightParen],mFrom(x,y,z,w1,w2)={
            var pre=[tCommand(coMessageFrom),tLeftParen,tPower(x),tInteger(y),tRightParen,tLeftParen].concat(unpower_list(z)).concat([tRightParen,tLeftParen]);
            pre=pre.concat(if(w1==null)unpress_message(w1)else unreply(w2));
            pre.concat([tRightParen]);
        });
        return[];
    }
    static function unmdf_province_list(xs:Array<Location>):Array<Token>{
        var ret=[];
        for(x in xs)ret=ret.concat(unmdf_province(x));
        return ret;
    }
    static function unmdf_adjacencies(xs:Array<MdfProAdjacencies>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unmdf_province_adjacencies(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unmdf_province_adjacencies(x:MdfProAdjacencies):Array<Token>{
        return[tProvince(x.pro)].concat(unmdf_coast_adjacencies_list(x.coasts));
    }
    static function unmdf_coast_adjacencies(x:MdfCoastAdjacencies):Array<Token>{
        return[tUnitType(x.unit)].concat(unmdf_province_list(x.locs));
    }
    static function unmdf_coast_adjacencies_list(xs:Array<MdfCoastAdjacencies>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unmdf_coast_adjacencies(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unmdf_centre_list(x:MdfCentreList):Array<Token>{
        if(x.powers.length==0)return[tParameter(paUnowned)].concat(unprovince_list(x.locs));
        else if(x.powers.length==1)return[tPower(x.powers[0])].concat(unprovince_list(x.locs));
        else return[tLeftParen].concat(unpower_list(x.powers)).concat([tRightParen]).concat(unprovince_list(x.locs));
    }
    static function unmdf_supply_centres(xs:Array<MdfCentreList>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unmdf_centre_list(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unmdf_provinces(x:MdfProvinces):Array<Token>{
        return[tLeftParen].concat(unmdf_supply_centres(x.slocs)).concat([tRightParen,tLeftParen]).concat(unprovince_list(x.locs)).concat([tRightParen]);
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
    static function uncompound_order_result(x:CompOrderResult):Array<Token>{
        var ret=[if(x.note==null)tResult(x.result)else tOrderNote(x.note)];
        if(x.ret)ret.push(tResult(rDislodged));
        return ret;
    }
    static function unsco_entry(x:ScoEntry):Array<Token>{
        return[tPower(x.power)].concat(unprovince_list(x.locs));
    }
    static function unsco_entry_list(xs:Array<ScoEntry>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unsco_entry(x));
            ret.push(tRightParen);
        }
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
    static function unprovince_list(xs:Array<Province>):Array<Token>{
        var ret=[];
        for(i in xs)ret.push(tProvince(i));
        return ret;
    }
    static function unexplanation(x:Explanation):Array<Token>{
        return[tPress(prExplain),tLeftParen].concat(unturn(x.turn)).concat([tRightParen,tLeftParen]).concat(unreply(x.reply)).concat([tRightParen]);
    }
    static function unfuture_offer(x:FutureOffer):Array<Token>{
        return[tPress(prPeace),tLeftParen].concat(unpower_list(x)).concat([tRightParen]);
    }
    static function unperiod(x:Period):Array<Token>{
        return[tLeftParen].concat(unturn(x.from)).concat([tRightParen,tLeftParen]).concat(unturn(x.to)).concat([tRightParen]);
    }
    static function unsc_ownership_list(x:ScOwnershipList):Array<Token>{
        return[if(x.power==null)tParameter(paUnowned)else tPower(x.power)].concat(unprovince_list(x.locs));
    }
    static function unsc_ownership_list_list(xs:Array<ScOwnershipList>):Array<Token>{
        var ret=[];
        for(i in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unsc_ownership_list(i));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unarrangement(ar:Arrangement):Array<Token>{
        return Match.match(ar,arPeace(xs)=[tPress(prPeace),tLeftParen].concat(unpower_list(xs)).concat([tRightParen]),arAlly(x,y)=[tPress(prAlly),tLeftParen].concat(unpower_list(x)).concat([tRightParen,tPress(prVersus),tLeftParen]).concat(unpower_list(y)).concat([tRightParen]),arDraw=[tCommand(coDraw)],arSolo(x)=[tCommand(coSolo),tLeftParen,tPower(x),tRightParen],arNOT(x)=[tCommand(coNOT),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),arNAR(x)=[tPress(prNAR),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),arXDo(x)=[tPress(prDo),tLeftParen].concat(unorder(x)).concat([tRightParen]),arDMZ(x,y)=[tPress(prDemiliterisedZone),tLeftParen].concat(unpower_list(x)).concat([tRightParen,tLeftParen]).concat(unprovince_list(y)).concat([tRightParen]),arSCD(x)=[tPress(prSupplyDistro)].concat(unsc_ownership_list_list(x)),arOCC(x)=[tPress(prOccupy)].concat(ununit_with_location_list(x)),arAND(x)=[tPress(prAND)].concat(unarrangement_list(x)),arOR(x)=[tPress(prOR)].concat(unarrangement_list(x)),arXOY(a,b)=[tPress(prOwes),tLeftParen,tPower(a),tRightParen,tLeftParen,tPower(b),tRightParen],arYDO(x,y)=[tPress(prTellMe),tLeftParen,tPower(x),tRightParen].concat(ununit_with_location_list(y)),arFOR(x,null,z)=[tPress(prForTurn),tLeftParen].concat(unturn(x)).concat([tRightParen,tLeftParen]).concat(unfuture_offer(z)).concat([tRightParen]),arFOR(null,y,z)=[tPress(prForTurn),tLeftParen].concat(unperiod(y)).concat([tRightParen,tLeftParen]).concat(unfuture_offer(z)).concat([tRightParen]),arSND(x,y,z,null)=[tCommand(coSendMessage),tLeftParen,tPower(x),tRightParen,tLeftParen].concat(unpower_list(y)).concat([tRightParen,tLeftParen]).concat(unpress_message(z)).concat([tRightParen]),arSND(x,y,null,z)=[tCommand(coSendMessage),tLeftParen,tPower(x),tRightParen,tLeftParen].concat(unpower_list(y)).concat([tRightParen,tLeftParen]).concat(unreply(z)).concat([tRightParen]),arCHO(x,y,z)=[tPress(prChoose),tLeftParen,tInteger(x),tInteger(y),tRightParen].concat(unarrangement_list(z)).concat([tRightParen]),arFWD(x,y,z)=[tPress(prRequestForward),tLeftParen].concat(unpower_list(x)).concat([tRightParen,tLeftParen,tPower(y),tRightParen,tLeftParen,tPower(z),tRightParen]),arBCC(x,y,z)=[tPress(prBCC),tLeftParen,tPower(x),tRightParen,tLeftParen].concat(unpower_list(y)).concat([tRightParen,tLeftParen,tPower(z),tRightParen]));
    }
    static function unarrangement_list(xs:Array<Arrangement>):Array<Token>{
        var ret=[];
        for(x in xs){
            ret.push(tLeftParen);
            ret=ret.concat(unarrangement(x));
            ret.push(tRightParen);
        }
        return ret;
    }
    static function unquery(x:Arrangement):Array<Token>return[tPress(prQuery),tLeftParen].concat(unarrangement(x)).concat([tRightParen])static function unnegatable_query(x:NegQuery):Array<Token>{
        return Match.match(x,negQRY(y)=[tPress(prQuery),tLeftParen].concat(unarrangement(y)).concat([tRightParen]),negNOT(y)=[tCommand(coNOT),tLeftParen].concat(unquery(y)).concat([tRightParen]));
    }
    static function unlogical_operator(x:LogicalOp):Array<Token>{
        return[if(x.and)tPress(prAND)else tPress(prOR)].concat(unarrangement_list(x.list));
    }
    static function unpress_message(x:PressMsg):Array<Token>{
        return Match.match(x,pmPRP(x,null)=[tPress(prPropose),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmPRP(null,y)=[tPress(prPropose),tLeftParen].concat(unlogical_operator(y)).concat([tRightParen]),pmHOW(x,null)=[tPress(prHowToAttack),tLeftParen,tProvince(x)].concat([tRightParen]),pmHOW(null,x)=[tPress(prHowToAttack),tLeftParen,tPower(x)].concat([tRightParen]),pmEXP(x,y)=[tPress(prExplain),tLeftParen].concat(unturn(x)).concat([tRightParen,tLeftParen]).concat(unreply(y)).concat([tRightParen]),pmTRY(x)=[tPress(prTry),tLeftParen].concat(x).concat([tRightParen]),pmCCL(x)=[tPress(prCCL),tLeftParen].concat(unpress_message(x)).concat([tRightParen]),pmINS(x)=[tPress(prInsist),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmQRY(x)=[tPress(prQuery),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmSUG(x)=[tPress(prSuggest),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmTHK(x)=[tPress(prThink),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmFCT(x)=[tPress(prFact),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),pmWHT(x)=[tPress(prWhat),tLeftParen].concat(ununit_with_location(x)).concat([tRightParen]),pmIFF(x,y,null)=[tPress(prIF),tLeftParen].concat(unarrangement(x)).concat([tRightParen,tPress(prThen),tLeftParen]).concat(unpress_message(y)).concat([tRightParen]),pmIFF(x,y,z)=[tPress(prIF),tLeftParen].concat(unarrangement(x)).concat([tRightParen,tPress(prThen),tLeftParen]).concat(unpress_message(y)).concat([tRightParen,tPress(prELSE),tLeftParen]).concat(unpress_message(z)).concat([tRightParen]),pmFRM(x,y,z,w,null)=[tCommand(coMessageFrom),tLeftParen,tPower(x),tInteger(y),tRightParen,tLeftParen].concat(unpower_list(z)).concat([tRightParen,tLeftParen]).concat(unpress_message(w)).concat([tRightParen]),pmFRM(x,y,z,null,w)=[tCommand(coMessageFrom),tLeftParen,tPower(x),tInteger(y),tRightParen,tLeftParen].concat(unpower_list(z)).concat([tRightParen,tLeftParen]).concat(unreply(w)).concat([tRightParen]),pmText(x)=[tText(x)]);
    }
    static function unreply(x:ReplyMsg):Array<Token>{
        return Match.match(x,rmYes(x,null)=[tCommand(coAccept),tLeftParen].concat(unpress_message(x)).concat([tRightParen]),rmYes(null,x)=[tCommand(coAccept),tLeftParen].concat(unexplanation(x)).concat([tRightParen]),rmRej(x,null)=[tCommand(coReject),tLeftParen].concat(unpress_message(x)).concat([tRightParen]),rmRej(null,x)=[tCommand(coReject),tLeftParen].concat(unexplanation(x)).concat([tRightParen]),rmBWX(x)=[tPress(prNoneOfYourBusiness),tLeftParen].concat(unpress_message(x)).concat([tRightParen]),rmHUH(x)=[tCommand(coHuh),tLeftParen].concat(x).concat([tRightParen]),rmTHK(x)=[tPress(prThink),tLeftParen].concat(unnegatable_query(x)).concat([tRightParen]),rmFCT(x)=[tPress(prFact),tLeftParen].concat(unnegatable_query(x)).concat([tRightParen]),rmSRY(x)=[tPress(prSorry),tLeftParen].concat(unexplanation(x)).concat([tRightParen]),rmPOB(x)=[tPress(prPosition),tLeftParen].concat(unwhy_sequence(x)).concat([tRightParen]),rmWHY(y)=[tPress(prWhy),tLeftParen].concat(unwhy(y)).concat([tRightParen]),rmIDK(y)=[tPress(prIDontKnow),tLeftParen].concat(unwhy(y)).concat([tRightParen]),rmPress(x)=unpress_message(x));
    }
    static function unwhy(x:WhyIDK):Array<Token>{
        return Match.match(x,whyThinkFact(x)=unthink_and_fact(x),whyQry(x)=unquery(x),whyExp(x)=unexplanation(x),whySug(x)=[tPress(prSuggest),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),whyPRP(x)=[tPress(prPropose),tLeftParen].concat(unarrangement(x)).concat([tRightParen]),whyINS(x)=[tPress(prInsist),tLeftParen].concat(unarrangement(x)).concat([tRightParen]));
    }
    static function unthink_and_fact(x:ThinkAndFact):Array<Token>{
        return[if(x.thk)tPress(prThink)else tPress(prFact),tLeftParen].concat(unarrangement(x.arr)).concat([tRightParen]);
    }
    static function unwhy_sequence(x:ThinkAndFact):Array<Token>return[tPress(prWhy),tLeftParen].concat(unthink_and_fact(x)).concat([tRightParen])
}
