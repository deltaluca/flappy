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
		static inline var entry_state:Int = 129;

	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([67,67,349]);
transitions.push(cur);
var cur = [];
cur.push([79,79,348]);
transitions.push(cur);
var cur = [];
cur.push([79,79,347]);
transitions.push(cur);
var cur = [];
cur.push([89,89,346]);
transitions.push(cur);
var cur = [];
cur.push([79,79,345]);
transitions.push(cur);
var cur = [];
cur.push([84,84,343]);
cur.push([89,89,344]);
transitions.push(cur);
var cur = [];
cur.push([83,83,342]);
transitions.push(cur);
var cur = [];
cur.push([89,89,341]);
transitions.push(cur);
var cur = [];
cur.push([89,89,337]);
transitions.push(cur);
var cur = [];
cur.push([89,89,335]);
transitions.push(cur);
var cur = [];
cur.push([66,66,333]);
transitions.push(cur);
var cur = [];
cur.push([69,69,332]);
transitions.push(cur);
var cur = [];
cur.push([67,67,330]);
transitions.push(cur);
var cur = [];
cur.push([83,83,329]);
transitions.push(cur);
var cur = [];
cur.push([70,70,328]);
transitions.push(cur);
var cur = [];
cur.push([75,75,327]);
transitions.push(cur);
var cur = [];
cur.push([87,87,326]);
transitions.push(cur);
var cur = [];
cur.push([82,82,325]);
transitions.push(cur);
var cur = [];
cur.push([84,84,324]);
transitions.push(cur);
var cur = [];
cur.push([68,68,323]);
transitions.push(cur);
var cur = [];
cur.push([80,80,322]);
transitions.push(cur);
var cur = [];
cur.push([83,83,321]);
transitions.push(cur);
var cur = [];
cur.push([90,90,320]);
transitions.push(cur);
var cur = [];
cur.push([88,88,319]);
transitions.push(cur);
var cur = [];
cur.push([68,68,318]);
transitions.push(cur);
var cur = [];
cur.push([89,89,317]);
transitions.push(cur);
var cur = [];
cur.push([79,79,315]);
cur.push([84,84,350]);
transitions.push(cur);
var cur = [];
cur.push([76,76,313]);
transitions.push(cur);
var cur = [];
cur.push([65,65,312]);
transitions.push(cur);
var cur = [];
cur.push([66,66,310]);
cur.push([82,82,311]);
transitions.push(cur);
var cur = [];
cur.push([84,84,308]);
transitions.push(cur);
var cur = [];
cur.push([76,76,307]);
transitions.push(cur);
var cur = [];
cur.push([82,82,306]);
transitions.push(cur);
var cur = [];
cur.push([76,76,305]);
transitions.push(cur);
var cur = [];
cur.push([65,65,304]);
transitions.push(cur);
var cur = [];
cur.push([77,77,303]);
transitions.push(cur);
var cur = [];
cur.push([83,83,302]);
transitions.push(cur);
var cur = [];
cur.push([69,69,301]);
transitions.push(cur);
var cur = [];
cur.push([75,75,339]);
cur.push([78,78,340]);
cur.push([88,88,300]);
transitions.push(cur);
var cur = [];
cur.push([69,69,299]);
transitions.push(cur);
var cur = [];
cur.push([68,68,297]);
transitions.push(cur);
var cur = [];
cur.push([79,79,296]);
transitions.push(cur);
var cur = [];
cur.push([78,78,293]);
cur.push([80,80,334]);
transitions.push(cur);
var cur = [];
cur.push([84,84,292]);
transitions.push(cur);
var cur = [];
cur.push([68,68,291]);
cur.push([82,82,331]);
transitions.push(cur);
var cur = [];
cur.push([70,70,290]);
transitions.push(cur);
var cur = [];
cur.push([83,83,289]);
transitions.push(cur);
var cur = [];
cur.push([84,84,287]);
cur.push([87,87,288]);
transitions.push(cur);
var cur = [];
cur.push([83,83,285]);
transitions.push(cur);
var cur = [];
cur.push([70,70,284]);
transitions.push(cur);
var cur = [];
cur.push([80,80,283]);
transitions.push(cur);
var cur = [];
cur.push([68,68,282]);
transitions.push(cur);
var cur = [];
cur.push([77,77,281]);
transitions.push(cur);
var cur = [];
cur.push([72,72,280]);
transitions.push(cur);
var cur = [];
cur.push([70,70,277]);
transitions.push(cur);
var cur = [];
cur.push([77,77,276]);
transitions.push(cur);
var cur = [];
cur.push([87,87,275]);
transitions.push(cur);
var cur = [];
cur.push([68,68,274]);
transitions.push(cur);
var cur = [];
cur.push([78,78,273]);
transitions.push(cur);
var cur = [];
cur.push([84,84,272]);
transitions.push(cur);
var cur = [];
cur.push([82,82,269]);
transitions.push(cur);
var cur = [];
cur.push([67,67,268]);
transitions.push(cur);
var cur = [];
cur.push([83,83,267]);
transitions.push(cur);
var cur = [];
cur.push([67,67,266]);
transitions.push(cur);
var cur = [];
cur.push([68,68,336]);
cur.push([79,79,295]);
cur.push([83,83,265]);
transitions.push(cur);
var cur = [];
cur.push([67,67,264]);
transitions.push(cur);
var cur = [];
cur.push([83,83,263]);
transitions.push(cur);
var cur = [];
cur.push([67,67,262]);
transitions.push(cur);
var cur = [];
cur.push([83,83,261]);
transitions.push(cur);
var cur = [];
cur.push([84,84,256]);
transitions.push(cur);
var cur = [];
cur.push([67,67,255]);
transitions.push(cur);
var cur = [];
cur.push([67,67,253]);
transitions.push(cur);
var cur = [];
cur.push([85,85,252]);
transitions.push(cur);
var cur = [];
cur.push([82,82,251]);
transitions.push(cur);
var cur = [];
cur.push([65,65,246]);
cur.push([67,67,247]);
cur.push([70,70,248]);
cur.push([79,79,259]);
cur.push([80,80,249]);
cur.push([85,85,250]);
transitions.push(cur);
var cur = [];
cur.push([78,78,244]);
cur.push([83,83,245]);
transitions.push(cur);
var cur = [];
cur.push([66,66,242]);
cur.push([69,69,286]);
cur.push([82,82,243]);
transitions.push(cur);
var cur = [];
cur.push([83,83,241]);
transitions.push(cur);
var cur = [];
cur.push([67,67,240]);
cur.push([84,84,279]);
transitions.push(cur);
var cur = [];
cur.push([76,76,271]);
cur.push([82,82,239]);
transitions.push(cur);
var cur = [];
cur.push([67,67,238]);
transitions.push(cur);
var cur = [];
cur.push([84,84,237]);
transitions.push(cur);
var cur = [];
cur.push([82,82,236]);
transitions.push(cur);
var cur = [];
cur.push([86,86,235]);
transitions.push(cur);
var cur = [];
cur.push([69,69,234]);
transitions.push(cur);
var cur = [];
cur.push([74,74,294]);
cur.push([77,77,233]);
cur.push([84,84,260]);
transitions.push(cur);
var cur = [];
cur.push([68,68,232]);
transitions.push(cur);
var cur = [];
cur.push([76,76,314]);
cur.push([79,79,231]);
transitions.push(cur);
var cur = [];
cur.push([66,66,230]);
cur.push([68,68,316]);
cur.push([82,82,257]);
transitions.push(cur);
var cur = [];
cur.push([65,65,229]);
transitions.push(cur);
var cur = [];
cur.push([66,66,298]);
cur.push([67,67,254]);
cur.push([71,71,338]);
cur.push([77,77,270]);
cur.push([80,80,228]);
transitions.push(cur);
var cur = [];
cur.push([76,76,309]);
cur.push([79,79,227]);
transitions.push(cur);
var cur = [];
cur.push([68,68,226]);
cur.push([79,79,278]);
transitions.push(cur);
var cur = [];
cur.push([89,89,225]);
transitions.push(cur);
var cur = [];
cur.push([79,79,224]);
transitions.push(cur);
var cur = [];
cur.push([68,68,258]);
cur.push([84,84,223]);
transitions.push(cur);
var cur = [];
cur.push([89,89,222]);
transitions.push(cur);
var cur = [];
cur.push([49,57,219]);
cur.push([48,48,221]);
transitions.push(cur);
var cur = [];
cur.push([48,57,220]);
cur.push([65,70,220]);
cur.push([97,102,220]);
transitions.push(cur);
var cur = [];
cur.push([101,101,218]);
transitions.push(cur);
var cur = [];
cur.push([49,57,215]);
cur.push([48,48,217]);
transitions.push(cur);
var cur = [];
cur.push([48,57,216]);
cur.push([65,70,216]);
cur.push([97,102,216]);
transitions.push(cur);
var cur = [];
cur.push([101,101,214]);
transitions.push(cur);
var cur = [];
cur.push([49,57,211]);
cur.push([48,48,213]);
transitions.push(cur);
var cur = [];
cur.push([48,57,212]);
cur.push([65,70,212]);
cur.push([97,102,212]);
transitions.push(cur);
var cur = [];
cur.push([101,101,210]);
transitions.push(cur);
var cur = [];
cur.push([49,57,207]);
cur.push([48,48,209]);
transitions.push(cur);
var cur = [];
cur.push([48,57,208]);
cur.push([65,70,208]);
cur.push([97,102,208]);
transitions.push(cur);
var cur = [];
cur.push([101,101,206]);
transitions.push(cur);
var cur = [];
cur.push([49,57,199]);
cur.push([48,48,201]);
transitions.push(cur);
var cur = [];
cur.push([48,57,200]);
cur.push([65,70,200]);
cur.push([97,102,200]);
transitions.push(cur);
var cur = [];
cur.push([1,9,114]);
cur.push([11,12,114]);
cur.push([14,128,114]);
transitions.push(cur);
var cur = [];
cur.push([1,9,113]);
cur.push([11,12,113]);
cur.push([14,128,113]);
transitions.push(cur);
var cur = [];
cur.push([1,9,113]);
cur.push([11,12,113]);
cur.push([14,38,113]);
cur.push([40,91,113]);
cur.push([93,128,113]);
cur.push([39,39,202]);
cur.push([92,92,112]);
transitions.push(cur);
var cur = [];
cur.push([1,9,114]);
cur.push([11,12,114]);
cur.push([14,33,114]);
cur.push([35,91,114]);
cur.push([93,128,114]);
cur.push([34,34,202]);
cur.push([92,92,111]);
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
cur.push([9,10,120]);
cur.push([13,13,120]);
cur.push([32,32,120]);
transitions.push(cur);
var cur = [];
cur.push([9,10,120]);
cur.push([13,13,120]);
cur.push([32,32,120]);
cur.push([40,40,205]);
cur.push([43,43,205]);
cur.push([47,93,205]);
transitions.push(cur);
var cur = [];
cur.push([9,10,121]);
cur.push([13,13,121]);
cur.push([32,32,121]);
cur.push([43,43,97]);
cur.push([45,45,97]);
cur.push([49,57,219]);
cur.push([48,48,221]);
transitions.push(cur);
var cur = [];
cur.push([9,10,122]);
cur.push([13,13,122]);
cur.push([32,32,122]);
cur.push([43,43,100]);
cur.push([45,45,100]);
cur.push([49,57,215]);
cur.push([48,48,217]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([43,43,103]);
cur.push([45,45,103]);
cur.push([49,57,211]);
cur.push([48,48,213]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([43,43,106]);
cur.push([45,45,106]);
cur.push([49,57,207]);
cur.push([48,48,209]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([102,102,158]);
cur.push([116,116,183]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([102,102,159]);
cur.push([116,116,182]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([102,102,160]);
cur.push([116,116,181]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([102,102,161]);
cur.push([116,116,180]);
transitions.push(cur);
var cur = [];
cur.push([9,10,198]);
cur.push([13,13,198]);
cur.push([32,32,198]);
cur.push([34,34,114]);
cur.push([39,39,113]);
cur.push([40,40,203]);
cur.push([41,41,204]);
cur.push([43,43,109]);
cur.push([45,45,109]);
cur.push([48,48,201]);
cur.push([49,57,199]);
cur.push([65,65,142]);
cur.push([66,66,139]);
cur.push([67,67,138]);
cur.push([68,68,148]);
cur.push([69,69,140]);
cur.push([70,70,132]);
cur.push([71,71,150]);
cur.push([72,72,147]);
cur.push([73,73,133]);
cur.push([76,76,151]);
cur.push([77,77,130]);
cur.push([78,78,131]);
cur.push([79,79,134]);
cur.push([80,80,135]);
cur.push([81,81,152]);
cur.push([82,82,144]);
cur.push([83,83,136]);
cur.push([84,84,145]);
cur.push([85,85,149]);
cur.push([86,86,146]);
cur.push([87,87,137]);
cur.push([88,88,143]);
cur.push([89,89,141]);
cur.push([98,98,167]);
cur.push([99,99,178]);
cur.push([105,105,175]);
cur.push([112,112,177]);
cur.push([115,115,166]);
transitions.push(cur);
var cur = [];
cur.push([65,65,50]);
cur.push([66,66,83]);
cur.push([68,68,49]);
cur.push([73,73,48]);
cur.push([82,82,30]);
cur.push([84,84,91]);
transitions.push(cur);
var cur = [];
cur.push([65,65,77]);
cur.push([67,67,68]);
cur.push([69,69,67]);
cur.push([77,77,76]);
cur.push([79,79,47]);
cur.push([80,80,29]);
cur.push([82,82,75]);
cur.push([83,83,74]);
cur.push([86,86,73]);
cur.push([87,87,61]);
cur.push([89,89,72]);
transitions.push(cur);
var cur = [];
cur.push([65,65,79]);
cur.push([67,67,18]);
cur.push([76,76,95]);
cur.push([79,79,17]);
cur.push([82,82,55]);
cur.push([87,87,19]);
transitions.push(cur);
var cur = [];
cur.push([65,65,52]);
cur.push([68,68,15]);
cur.push([70,70,14]);
cur.push([78,78,13]);
transitions.push(cur);
var cur = [];
cur.push([66,66,46]);
cur.push([67,67,12]);
cur.push([70,70,45]);
cur.push([82,82,44]);
cur.push([85,85,43]);
transitions.push(cur);
var cur = [];
cur.push([67,67,11]);
cur.push([68,68,28]);
cur.push([79,79,10]);
cur.push([82,82,42]);
cur.push([84,84,27]);
transitions.push(cur);
var cur = [];
cur.push([67,67,64]);
cur.push([69,69,65]);
cur.push([76,76,41]);
cur.push([78,78,40]);
cur.push([80,80,60]);
cur.push([82,82,8]);
cur.push([85,85,90]);
cur.push([86,86,39]);
cur.push([87,87,63]);
transitions.push(cur);
var cur = [];
cur.push([67,67,62]);
cur.push([72,72,5]);
cur.push([73,73,58]);
cur.push([86,86,84]);
transitions.push(cur);
var cur = [];
cur.push([67,67,57]);
cur.push([72,72,1]);
cur.push([83,83,81]);
cur.push([84,84,94]);
cur.push([85,85,69]);
cur.push([86,86,93]);
transitions.push(cur);
var cur = [];
cur.push([67,67,0]);
cur.push([76,76,86]);
cur.push([78,78,70]);
cur.push([80,80,82]);
cur.push([84,84,33]);
cur.push([87,87,23]);
transitions.push(cur);
var cur = [];
cur.push([67,67,66]);
cur.push([76,76,21]);
cur.push([82,82,32]);
cur.push([83,83,80]);
cur.push([88,88,20]);
transitions.push(cur);
var cur = [];
cur.push([68,68,2]);
cur.push([69,69,36]);
cur.push([83,83,71]);
transitions.push(cur);
var cur = [];
cur.push([68,68,35]);
cur.push([76,76,25]);
cur.push([77,77,96]);
cur.push([78,78,24]);
cur.push([79,79,34]);
cur.push([85,85,59]);
transitions.push(cur);
var cur = [];
cur.push([68,68,4]);
cur.push([79,79,3]);
transitions.push(cur);
var cur = [];
cur.push([69,69,85]);
cur.push([84,84,87]);
transitions.push(cur);
var cur = [];
cur.push([72,72,38]);
cur.push([77,77,37]);
cur.push([82,82,7]);
transitions.push(cur);
var cur = [];
cur.push([73,73,89]);
cur.push([83,83,6]);
transitions.push(cur);
var cur = [];
cur.push([76,76,92]);
cur.push([79,79,16]);
cur.push([83,83,78]);
cur.push([85,85,53]);
transitions.push(cur);
var cur = [];
cur.push([77,77,22]);
cur.push([82,82,56]);
cur.push([83,83,88]);
transitions.push(cur);
var cur = [];
cur.push([78,78,26]);
transitions.push(cur);
var cur = [];
cur.push([79,79,54]);
transitions.push(cur);
var cur = [];
cur.push([79,79,51]);
cur.push([86,86,31]);
transitions.push(cur);
var cur = [];
cur.push([82,82,9]);
transitions.push(cur);
var cur = [];
cur.push([97,97,186]);
transitions.push(cur);
var cur = [];
cur.push([97,97,185]);
transitions.push(cur);
var cur = [];
cur.push([97,97,176]);
transitions.push(cur);
var cur = [];
cur.push([97,97,174]);
transitions.push(cur);
var cur = [];
cur.push([97,97,173]);
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
cur.push([97,97,168]);
transitions.push(cur);
var cur = [];
cur.push([97,97,116]);
transitions.push(cur);
var cur = [];
cur.push([99,99,179]);
transitions.push(cur);
var cur = [];
cur.push([100,100,115]);
transitions.push(cur);
var cur = [];
cur.push([101,101,184]);
transitions.push(cur);
var cur = [];
cur.push([101,101,162]);
transitions.push(cur);
var cur = [];
cur.push([105,105,163]);
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
cur.push([108,108,187]);
transitions.push(cur);
var cur = [];
cur.push([108,108,155]);
transitions.push(cur);
var cur = [];
cur.push([108,108,118]);
transitions.push(cur);
var cur = [];
cur.push([108,108,117]);
transitions.push(cur);
var cur = [];
cur.push([110,110,172]);
transitions.push(cur);
var cur = [];
cur.push([110,110,164]);
transitions.push(cur);
var cur = [];
cur.push([111,111,197]);
transitions.push(cur);
var cur = [];
cur.push([111,111,154]);
transitions.push(cur);
var cur = [];
cur.push([111,111,153]);
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
cur.push([114,114,193]);
transitions.push(cur);
var cur = [];
cur.push([114,114,119]);
transitions.push(cur);
var cur = [];
cur.push([115,115,192]);
transitions.push(cur);
var cur = [];
cur.push([115,115,191]);
transitions.push(cur);
var cur = [];
cur.push([115,115,108]);
transitions.push(cur);
var cur = [];
cur.push([115,115,105]);
transitions.push(cur);
var cur = [];
cur.push([115,115,102]);
transitions.push(cur);
var cur = [];
cur.push([115,115,99]);
transitions.push(cur);
var cur = [];
cur.push([116,116,157]);
transitions.push(cur);
var cur = [];
cur.push([116,116,156]);
transitions.push(cur);
var cur = [];
cur.push([117,117,108]);
transitions.push(cur);
var cur = [];
cur.push([117,117,105]);
transitions.push(cur);
var cur = [];
cur.push([117,117,102]);
transitions.push(cur);
var cur = [];
cur.push([117,117,99]);
transitions.push(cur);
var cur = [];
cur.push([119,119,165]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([48,57,199]);
transitions.push(cur);
var cur = [];
cur.push([48,57,200]);
cur.push([65,70,200]);
cur.push([97,102,200]);
transitions.push(cur);
var cur = [];
cur.push([48,57,199]);
cur.push([120,120,110]);
transitions.push(cur);
transitions.push(null);
transitions.push(null);
transitions.push(null);
var cur = [];
cur.push([40,40,205]);
cur.push([43,43,205]);
cur.push([47,93,205]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,207]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,208]);
cur.push([65,70,208]);
cur.push([97,102,208]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,207]);
cur.push([120,120,107]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,211]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,212]);
cur.push([65,70,212]);
cur.push([97,102,212]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,211]);
cur.push([120,120,104]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,215]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,216]);
cur.push([65,70,216]);
cur.push([97,102,216]);
transitions.push(cur);
var cur = [];
cur.push([9,10,127]);
cur.push([13,13,127]);
cur.push([32,32,127]);
cur.push([48,57,215]);
cur.push([120,120,101]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,219]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,220]);
cur.push([65,70,220]);
cur.push([97,102,220]);
transitions.push(cur);
var cur = [];
cur.push([9,10,128]);
cur.push([13,13,128]);
cur.push([32,32,128]);
cur.push([48,57,219]);
cur.push([120,120,98]);
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
}

        static var accepting = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false].concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]);

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
	static inline function errtok(hxl_match:String) {
return ({ HLexLog.log("Error: Unknown char sequence '"+ hxl_match +"'"); null; });
	}
	static function tokenof(id:Int, hxl_match:String) {
		switch(id) {
			default: return null;
            case 199:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 200:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 201:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 202:
				return ({ tText( hxl_match .substr(1, hxl_match .length-2)); });
            case 203:
				return ({ tLeftParen;  });
            case 204:
				return ({ tRightParen; });
            case 205:
				return ({
	var xs = ((~/[\n\r \t]+/).replace( hxl_match ," ")).split(" ");
	tPower(Std.parseInt(xs[1]));
});
            case 206:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 207:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 208:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 209:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proInland(pro.val,pro.sc));
});
            case 210:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 211:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 212:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 213:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proSea(pro.val,pro.sc));
});
            case 214:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 215:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 216:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 217:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proCoastal(pro.val,pro.sc));
});
            case 218:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 219:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 220:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 221:
				return ({
	var pro = HLexLog.province( hxl_match );
	tProvince(proBiCoastal(pro.val,pro.sc));
});
            case 222:
				return ({ tUnitType(utArmy);  });
            case 223:
				return ({ tUnitType(utFleet); });
            case 224:
				return ({ tOrder(oMoveByConvoy); });
            case 225:
				return ({ tOrder(oConvoy); });
            case 226:
				return ({ tOrder(oHold); });
            case 227:
				return ({ tOrder(oMove); });
            case 228:
				return ({ tOrder(oSupport); });
            case 229:
				return ({ tOrder(oVia); });
            case 230:
				return ({ tOrder(oDisband); });
            case 231:
				return ({ tOrder(oRetreat); });
            case 232:
				return ({ tOrder(oBuild); });
            case 233:
				return ({ tOrder(oRemove); });
            case 234:
				return ({ tOrder(oWaive); });
            case 235:
				return ({ tOrderNote(onOkay); });
            case 236:
				return ({ tOrderNote(onBPR); });
            case 237:
				return ({ tOrderNote(onNoCoastSpecified); });
            case 238:
				return ({ tOrderNote(onNotEmptySupply); });
            case 239:
				return ({ tOrderNote(onNotAdjacent); });
            case 240:
				return ({ tOrderNote(onNotHomeSupply); });
            case 241:
				return ({ tOrderNote(onNotAtSea); });
            case 242:
				return ({ tOrderNote(onNoMoreBuilds); });
            case 243:
				return ({ tOrderNote(onNoMoreRemovals); });
            case 244:
				return ({ tOrderNote(onNoRetreatNeeded); });
            case 245:
				return ({ tOrderNote(onNotRightSeason); });
            case 246:
				return ({ tOrderNote(onNoSuchArmy); });
            case 247:
				return ({ tOrderNote(onNotSupply); });
            case 248:
				return ({ tOrderNote(onNoSuchFleet); });
            case 249:
				return ({ tOrderNote(onNoSuchProvince); });
            case 250:
				return ({ tOrderNote(onNoSuchUnit); });
            case 251:
				return ({ tOrderNote(onNotValidRetreat); });
            case 252:
				return ({ tOrderNote(onNotYourUnit); });
            case 253:
				return ({ tOrderNote(onNotYourSupply); });
            case 254:
				return ({ tResult(rSuccess); });
            case 255:
				return ({ tResult(rMoveBounced); });
            case 256:
				return ({ tResult(rSupportCut); });
            case 257:
				return ({ tResult(rConvoyDisrupted); });
            case 258:
				return ({ tResult(rFLD); });
            case 259:
				return ({ tResult(rNoSuchOrder); });
            case 260:
				return ({ tResult(rDislodged); });
            case 261:
				return ({ tCoast(cNorth); });
            case 262:
				return ({ tCoast(cNorthEast); });
            case 263:
				return ({ tCoast(cEast); });
            case 264:
				return ({ tCoast(cSouthEast); });
            case 265:
				return ({ tCoast(cSouth); });
            case 266:
				return ({ tCoast(cSouthWest); });
            case 267:
				return ({ tCoast(cWest); });
            case 268:
				return ({ tCoast(cNorthWest); });
            case 269:
				return ({ tPhase(pSpring); });
            case 270:
				return ({ tPhase(pSummer); });
            case 271:
				return ({ tPhase(pFall); });
            case 272:
				return ({ tPhase(pAutumn); });
            case 273:
				return ({ tPhase(pWinter); });
            case 274:
				return ({ tCommand(coPowerInCivilDisorder); });
            case 275:
				return ({ tCommand(coDraw); });
            case 276:
				return ({ tCommand(coMessageFrom); });
            case 277:
				return ({ tCommand(coGoFlag); });
            case 278:
				return ({ tCommand(coHello); });
            case 279:
				return ({ tCommand(coHistory); });
            case 280:
				return ({ tCommand(coHuh); });
            case 281:
				return ({ tCommand(coIAm); });
            case 282:
				return ({ tCommand(coLoadGame); });
            case 283:
				return ({ tCommand(coMap); });
            case 284:
				return ({ tCommand(coMapDefinition); });
            case 285:
				return ({ tCommand(coMissingOrders); });
            case 286:
				return ({ tCommand(coName); });
            case 287:
				return ({ tCommand(coNOT); });
            case 288:
				return ({ tCommand(coCurrentPosition); });
            case 289:
				return ({ tCommand(coObserver); });
            case 290:
				return ({ tCommand(coTurnOff); });
            case 291:
				return ({ tCommand(coOrderResult); });
            case 292:
				return ({ tCommand(coPowerEliminated); });
            case 293:
				return ({ tCommand(coParenthesisError); });
            case 294:
				return ({ tCommand(coReject); });
            case 295:
				return ({ tCommand(coSupplyOwnership); });
            case 296:
				return ({ tCommand(coSolo); });
            case 297:
				return ({ tCommand(coSendMessage); });
            case 298:
				return ({ tCommand(coSubmitOrder); });
            case 299:
				return ({ tCommand(coSaveGame); });
            case 300:
				return ({ tCommand(coThink); });
            case 301:
				return ({ tCommand(coTimeToDeadline); });
            case 302:
				return ({ tCommand(coAccept); });
            case 303:
				return ({ tCommand(coAdmin); });
            case 304:
				return ({ tParameter(paAnyOrder); });
            case 305:
				return ({ tParameter(paBuildTimeLimit); });
            case 306:
				return ({ tParameter(paLocationError); });
            case 307:
				return ({ tParameter(paLevel); });
            case 308:
				return ({ tParameter(paMustRetreat); });
            case 309:
				return ({ tParameter(paMoveTimeLimit); });
            case 310:
				return ({ tParameter(paNoPressDuringBuild); });
            case 311:
				return ({ tParameter(paNoPressDuringRetreat); });
            case 312:
				return ({ tParameter(paPartialDrawsAllowed); });
            case 313:
				return ({ tParameter(paPressTimeLimit); });
            case 314:
				return ({ tParameter(paRetreatTimeLimit); });
            case 315:
				return ({ tParameter(paUnowned); });
            case 316:
				return ({ tParameter(paDeadlineDisconnect); });
            case 317:
				return ({ tPress(prAlly); });
            case 318:
				return ({ tPress(prAND); });
            case 319:
				return ({ tPress(prNoneOfYourBusiness); });
            case 320:
				return ({ tPress(prDemiliterisedZone); });
            case 321:
				return ({ tPress(prELSE); });
            case 322:
				return ({ tPress(prExplain); });
            case 323:
				return ({ tPress(prRequestForward); });
            case 324:
				return ({ tPress(prFact); });
            case 325:
				return ({ tPress(prForTurn); });
            case 326:
				return ({ tPress(prHowToAttack); });
            case 327:
				return ({ tPress(prIDontKnow); });
            case 328:
				return ({ tPress(prIF); });
            case 329:
				return ({ tPress(prInsist); });
            case 330:
				return ({ tPress(prOccupy); });
            case 331:
				return ({ tPress(prOR); });
            case 332:
				return ({ tPress(prPeace); });
            case 333:
				return ({ tPress(prPosition); });
            case 334:
				return ({ tPress(prPropose); });
            case 335:
				return ({ tPress(prQuery); });
            case 336:
				return ({ tPress(prSupplyDistro); });
            case 337:
				return ({ tPress(prSorry); });
            case 338:
				return ({ tPress(prSuggest); });
            case 339:
				return ({ tPress(prThink); });
            case 340:
				return ({ tPress(prThen); });
            case 341:
				return ({ tPress(prTry); });
            case 342:
				return ({ tPress(prVersus); });
            case 343:
				return ({ tPress(prWhat); });
            case 344:
				return ({ tPress(prWhy); });
            case 345:
				return ({ tPress(prDo); });
            case 346:
				return ({ tPress(prOwes); });
            case 347:
				return ({ tPress(prTellMe); });
            case 348:
				return ({ tPress(prChoose); });
            case 349:
				return ({ tPress(prBCC); });
            case 350:
				return ({ tPress(prUNT); });
        }
	}
}
