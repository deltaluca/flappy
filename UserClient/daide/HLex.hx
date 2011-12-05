package daide;

	import daide.Tokens;
	class HLexLog {
		public static var logger:String->Void = null;
		public static function log(x:String) {
			logger(x);
		}

		public static function province(x:String) {
			var xs = ((~/[\n\r \t]+/).replace(x," ")).split(" ");
			var val = Std.parseInt(xs[1]);
			if(xs.length==2) return { val:val, sc:false };
			else             return { val:val, sc:xs[2]=="true" };
		}
	}
class HLex {
	static inline var entry_state:Int = 130;
	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([67,67,353]);
transitions.push(cur);
var cur = [];
cur.push([79,79,352]);
transitions.push(cur);
var cur = [];
cur.push([79,79,351]);
transitions.push(cur);
var cur = [];
cur.push([89,89,350]);
transitions.push(cur);
var cur = [];
cur.push([79,79,349]);
transitions.push(cur);
var cur = [];
cur.push([84,84,347]);
cur.push([89,89,348]);
transitions.push(cur);
var cur = [];
cur.push([83,83,346]);
transitions.push(cur);
var cur = [];
cur.push([89,89,345]);
transitions.push(cur);
var cur = [];
cur.push([89,89,341]);
transitions.push(cur);
var cur = [];
cur.push([89,89,339]);
transitions.push(cur);
var cur = [];
cur.push([66,66,337]);
transitions.push(cur);
var cur = [];
cur.push([69,69,336]);
transitions.push(cur);
var cur = [];
cur.push([67,67,334]);
transitions.push(cur);
var cur = [];
cur.push([83,83,333]);
transitions.push(cur);
var cur = [];
cur.push([70,70,332]);
transitions.push(cur);
var cur = [];
cur.push([75,75,331]);
transitions.push(cur);
var cur = [];
cur.push([87,87,330]);
transitions.push(cur);
var cur = [];
cur.push([82,82,329]);
transitions.push(cur);
var cur = [];
cur.push([84,84,328]);
transitions.push(cur);
var cur = [];
cur.push([68,68,327]);
transitions.push(cur);
var cur = [];
cur.push([80,80,326]);
transitions.push(cur);
var cur = [];
cur.push([83,83,325]);
transitions.push(cur);
var cur = [];
cur.push([90,90,324]);
transitions.push(cur);
var cur = [];
cur.push([88,88,323]);
transitions.push(cur);
var cur = [];
cur.push([68,68,322]);
transitions.push(cur);
var cur = [];
cur.push([89,89,321]);
transitions.push(cur);
var cur = [];
cur.push([79,79,319]);
cur.push([84,84,354]);
transitions.push(cur);
var cur = [];
cur.push([76,76,317]);
transitions.push(cur);
var cur = [];
cur.push([65,65,316]);
transitions.push(cur);
var cur = [];
cur.push([66,66,314]);
cur.push([82,82,315]);
transitions.push(cur);
var cur = [];
cur.push([84,84,312]);
transitions.push(cur);
var cur = [];
cur.push([76,76,311]);
transitions.push(cur);
var cur = [];
cur.push([82,82,310]);
transitions.push(cur);
var cur = [];
cur.push([76,76,309]);
transitions.push(cur);
var cur = [];
cur.push([65,65,308]);
transitions.push(cur);
var cur = [];
cur.push([82,82,307]);
transitions.push(cur);
var cur = [];
cur.push([77,77,306]);
transitions.push(cur);
var cur = [];
cur.push([83,83,305]);
transitions.push(cur);
var cur = [];
cur.push([69,69,304]);
transitions.push(cur);
var cur = [];
cur.push([75,75,343]);
cur.push([78,78,344]);
cur.push([88,88,303]);
transitions.push(cur);
var cur = [];
cur.push([69,69,302]);
transitions.push(cur);
var cur = [];
cur.push([68,68,300]);
transitions.push(cur);
var cur = [];
cur.push([79,79,299]);
transitions.push(cur);
var cur = [];
cur.push([78,78,296]);
cur.push([80,80,338]);
transitions.push(cur);
var cur = [];
cur.push([84,84,295]);
transitions.push(cur);
var cur = [];
cur.push([68,68,294]);
cur.push([82,82,335]);
transitions.push(cur);
var cur = [];
cur.push([70,70,293]);
transitions.push(cur);
var cur = [];
cur.push([83,83,292]);
transitions.push(cur);
var cur = [];
cur.push([84,84,290]);
cur.push([87,87,291]);
transitions.push(cur);
var cur = [];
cur.push([83,83,288]);
transitions.push(cur);
var cur = [];
cur.push([70,70,287]);
transitions.push(cur);
var cur = [];
cur.push([80,80,286]);
transitions.push(cur);
var cur = [];
cur.push([68,68,285]);
transitions.push(cur);
var cur = [];
cur.push([77,77,284]);
transitions.push(cur);
var cur = [];
cur.push([72,72,283]);
transitions.push(cur);
var cur = [];
cur.push([70,70,280]);
transitions.push(cur);
var cur = [];
cur.push([77,77,279]);
transitions.push(cur);
var cur = [];
cur.push([87,87,278]);
transitions.push(cur);
var cur = [];
cur.push([68,68,277]);
cur.push([76,76,355]);
transitions.push(cur);
var cur = [];
cur.push([78,78,276]);
transitions.push(cur);
var cur = [];
cur.push([84,84,275]);
transitions.push(cur);
var cur = [];
cur.push([82,82,272]);
transitions.push(cur);
var cur = [];
cur.push([67,67,271]);
transitions.push(cur);
var cur = [];
cur.push([83,83,270]);
transitions.push(cur);
var cur = [];
cur.push([67,67,269]);
transitions.push(cur);
var cur = [];
cur.push([68,68,340]);
cur.push([79,79,298]);
cur.push([83,83,268]);
transitions.push(cur);
var cur = [];
cur.push([67,67,267]);
transitions.push(cur);
var cur = [];
cur.push([83,83,266]);
transitions.push(cur);
var cur = [];
cur.push([67,67,265]);
transitions.push(cur);
var cur = [];
cur.push([83,83,264]);
transitions.push(cur);
var cur = [];
cur.push([84,84,259]);
transitions.push(cur);
var cur = [];
cur.push([67,67,258]);
transitions.push(cur);
var cur = [];
cur.push([67,67,256]);
transitions.push(cur);
var cur = [];
cur.push([85,85,255]);
transitions.push(cur);
var cur = [];
cur.push([82,82,254]);
transitions.push(cur);
var cur = [];
cur.push([65,65,249]);
cur.push([67,67,250]);
cur.push([70,70,251]);
cur.push([79,79,262]);
cur.push([80,80,252]);
cur.push([85,85,253]);
transitions.push(cur);
var cur = [];
cur.push([78,78,247]);
cur.push([83,83,248]);
transitions.push(cur);
var cur = [];
cur.push([66,66,245]);
cur.push([69,69,289]);
cur.push([82,82,246]);
transitions.push(cur);
var cur = [];
cur.push([82,82,356]);
cur.push([83,83,244]);
transitions.push(cur);
var cur = [];
cur.push([67,67,243]);
cur.push([84,84,282]);
transitions.push(cur);
var cur = [];
cur.push([76,76,274]);
cur.push([82,82,242]);
transitions.push(cur);
var cur = [];
cur.push([67,67,241]);
transitions.push(cur);
var cur = [];
cur.push([84,84,240]);
transitions.push(cur);
var cur = [];
cur.push([82,82,239]);
transitions.push(cur);
var cur = [];
cur.push([86,86,238]);
transitions.push(cur);
var cur = [];
cur.push([69,69,237]);
transitions.push(cur);
var cur = [];
cur.push([74,74,297]);
cur.push([77,77,236]);
cur.push([84,84,263]);
transitions.push(cur);
var cur = [];
cur.push([68,68,235]);
transitions.push(cur);
var cur = [];
cur.push([76,76,318]);
cur.push([79,79,234]);
transitions.push(cur);
var cur = [];
cur.push([66,66,233]);
cur.push([68,68,320]);
cur.push([82,82,260]);
transitions.push(cur);
var cur = [];
cur.push([65,65,232]);
transitions.push(cur);
var cur = [];
cur.push([66,66,301]);
cur.push([67,67,257]);
cur.push([71,71,342]);
cur.push([77,77,273]);
cur.push([80,80,231]);
transitions.push(cur);
var cur = [];
cur.push([76,76,313]);
cur.push([79,79,230]);
transitions.push(cur);
var cur = [];
cur.push([68,68,229]);
cur.push([79,79,281]);
transitions.push(cur);
var cur = [];
cur.push([89,89,228]);
transitions.push(cur);
var cur = [];
cur.push([79,79,227]);
transitions.push(cur);
var cur = [];
cur.push([68,68,261]);
cur.push([84,84,226]);
transitions.push(cur);
var cur = [];
cur.push([89,89,225]);
transitions.push(cur);
var cur = [];
cur.push([49,57,222]);
cur.push([48,48,224]);
transitions.push(cur);
var cur = [];
cur.push([48,57,223]);
cur.push([65,70,223]);
cur.push([97,102,223]);
transitions.push(cur);
var cur = [];
cur.push([101,101,221]);
transitions.push(cur);
var cur = [];
cur.push([49,57,218]);
cur.push([48,48,220]);
transitions.push(cur);
var cur = [];
cur.push([48,57,219]);
cur.push([65,70,219]);
cur.push([97,102,219]);
transitions.push(cur);
var cur = [];
cur.push([101,101,217]);
transitions.push(cur);
var cur = [];
cur.push([49,57,214]);
cur.push([48,48,216]);
transitions.push(cur);
var cur = [];
cur.push([48,57,215]);
cur.push([65,70,215]);
cur.push([97,102,215]);
transitions.push(cur);
var cur = [];
cur.push([101,101,213]);
transitions.push(cur);
var cur = [];
cur.push([49,57,210]);
cur.push([48,48,212]);
transitions.push(cur);
var cur = [];
cur.push([48,57,211]);
cur.push([65,70,211]);
cur.push([97,102,211]);
transitions.push(cur);
var cur = [];
cur.push([101,101,209]);
transitions.push(cur);
var cur = [];
cur.push([49,57,202]);
cur.push([48,48,204]);
transitions.push(cur);
var cur = [];
cur.push([48,57,203]);
cur.push([65,70,203]);
cur.push([97,102,203]);
transitions.push(cur);
var cur = [];
cur.push([1,9,115]);
cur.push([11,12,115]);
cur.push([14,128,115]);
transitions.push(cur);
var cur = [];
cur.push([1,9,114]);
cur.push([11,12,114]);
cur.push([14,128,114]);
transitions.push(cur);
var cur = [];
cur.push([1,9,114]);
cur.push([11,12,114]);
cur.push([14,38,114]);
cur.push([40,91,114]);
cur.push([93,128,114]);
cur.push([39,39,205]);
cur.push([92,92,113]);
transitions.push(cur);
var cur = [];
cur.push([1,9,115]);
cur.push([11,12,115]);
cur.push([14,33,115]);
cur.push([35,91,115]);
cur.push([93,128,115]);
cur.push([34,34,205]);
cur.push([92,92,112]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
transitions.push(cur);
var cur = [];
cur.push([9,10,122]);
cur.push([13,13,122]);
cur.push([32,32,122]);
transitions.push(cur);
var cur = [];
cur.push([9,10,121]);
cur.push([13,13,121]);
cur.push([32,32,121]);
transitions.push(cur);
var cur = [];
cur.push([9,10,121]);
cur.push([13,13,121]);
cur.push([32,32,121]);
cur.push([40,40,208]);
cur.push([43,43,208]);
cur.push([47,93,208]);
transitions.push(cur);
var cur = [];
cur.push([9,10,122]);
cur.push([13,13,122]);
cur.push([32,32,122]);
cur.push([43,43,98]);
cur.push([45,45,98]);
cur.push([49,57,222]);
cur.push([48,48,224]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([43,43,101]);
cur.push([45,45,101]);
cur.push([49,57,218]);
cur.push([48,48,220]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([43,43,104]);
cur.push([45,45,104]);
cur.push([49,57,214]);
cur.push([48,48,216]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([43,43,107]);
cur.push([45,45,107]);
cur.push([49,57,210]);
cur.push([48,48,212]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([102,102,159]);
cur.push([116,116,184]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([102,102,160]);
cur.push([116,116,183]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([102,102,161]);
cur.push([116,116,182]);
transitions.push(cur);
var cur = [];
cur.push([9,10,129]);
cur.push([13,13,129]);
cur.push([32,32,129]);
cur.push([102,102,162]);
cur.push([116,116,181]);
transitions.push(cur);
var cur = [];
cur.push([9,10,199]);
cur.push([13,13,199]);
cur.push([32,32,199]);
cur.push([34,34,115]);
cur.push([39,39,114]);
cur.push([40,40,206]);
cur.push([41,41,207]);
cur.push([43,43,110]);
cur.push([45,45,110]);
cur.push([48,48,201]);
cur.push([49,57,202]);
cur.push([65,65,143]);
cur.push([66,66,140]);
cur.push([67,67,139]);
cur.push([68,68,149]);
cur.push([69,69,141]);
cur.push([70,70,133]);
cur.push([71,71,151]);
cur.push([72,72,148]);
cur.push([73,73,134]);
cur.push([76,76,152]);
cur.push([77,77,131]);
cur.push([78,78,132]);
cur.push([79,79,135]);
cur.push([80,80,136]);
cur.push([81,81,153]);
cur.push([82,82,145]);
cur.push([83,83,137]);
cur.push([84,84,146]);
cur.push([85,85,150]);
cur.push([86,86,147]);
cur.push([87,87,138]);
cur.push([88,88,144]);
cur.push([89,89,142]);
cur.push([98,98,168]);
cur.push([99,99,179]);
cur.push([105,105,176]);
cur.push([112,112,178]);
cur.push([115,115,167]);
transitions.push(cur);
var cur = [];
cur.push([65,65,51]);
cur.push([66,66,84]);
cur.push([68,68,50]);
cur.push([73,73,49]);
cur.push([82,82,30]);
cur.push([84,84,92]);
transitions.push(cur);
var cur = [];
cur.push([65,65,78]);
cur.push([67,67,69]);
cur.push([69,69,68]);
cur.push([77,77,77]);
cur.push([79,79,48]);
cur.push([80,80,29]);
cur.push([82,82,76]);
cur.push([83,83,75]);
cur.push([86,86,74]);
cur.push([87,87,62]);
cur.push([89,89,73]);
transitions.push(cur);
var cur = [];
cur.push([65,65,80]);
cur.push([67,67,18]);
cur.push([76,76,96]);
cur.push([79,79,17]);
cur.push([82,82,56]);
cur.push([87,87,19]);
transitions.push(cur);
var cur = [];
cur.push([65,65,53]);
cur.push([68,68,15]);
cur.push([70,70,14]);
cur.push([78,78,13]);
transitions.push(cur);
var cur = [];
cur.push([66,66,47]);
cur.push([67,67,12]);
cur.push([70,70,46]);
cur.push([82,82,45]);
cur.push([85,85,44]);
transitions.push(cur);
var cur = [];
cur.push([67,67,11]);
cur.push([68,68,28]);
cur.push([79,79,10]);
cur.push([82,82,43]);
cur.push([84,84,27]);
transitions.push(cur);
var cur = [];
cur.push([67,67,65]);
cur.push([69,69,66]);
cur.push([76,76,42]);
cur.push([77,77,35]);
cur.push([78,78,41]);
cur.push([80,80,61]);
cur.push([82,82,8]);
cur.push([85,85,91]);
cur.push([86,86,40]);
cur.push([87,87,64]);
transitions.push(cur);
var cur = [];
cur.push([67,67,63]);
cur.push([72,72,5]);
cur.push([73,73,59]);
cur.push([86,86,85]);
transitions.push(cur);
var cur = [];
cur.push([67,67,58]);
cur.push([72,72,1]);
cur.push([83,83,82]);
cur.push([84,84,95]);
cur.push([85,85,70]);
cur.push([86,86,94]);
transitions.push(cur);
var cur = [];
cur.push([67,67,0]);
cur.push([76,76,87]);
cur.push([78,78,71]);
cur.push([80,80,83]);
cur.push([84,84,33]);
cur.push([87,87,23]);
transitions.push(cur);
var cur = [];
cur.push([67,67,67]);
cur.push([76,76,21]);
cur.push([82,82,32]);
cur.push([83,83,81]);
cur.push([88,88,20]);
transitions.push(cur);
var cur = [];
cur.push([68,68,2]);
cur.push([69,69,37]);
cur.push([83,83,72]);
transitions.push(cur);
var cur = [];
cur.push([68,68,36]);
cur.push([76,76,25]);
cur.push([77,77,97]);
cur.push([78,78,24]);
cur.push([79,79,34]);
cur.push([85,85,60]);
transitions.push(cur);
var cur = [];
cur.push([68,68,4]);
cur.push([79,79,3]);
transitions.push(cur);
var cur = [];
cur.push([69,69,86]);
cur.push([84,84,88]);
transitions.push(cur);
var cur = [];
cur.push([72,72,39]);
cur.push([77,77,38]);
cur.push([82,82,7]);
transitions.push(cur);
var cur = [];
cur.push([73,73,90]);
cur.push([83,83,6]);
transitions.push(cur);
var cur = [];
cur.push([76,76,93]);
cur.push([79,79,16]);
cur.push([83,83,79]);
cur.push([85,85,54]);
transitions.push(cur);
var cur = [];
cur.push([77,77,22]);
cur.push([82,82,57]);
cur.push([83,83,89]);
transitions.push(cur);
var cur = [];
cur.push([78,78,26]);
transitions.push(cur);
var cur = [];
cur.push([79,79,55]);
transitions.push(cur);
var cur = [];
cur.push([79,79,52]);
cur.push([86,86,31]);
transitions.push(cur);
var cur = [];
cur.push([82,82,9]);
transitions.push(cur);
var cur = [];
cur.push([97,97,187]);
transitions.push(cur);
var cur = [];
cur.push([97,97,186]);
transitions.push(cur);
var cur = [];
cur.push([97,97,177]);
transitions.push(cur);
var cur = [];
cur.push([97,97,175]);
transitions.push(cur);
var cur = [];
cur.push([97,97,174]);
transitions.push(cur);
var cur = [];
cur.push([97,97,172]);
transitions.push(cur);
var cur = [];
cur.push([97,97,171]);
transitions.push(cur);
var cur = [];
cur.push([97,97,170]);
transitions.push(cur);
var cur = [];
cur.push([97,97,169]);
transitions.push(cur);
var cur = [];
cur.push([97,97,117]);
transitions.push(cur);
var cur = [];
cur.push([99,99,180]);
transitions.push(cur);
var cur = [];
cur.push([100,100,116]);
transitions.push(cur);
var cur = [];
cur.push([101,101,185]);
transitions.push(cur);
var cur = [];
cur.push([101,101,163]);
transitions.push(cur);
var cur = [];
cur.push([105,105,164]);
transitions.push(cur);
var cur = [];
cur.push([108,108,191]);
transitions.push(cur);
var cur = [];
cur.push([108,108,190]);
transitions.push(cur);
var cur = [];
cur.push([108,108,189]);
transitions.push(cur);
var cur = [];
cur.push([108,108,188]);
transitions.push(cur);
var cur = [];
cur.push([108,108,156]);
transitions.push(cur);
var cur = [];
cur.push([108,108,119]);
transitions.push(cur);
var cur = [];
cur.push([108,108,118]);
transitions.push(cur);
var cur = [];
cur.push([110,110,173]);
transitions.push(cur);
var cur = [];
cur.push([110,110,165]);
transitions.push(cur);
var cur = [];
cur.push([111,111,198]);
transitions.push(cur);
var cur = [];
cur.push([111,111,155]);
transitions.push(cur);
var cur = [];
cur.push([111,111,154]);
transitions.push(cur);
var cur = [];
cur.push([114,114,197]);
transitions.push(cur);
var cur = [];
cur.push([114,114,196]);
transitions.push(cur);
var cur = [];
cur.push([114,114,195]);
transitions.push(cur);
var cur = [];
cur.push([114,114,194]);
transitions.push(cur);
var cur = [];
cur.push([114,114,120]);
transitions.push(cur);
var cur = [];
cur.push([115,115,193]);
transitions.push(cur);
var cur = [];
cur.push([115,115,192]);
transitions.push(cur);
var cur = [];
cur.push([115,115,109]);
transitions.push(cur);
var cur = [];
cur.push([115,115,106]);
transitions.push(cur);
var cur = [];
cur.push([115,115,103]);
transitions.push(cur);
var cur = [];
cur.push([115,115,100]);
transitions.push(cur);
var cur = [];
cur.push([116,116,158]);
transitions.push(cur);
var cur = [];
cur.push([116,116,157]);
transitions.push(cur);
var cur = [];
cur.push([117,117,109]);
transitions.push(cur);
var cur = [];
cur.push([117,117,106]);
transitions.push(cur);
var cur = [];
cur.push([117,117,103]);
transitions.push(cur);
var cur = [];
cur.push([117,117,100]);
transitions.push(cur);
var cur = [];
cur.push([119,119,166]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([49,57,202]);
cur.push([48,48,200]);
transitions.push(cur);
var cur = [];
cur.push([49,57,202]);
cur.push([48,48,200]);
cur.push([120,120,111]);
transitions.push(cur);
var cur = [];
cur.push([48,57,202]);
transitions.push(cur);
var cur = [];
cur.push([48,57,203]);
cur.push([65,70,203]);
cur.push([97,102,203]);
transitions.push(cur);
var cur = [];
cur.push([48,57,202]);
cur.push([120,120,111]);
transitions.push(cur);
transitions.push(null);
transitions.push(null);
transitions.push(null);
var cur = [];
cur.push([40,40,208]);
cur.push([43,43,208]);
cur.push([47,93,208]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,210]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,211]);
cur.push([65,70,211]);
cur.push([97,102,211]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,210]);
cur.push([120,120,108]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,214]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,215]);
cur.push([65,70,215]);
cur.push([97,102,215]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,214]);
cur.push([120,120,105]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,218]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,219]);
cur.push([65,70,219]);
cur.push([97,102,219]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,218]);
cur.push([120,120,102]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,129]);
cur.push([13,13,129]);
cur.push([32,32,129]);
cur.push([48,57,222]);
transitions.push(cur);
var cur = [];
cur.push([9,10,129]);
cur.push([13,13,129]);
cur.push([32,32,129]);
cur.push([48,57,223]);
cur.push([65,70,223]);
cur.push([97,102,223]);
transitions.push(cur);
var cur = [];
cur.push([9,10,129]);
cur.push([13,13,129]);
cur.push([32,32,129]);
cur.push([48,57,222]);
cur.push([120,120,99]);
transitions.push(cur);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
transitions.push(null);
}
        static var accepting = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false].concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]);
	public static function lexify(input:String):Array<Token> {
		init();
var ret = new Array<Token>();
var valid = false;
var valcnt = 0;
var attr = 0;
var errstate = false;
var errstr:String = null;

var state = entry_state;
var pos = 0;
var ipos = pos;

while(pos<input.length) {
	//evaluate next state to progress to.
	var trans = transitions[state];
	var char = input.charCodeAt(pos);

	state = -1;
	if(trans!=null){
		for(range in trans) {
			if(char>=range[0] && char<=range[1]) {
				state = range[2];
				break;
			}
		}
	}

	if(state==-1) {
		//ERROR?
		if(!valid) {
			if(!errstate) {
				if(errstr==null) errstr = input.charAt(ipos);
				else errstr += input.charAt(ipos);
			}else errstr += String.fromCharCode(char);
			pos = ipos + 1;
		}else {
			if(errstr!=null) {
				var tok = errtok(errstr);
				if(tok!=null) ret.push(tok);
				errstr = null;
			}
			var tok = tokenof(attr,input.substr(ipos,valcnt));
			if(tok!=null) ret.push(tok);
			pos = ipos+valcnt;
		}
		errstate = !valid;
		state = entry_state;
		valid = false;
		ipos = pos;
	}else {
		pos++;
		errstate = false;
	}

	if(accepting[state]) {
		valid = true;
		valcnt = pos-ipos;
		attr = state;
	}else if(pos==input.length) {
		if(!valid) {
			if(!errstate) {
				if(errstr==null) errstr = input.charAt(ipos);
				else errstr += input.charAt(ipos);
			}
			var tok = tokenof(attr,input.substr(ipos,valcnt));
			if(tok!=null) ret.push(tok);
			pos = ipos+valcnt;
		}
		errstate = !valid;
		state = entry_state;
		valid = false;
		ipos = pos;
	}
}

if(ipos<input.length) {
	if(!valid) ret.push(errtok(input.substr(ipos)));
	else {
		if(errstr!=null) {
			var tok = errtok(errstr);
			if(tok!=null) ret.push(tok);
			errstr = null;
		}
		var tok = tokenof(attr,input.substr(ipos,valcnt));
		if(tok!=null) ret.push(tok);
		pos = ipos+valcnt;
	}
}

if(errstr!=null) {
	var tok = errtok(errstr);
	if(tok!=null) ret.push(tok);
	errstr = null;
}

return ret;
}
	static inline function errtok(hxl_match:String):Token {
return ({ HLexLog.log("Error: Unknown char sequence '"+ hxl_match +"'"); null; });
	}
	static function tokenof(id:Int, hxl_match:String):Token {
		switch(id) {
			default: return null;
            case 200:
				return ({ tZero; });
            case 201:
				return ({ tZero; });
            case 202:
				return ({ tNonZero(Std.parseInt( hxl_match )); });
            case 203:
				return ({ tNonZero(Std.parseInt( hxl_match )); });
            case 204:
				return ({ tNonZero(Std.parseInt( hxl_match )); });
            case 205:
				return ({ tText( hxl_match .substr(1, hxl_match .length-2)); });
            case 206:
				return ({ tLeftParen;  });
            case 207:
				return ({ tRightParen; });
            case 208:
				return ({
	var xs = ((~/[\n\r \t]+/).replace( hxl_match ," ")).split(" ");
	tPower(Std.parseInt(xs[1]));
});
            case 209:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 210:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 211:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 212:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 213:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 214:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 215:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 216:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 217:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 218:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 219:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 220:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 221:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 222:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 223:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 224:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 225:
				return ({ tUnitType(utArmy);  });
            case 226:
				return ({ tUnitType(utFleet); });
            case 227:
				return ({ tOrder(oMoveByConvoy); });
            case 228:
				return ({ tOrder(oConvoy); });
            case 229:
				return ({ tOrder(oHold); });
            case 230:
				return ({ tOrder(oMove); });
            case 231:
				return ({ tOrder(oSupport); });
            case 232:
				return ({ tOrder(oVia); });
            case 233:
				return ({ tOrder(oDisband); });
            case 234:
				return ({ tOrder(oRetreat); });
            case 235:
				return ({ tOrder(oBuild); });
            case 236:
				return ({ tOrder(oRemove); });
            case 237:
				return ({ tOrder(oWaive); });
            case 238:
				return ({ tOrderNote(onOkay); });
            case 239:
				return ({ tOrderNote(onBPR); });
            case 240:
				return ({ tOrderNote(onNoCoastSpecified); });
            case 241:
				return ({ tOrderNote(onNotEmptySupply); });
            case 242:
				return ({ tOrderNote(onNotAdjacent); });
            case 243:
				return ({ tOrderNote(onNotHomeSupply); });
            case 244:
				return ({ tOrderNote(onNotAtSea); });
            case 245:
				return ({ tOrderNote(onNoMoreBuilds); });
            case 246:
				return ({ tOrderNote(onNoMoreRemovals); });
            case 247:
				return ({ tOrderNote(onNoRetreatNeeded); });
            case 248:
				return ({ tOrderNote(onNotRightSeason); });
            case 249:
				return ({ tOrderNote(onNoSuchArmy); });
            case 250:
				return ({ tOrderNote(onNotSupply); });
            case 251:
				return ({ tOrderNote(onNoSuchFleet); });
            case 252:
				return ({ tOrderNote(onNoSuchProvince); });
            case 253:
				return ({ tOrderNote(onNoSuchUnit); });
            case 254:
				return ({ tOrderNote(onNotValidRetreat); });
            case 255:
				return ({ tOrderNote(onNotYourUnit); });
            case 256:
				return ({ tOrderNote(onNotYourSupply); });
            case 257:
				return ({ tResult(rSuccess); });
            case 258:
				return ({ tResult(rMoveBounced); });
            case 259:
				return ({ tResult(rSupportCut); });
            case 260:
				return ({ tResult(rConvoyDisrupted); });
            case 261:
				return ({ tResult(rFLD); });
            case 262:
				return ({ tResult(rNoSuchOrder); });
            case 263:
				return ({ tResult(rDislodged); });
            case 264:
				return ({ tCoast(cNorth); });
            case 265:
				return ({ tCoast(cNorthEast); });
            case 266:
				return ({ tCoast(cEast); });
            case 267:
				return ({ tCoast(cSouthEast); });
            case 268:
				return ({ tCoast(cSouth); });
            case 269:
				return ({ tCoast(cSouthWest); });
            case 270:
				return ({ tCoast(cWest); });
            case 271:
				return ({ tCoast(cNorthWest); });
            case 272:
				return ({ tPhase(pSpring); });
            case 273:
				return ({ tPhase(pSummer); });
            case 274:
				return ({ tPhase(pFall); });
            case 275:
				return ({ tPhase(pAutumn); });
            case 276:
				return ({ tPhase(pWinter); });
            case 277:
				return ({ tCommand(coPowerInCivilDisorder); });
            case 278:
				return ({ tCommand(coDraw); });
            case 279:
				return ({ tCommand(coMessageFrom); });
            case 280:
				return ({ tCommand(coGoFlag); });
            case 281:
				return ({ tCommand(coHello); });
            case 282:
				return ({ tCommand(coHistory); });
            case 283:
				return ({ tCommand(coHuh); });
            case 284:
				return ({ tCommand(coIAm); });
            case 285:
				return ({ tCommand(coLoadGame); });
            case 286:
				return ({ tCommand(coMap); });
            case 287:
				return ({ tCommand(coMapDefinition); });
            case 288:
				return ({ tCommand(coMissingOrders); });
            case 289:
				return ({ tCommand(coName); });
            case 290:
				return ({ tCommand(coNOT); });
            case 291:
				return ({ tCommand(coCurrentPosition); });
            case 292:
				return ({ tCommand(coObserver); });
            case 293:
				return ({ tCommand(coTurnOff); });
            case 294:
				return ({ tCommand(coOrderResult); });
            case 295:
				return ({ tCommand(coPowerEliminated); });
            case 296:
				return ({ tCommand(coParenthesisError); });
            case 297:
				return ({ tCommand(coReject); });
            case 298:
				return ({ tCommand(coSupplyOwnership); });
            case 299:
				return ({ tCommand(coSolo); });
            case 300:
				return ({ tCommand(coSendMessage); });
            case 301:
				return ({ tCommand(coSubmitOrder); });
            case 302:
				return ({ tCommand(coSaveGame); });
            case 303:
				return ({ tCommand(coThink); });
            case 304:
				return ({ tCommand(coTimeToDeadline); });
            case 305:
				return ({ tCommand(coAccept); });
            case 306:
				return ({ tCommand(coAdmin); });
            case 307:
				return ({ tCommand(coSMR); });
            case 308:
				return ({ tParameter(paAnyOrder); });
            case 309:
				return ({ tParameter(paBuildTimeLimit); });
            case 310:
				return ({ tParameter(paLocationError); });
            case 311:
				return ({ tParameter(paLevel); });
            case 312:
				return ({ tParameter(paMustRetreat); });
            case 313:
				return ({ tParameter(paMoveTimeLimit); });
            case 314:
				return ({ tParameter(paNoPressDuringBuild); });
            case 315:
				return ({ tParameter(paNoPressDuringRetreat); });
            case 316:
				return ({ tParameter(paPartialDrawsAllowed); });
            case 317:
				return ({ tParameter(paPressTimeLimit); });
            case 318:
				return ({ tParameter(paRetreatTimeLimit); });
            case 319:
				return ({ tParameter(paUnowned); });
            case 320:
				return ({ tParameter(paDeadlineDisconnect); });
            case 321:
				return ({ tPress(prAlly); });
            case 322:
				return ({ tPress(prAND); });
            case 323:
				return ({ tPress(prNoneOfYourBusiness); });
            case 324:
				return ({ tPress(prDemiliterisedZone); });
            case 325:
				return ({ tPress(prELSE); });
            case 326:
				return ({ tPress(prExplain); });
            case 327:
				return ({ tPress(prRequestForward); });
            case 328:
				return ({ tPress(prFact); });
            case 329:
				return ({ tPress(prForTurn); });
            case 330:
				return ({ tPress(prHowToAttack); });
            case 331:
				return ({ tPress(prIDontKnow); });
            case 332:
				return ({ tPress(prIF); });
            case 333:
				return ({ tPress(prInsist); });
            case 334:
				return ({ tPress(prOccupy); });
            case 335:
				return ({ tPress(prOR); });
            case 336:
				return ({ tPress(prPeace); });
            case 337:
				return ({ tPress(prPosition); });
            case 338:
				return ({ tPress(prPropose); });
            case 339:
				return ({ tPress(prQuery); });
            case 340:
				return ({ tPress(prSupplyDistro); });
            case 341:
				return ({ tPress(prSorry); });
            case 342:
				return ({ tPress(prSuggest); });
            case 343:
				return ({ tPress(prThink); });
            case 344:
				return ({ tPress(prThen); });
            case 345:
				return ({ tPress(prTry); });
            case 346:
				return ({ tPress(prVersus); });
            case 347:
				return ({ tPress(prWhat); });
            case 348:
				return ({ tPress(prWhy); });
            case 349:
				return ({ tPress(prDo); });
            case 350:
				return ({ tPress(prOwes); });
            case 351:
				return ({ tPress(prTellMe); });
            case 352:
				return ({ tPress(prChoose); });
            case 353:
				return ({ tPress(prBCC); });
            case 354:
				return ({ tPress(prUNT); });
            case 355:
				return ({ tPress(prCCL); });
            case 356:
				return ({ tPress(prNAR); });
        }
	}
}
