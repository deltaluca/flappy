package gui;
import nme.display.BitmapData;
import nme.display.Bitmap;
import nme.utils.ByteArray;
import nme.Memory;
class Level{
    public var width:Int;
    public var height:Int;
    public var base:Int;
    public function new(base:Int,width:Int,height:Int){
        this.base=base;
        this.width=width;
        this.height=height;
    }
}
class Mip{
    public var data:ByteArray;
    public var width:Int;
    public var height:Int;
    public var bitmap:BitmapData;
    public function new(mip:BitmapData){
        width=mip.width;
        height=mip.height;
        bitmap=mip;
    }
    public inline function interp(x:Float,y:Float){
        if(x>=width-1)x=width-1.001;
        else if(x<0)x=0;
        if(y>=height-1)y=height-1.001;
        else if(y<0)y=0;
        var ix=Std.int(x);
        var iy=Std.int(y);
        var fx=x-ix;
        var fy=y-iy;
        var ifx=1-fx;
        var ify=1-fy;
        data.position=(iy*width+ix)<<2;
        var a=data.readByte();
        var r=data.readByte();
        var g=data.readByte();
        var b=data.readByte();
        var a2=data.readByte();
        var r2=data.readByte();
        var g2=data.readByte();
        var b2=data.readByte();
        data.position+=(width-2)<<2;
        var a3=data.readByte();
        var r3=data.readByte();
        var g3=data.readByte();
        var b3=data.readByte();
        var a4=data.readByte();
        var r4=data.readByte();
        var g4=data.readByte();
        var b4=data.readByte();
        var c0=ifx*ify;
        var c1=fx*ify;
        var c2=ifx*fy;
        var c3=fx*fy;
        return argb(a*c0+a2*c1+a3*c2+a4*c3,r*c0+r2*c1+r3*c2+r4*c3,g*c0+g2*c1+g3*c2+g4*c3,b*c0+b2*c1+b3*c2+b4*c3);
    }
    public static inline function weighted(cols:Array<Int>,weights:Array<Float>=null){
        var a=0.0;
        var r=0.0;
        var g=0.0;
        var b=0.0;
        var wsum=0.0;
        for(i in 0...cols.length){
            var c=cols[i];
            var w=weights[i];
            a+=(c>>>24)*w;
            r+=((c>>>16)&0xff)*w;
            g+=((c>>>8)&0xff)*w;
            b+=(c&0xff)*w;
            wsum+=w;
        }
        return argb(a/wsum,r/wsum,g/wsum,b/wsum);
    }
    static inline function argb(a:Float,r:Float,g:Float,b:Float){
        return Std.int(b)|(Std.int(g)<<8)|(Std.int(r)<<16)|(Std.int(a)<<24);
    }
}
class MipMap extends Bitmap{
    public var mips:Array<Mip>;
    public var ratio:Float;
    public var data:ByteArray;
    public var levels:Array<Level>;
    public function new(mips:Array<BitmapData>){
        super();
        this.mips=new Array<Mip>();
        ratio=mips[0].height/mips[0].width;
        for(m in mips)this.mips.push(new Mip(m));
        var length=0;
        for(m in mips)length+=m.width*m.height*3;
        data=new ByteArray(length);
        Memory.select(data);
        levels=new Array<Level>();
        var base=0;
        for(m in mips){
            levels.push(new Level(base,m.width,m.height));
            var dat=m.clone().getVector(m.rect);
            for(c in dat){
                Memory.setByte(base++,(c>>16)&0xff);
                Memory.setByte(base++,(c>>8)&0xff);
                Memory.setByte(base++,c&0xff);
            }
        }
    }
    function setas(level:Level){
        var ret=new ByteArray();
        var ptr=level.base;
        for(i in 0...level.width*level.height){
            ret.writeByte(0xff);
            ret.writeByte(Memory.getByte(ptr++));
            ret.writeByte(Memory.getByte(ptr++));
            ret.writeByte(Memory.getByte(ptr++));
        }
        bitmapData.setPixels(bitmapData.rect,ret);
    }
    function setinterp(level:Level){
        var ret=new ByteArray();
        var row=level.width*3;
        for(y in 0...bitmapData.height){
            var ry=y/bitmapData.height*level.height;
            if(ry>=level.height-1)ry=level.height-1.00001;
            var iy=Std.int(ry);
            var fy=ry-iy;
            var ify=1-fy;
            for(x in 0...bitmapData.width){
                var rx=x/bitmapData.width*level.width;
                if(rx>=level.width-1)rx=level.width-1.00001;
                var ix=Std.int(rx);
                var fx=rx-ix;
                var ifx=1-fx;
                var base=level.base+(iy*level.width+ix)*3;
                ret.writeByte(0xff);
                ret.writeByte((Std.int(((Memory.getByte(base)*ifx+Memory.getByte(base+3)*fx)*ify+(Memory.getByte(base+row)*ifx+Memory.getByte(base+row+3)*fx)*fy))));
                ret.writeByte((Std.int(((Memory.getByte(base+1)*ifx+Memory.getByte(base+1+3)*fx)*ify+(Memory.getByte(base+1+row)*ifx+Memory.getByte(base+1+row+3)*fx)*fy))));
                ret.writeByte((Std.int(((Memory.getByte(base+2)*ifx+Memory.getByte(base+2+3)*fx)*ify+(Memory.getByte(base+2+row)*ifx+Memory.getByte(base+2+row+3)*fx)*fy))));
                base+=3;
            }
        }
        bitmapData.setPixels(bitmapData.rect,ret);
    }
    function setmix(up:Level,down:Level,fw:Float,ifw:Float){
        var ret=new ByteArray();
        var rowu=up.width*3;
        var rowd=down.width*3;
        for(y in 0...bitmapData.height){
            var ury=y/bitmapData.height*up.height;
            if(ury>=up.height-1)ury=up.height-1.00001;
            var uiy=Std.int(ury);
            var ufy=ury-uiy;
            var uify=1-ufy;
            var dry=y/bitmapData.height*down.height;
            if(dry>=down.height-1)dry=down.height-1.00001;
            var diy=Std.int(dry);
            var dfy=dry-diy;
            var dify=1-dfy;
            for(x in 0...bitmapData.width){
                var urx=x/bitmapData.width*up.width;
                if(urx>=up.width-1)urx=up.width-1.00001;
                var uix=Std.int(urx);
                var ufx=urx-uix;
                var uifx=1-ufx;
                var drx=x/bitmapData.width*down.width;
                if(drx>=down.width-1)drx=down.width-1.00001;
                var dix=Std.int(drx);
                var dfx=drx-dix;
                var difx=1-dfx;
                var ubase=up.base+(uiy*up.width+uix)*3;
                var dbase=down.base+(diy*down.width+dix)*3;
                ret.writeByte(0xff);
                ret.writeByte((Std.int(((Memory.getByte(ubase)*uifx+Memory.getByte(ubase+3)*ufx)*uify+(Memory.getByte(ubase+rowu)*uifx+Memory.getByte(ubase+rowu+3)*ufx)*ufy)*fw+((Memory.getByte(dbase)*difx+Memory.getByte(dbase+3)*dfx)*dify+(Memory.getByte(dbase+rowd)*difx+Memory.getByte(dbase+rowd+3)*dfx)*dfy)*ifw)));
                ret.writeByte((Std.int(((Memory.getByte(ubase+1)*uifx+Memory.getByte(ubase+1+3)*ufx)*uify+(Memory.getByte(ubase+1+rowu)*uifx+Memory.getByte(ubase+1+rowu+3)*ufx)*ufy)*fw+((Memory.getByte(dbase+1)*difx+Memory.getByte(dbase+1+3)*dfx)*dify+(Memory.getByte(dbase+1+rowd)*difx+Memory.getByte(dbase+1+rowd+3)*dfx)*dfy)*ifw)));
                ret.writeByte((Std.int(((Memory.getByte(ubase+2)*uifx+Memory.getByte(ubase+2+3)*ufx)*uify+(Memory.getByte(ubase+2+rowu)*uifx+Memory.getByte(ubase+2+rowu+3)*ufx)*ufy)*fw+((Memory.getByte(dbase+2)*difx+Memory.getByte(dbase+2+3)*dfx)*dify+(Memory.getByte(dbase+2+rowd)*difx+Memory.getByte(dbase+2+rowd+3)*dfx)*dfy)*ifw)));
                ubase+=3;
                dbase+=3;
            }
        }
        bitmapData.setPixels(bitmapData.rect,ret);
    }
    public function resize(width:Int,height:Int){
        Memory.select(data);
        bitmapData=new BitmapData(width,height,false,0);
        var up:Level=null;
        var down:Level=null;
        for(level in levels){
            if(level.width==width){
                setas(level);
                return;
            }
            if(width>level.width){
                down=level;
                break;
            }
            up=level;
        }
        if(down==null||up==null){
            var level=levels[0];
            if(width<level.width)level=levels[levels.length-1];
            setinterp(level);
        }
        else{
            var fw=(width-down.width)/(up.width-down.width);
            setmix(up,down,fw,1-fw);
        }
    }
}
