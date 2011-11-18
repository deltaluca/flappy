package scx;
#if macro import haxe.macro.Expr;
import haxe.macro.Context;
#end enum Pair<A,B>{
    pair(a:A,b:B);
}
class Match{
    #if macro static function mk(e:ExprDef):Expr{
        return{
            expr:e,pos:Context.currentPos()
        };
    }
    static function extract(e:Expr,b:Expr,?cnt:Int=0){
        function gen(v:String){
            var name="__match"+v+"_"+(cnt++);
            var guard=mk(EBinop(OpEq,mk(EConst(CIdent(name))),mk(EConst(CIdent(v)))));
            if(b!=null)guard=mk(EBinop(OpBoolAnd,b,guard));
            return{
                expr:mk(EConst(CIdent(name))),guard:guard,cnt:cnt
            };
        }
        switch(e.expr){
            case EConst(c):switch(c){
                default:case CIdent(v):if(v=="null"||v=="false"||v=="true")return gen(v);
            }
            case ECall(a,xs):var ys=[];
            for(x in xs){
                var eg=extract(x,b,cnt);
                cnt=eg.cnt;
                b=eg.guard;
                ys.push(eg.expr);
            }
            return{
                expr:mk(ECall(a,ys)),guard:b,cnt:cnt
            };
            default:
        }
        return{
            expr:e,guard:b,cnt:cnt
        };
    }
    static function extractData(e:Array<Expr>){
        var def:Expr=null;
        var cases=[];
        for(i in 1...e.length){
            var cs=e[i];
            switch(cs.expr){
                default:throw "lol";
                case EBinop(op,e1,e2):switch(op){
                    default:throw "lol";
                    case OpAssign:var block=e2;
                    var guard:Expr=null;
                    var value=switch(e1.expr){
                        case EBinop(op,oe1,oe2):switch(op){
                            case OpOr:guard=oe2;
                            oe1;
                            default:e1;
                        }
                        default:e1;
                    };
                    var cont=true;
                    switch(value.expr){
                        default:case EConst(c):switch(c){
                            default:case CIdent(x):if(x=="_")cont=false;
                        }
                    }
                    if(cont){
                        var vg=extract(value,guard);
                        cases.push({
                            value:vg.expr,expr:block,guard:vg.guard
                        });
                    }
                    else def=block;
                }
            }
        }
        return{
            on:e[0],def:def,cases:cases
        };
    }
    static inline var matchon="__match_on";
    static function matcher(){
        return mk(EConst(CIdent(matchon)));
    }
    static var varcnt=0;
    static function gencase(match:Expr,cs:Expr,fin:Expr):Expr{
        switch(cs.expr){
            default:throw "lol";
            case EConst(c):switch(match.expr){
                default:case EConst(x):switch(x){
                    default:case CIdent(x2):switch(cs.expr){
                        default:case EConst(y):switch(y){
                            default:case CIdent(y2):if(x2==y2)return fin;
                        }
                    }
                }
            }
            return mk(EIf(mk(EBinop(OpEq,match,cs)),fin,null));
            case ECall(en,args):var name="";
            switch(en.expr){
                default:throw "lol";
                case EConst(c):switch(c){
                    default:throw "lol";
                    case CIdent(n):name=n;
                }
            }
            var vars=[];
            var switchvars=[];
            for(i in 0...args.length){
                var v="";
                switch(args[i].expr){
                    default:case EConst(c):switch(c){
                        default:case CIdent(n):v=n;
                    }
                }
                if(v=="")v="__match_var"+(varcnt++);
                vars.push(v);
                switchvars.push(mk(EConst(CIdent(v))));
            }
            var recurse=fin;
            for(i in 0...args.length){
                var j=args.length-1-i;
                recurse=gencase(switchvars[j],args[j],recurse);
            }
            return mk(ESwitch(match,[{
                expr:recurse,values:[mk(ECall(mk(EConst(CIdent(name))),switchvars))]
            }
            ],mk(EBlock([]))));
        }
    }
    static function domatch(e:Array<Expr>):Expr{
        var gdata=extractData(e);
        var states=[];
        states.push(mk(EVars([{
            name:matchon,type:null,expr:gdata.on
        }
        ])));
        for(cs in gdata.cases){
            var fin=mk(EReturn(cs.expr));
            if(cs.guard!=null)fin=mk(EIf(cs.guard,fin,null));
            states.push(gencase(matcher(),cs.value,fin));
        }
        if(gdata.def!=null)states.push(mk(EReturn(gdata.def)));
        else{
            var str=mk(EConst(CString("Non-exhaustive patterns in match with: ")));
            var fail=mk(EConst(CIdent(matchon)));
            str=mk(EBinop(OpAdd,str,fail));
            states.push(mk(EThrow(str)));
        }
        var block=mk(EBlock(states));
        return mk(ECall(mk(EFunction(null,{
            ret:null,params:[],args:[],expr:block
        })),[]));
    }
    static function pretty(s:String){
        var ind=0;
        var mkIndent=function(i){
            var s="";
            for(k in 0...i)s+="   ";
            return s;
        };
        var o=new haxe.io.BytesOutput();
        for(i in 0...s.length){
            var c=s.charAt(i);
            switch(c){
                case '{','[':o.writeString("\n"+mkIndent(ind)+c);
                ind++;
                case '}',']':ind--;
                o.writeString("\n"+mkIndent(ind)+c);
                case '\n':o.writeString(mkIndent(ind));
                default:o.writeString(c);
            }
        }
        return o.getBytes().toString();
    }
    #end@:macro public static function match(e:Array<haxe.macro.Expr>){
        var ret=domatch(e);
        return ret;
    }
}
