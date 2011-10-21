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
		static inline var entry_state:Int = 127;

	static var transitions:Array<Array<Array<Int>>> = null;
	public static function init() {
		if(transitions!=null) return;
		transitions = [];
var cur = [];
cur.push([84,84,352]);
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
cur.push([77,77,345]);
transitions.push(cur);
var cur = [];
cur.push([89,89,344]);
transitions.push(cur);
var cur = [];
cur.push([89,89,340]);
transitions.push(cur);
var cur = [];
cur.push([89,89,338]);
transitions.push(cur);
var cur = [];
cur.push([84,84,336]);
transitions.push(cur);
var cur = [];
cur.push([66,66,335]);
transitions.push(cur);
var cur = [];
cur.push([69,69,334]);
transitions.push(cur);
var cur = [];
cur.push([67,67,332]);
transitions.push(cur);
var cur = [];
cur.push([85,85,331]);
transitions.push(cur);
var cur = [];
cur.push([83,83,330]);
transitions.push(cur);
var cur = [];
cur.push([70,70,329]);
transitions.push(cur);
var cur = [];
cur.push([75,75,328]);
transitions.push(cur);
var cur = [];
cur.push([87,87,327]);
transitions.push(cur);
var cur = [];
cur.push([82,82,326]);
transitions.push(cur);
var cur = [];
cur.push([84,84,325]);
transitions.push(cur);
var cur = [];
cur.push([68,68,324]);
transitions.push(cur);
var cur = [];
cur.push([80,80,323]);
transitions.push(cur);
var cur = [];
cur.push([83,83,322]);
transitions.push(cur);
var cur = [];
cur.push([90,90,321]);
transitions.push(cur);
var cur = [];
cur.push([88,88,320]);
transitions.push(cur);
var cur = [];
cur.push([68,68,319]);
transitions.push(cur);
var cur = [];
cur.push([89,89,318]);
transitions.push(cur);
var cur = [];
cur.push([79,79,316]);
transitions.push(cur);
var cur = [];
cur.push([76,76,314]);
transitions.push(cur);
var cur = [];
cur.push([65,65,313]);
transitions.push(cur);
var cur = [];
cur.push([66,66,311]);
cur.push([82,82,312]);
transitions.push(cur);
var cur = [];
cur.push([84,84,309]);
transitions.push(cur);
var cur = [];
cur.push([76,76,308]);
transitions.push(cur);
var cur = [];
cur.push([82,82,307]);
transitions.push(cur);
var cur = [];
cur.push([76,76,306]);
transitions.push(cur);
var cur = [];
cur.push([65,65,305]);
transitions.push(cur);
var cur = [];
cur.push([77,77,304]);
transitions.push(cur);
var cur = [];
cur.push([83,83,303]);
transitions.push(cur);
var cur = [];
cur.push([69,69,302]);
transitions.push(cur);
var cur = [];
cur.push([75,75,342]);
cur.push([78,78,343]);
cur.push([88,88,301]);
transitions.push(cur);
var cur = [];
cur.push([69,69,300]);
transitions.push(cur);
var cur = [];
cur.push([68,68,298]);
transitions.push(cur);
var cur = [];
cur.push([79,79,297]);
transitions.push(cur);
var cur = [];
cur.push([78,78,294]);
cur.push([80,80,337]);
transitions.push(cur);
var cur = [];
cur.push([84,84,293]);
transitions.push(cur);
var cur = [];
cur.push([68,68,292]);
cur.push([82,82,333]);
transitions.push(cur);
var cur = [];
cur.push([70,70,291]);
transitions.push(cur);
var cur = [];
cur.push([83,83,290]);
transitions.push(cur);
var cur = [];
cur.push([84,84,288]);
cur.push([87,87,289]);
transitions.push(cur);
var cur = [];
cur.push([83,83,286]);
transitions.push(cur);
var cur = [];
cur.push([70,70,285]);
transitions.push(cur);
var cur = [];
cur.push([80,80,284]);
transitions.push(cur);
var cur = [];
cur.push([68,68,283]);
transitions.push(cur);
var cur = [];
cur.push([77,77,282]);
transitions.push(cur);
var cur = [];
cur.push([72,72,281]);
transitions.push(cur);
var cur = [];
cur.push([70,70,278]);
transitions.push(cur);
var cur = [];
cur.push([77,77,277]);
transitions.push(cur);
var cur = [];
cur.push([87,87,276]);
transitions.push(cur);
var cur = [];
cur.push([68,68,275]);
transitions.push(cur);
var cur = [];
cur.push([78,78,274]);
transitions.push(cur);
var cur = [];
cur.push([84,84,273]);
transitions.push(cur);
var cur = [];
cur.push([82,82,270]);
transitions.push(cur);
var cur = [];
cur.push([67,67,269]);
transitions.push(cur);
var cur = [];
cur.push([83,83,268]);
transitions.push(cur);
var cur = [];
cur.push([67,67,267]);
transitions.push(cur);
var cur = [];
cur.push([68,68,339]);
cur.push([79,79,296]);
cur.push([83,83,266]);
transitions.push(cur);
var cur = [];
cur.push([67,67,265]);
transitions.push(cur);
var cur = [];
cur.push([83,83,264]);
transitions.push(cur);
var cur = [];
cur.push([67,67,263]);
transitions.push(cur);
var cur = [];
cur.push([83,83,262]);
transitions.push(cur);
var cur = [];
cur.push([84,84,257]);
transitions.push(cur);
var cur = [];
cur.push([67,67,256]);
transitions.push(cur);
var cur = [];
cur.push([67,67,254]);
transitions.push(cur);
var cur = [];
cur.push([85,85,253]);
transitions.push(cur);
var cur = [];
cur.push([82,82,252]);
transitions.push(cur);
var cur = [];
cur.push([65,65,246]);
cur.push([67,67,247]);
cur.push([70,70,248]);
cur.push([79,79,260]);
cur.push([80,80,249]);
cur.push([84,84,250]);
cur.push([85,85,251]);
transitions.push(cur);
var cur = [];
cur.push([78,78,244]);
cur.push([83,83,245]);
transitions.push(cur);
var cur = [];
cur.push([66,66,242]);
cur.push([69,69,287]);
cur.push([82,82,243]);
transitions.push(cur);
var cur = [];
cur.push([83,83,241]);
transitions.push(cur);
var cur = [];
cur.push([67,67,240]);
cur.push([84,84,280]);
transitions.push(cur);
var cur = [];
cur.push([76,76,272]);
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
cur.push([74,74,295]);
cur.push([77,77,233]);
cur.push([84,84,261]);
transitions.push(cur);
var cur = [];
cur.push([68,68,232]);
transitions.push(cur);
var cur = [];
cur.push([76,76,315]);
cur.push([79,79,231]);
transitions.push(cur);
var cur = [];
cur.push([66,66,230]);
cur.push([68,68,317]);
cur.push([82,82,258]);
transitions.push(cur);
var cur = [];
cur.push([65,65,229]);
transitions.push(cur);
var cur = [];
cur.push([66,66,299]);
cur.push([67,67,255]);
cur.push([71,71,341]);
cur.push([77,77,271]);
cur.push([80,80,228]);
transitions.push(cur);
var cur = [];
cur.push([76,76,310]);
cur.push([79,79,227]);
transitions.push(cur);
var cur = [];
cur.push([68,68,226]);
cur.push([79,79,279]);
transitions.push(cur);
var cur = [];
cur.push([89,89,225]);
transitions.push(cur);
var cur = [];
cur.push([79,79,224]);
transitions.push(cur);
var cur = [];
cur.push([68,68,259]);
cur.push([84,84,223]);
transitions.push(cur);
var cur = [];
cur.push([89,89,222]);
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
cur.push([48,57,216]);
cur.push([65,70,216]);
cur.push([97,102,216]);
transitions.push(cur);
var cur = [];
cur.push([101,101,214]);
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
cur.push([48,57,208]);
cur.push([65,70,208]);
cur.push([97,102,208]);
transitions.push(cur);
var cur = [];
cur.push([101,101,206]);
transitions.push(cur);
var cur = [];
cur.push([48,57,204]);
cur.push([65,70,204]);
cur.push([97,102,204]);
transitions.push(cur);
var cur = [];
cur.push([48,57,198]);
cur.push([65,70,198]);
cur.push([97,102,198]);
transitions.push(cur);
var cur = [];
cur.push([1,9,112]);
cur.push([11,12,112]);
cur.push([14,128,112]);
transitions.push(cur);
var cur = [];
cur.push([1,9,111]);
cur.push([11,12,111]);
cur.push([14,128,111]);
transitions.push(cur);
var cur = [];
cur.push([1,9,111]);
cur.push([11,12,111]);
cur.push([14,38,111]);
cur.push([40,91,111]);
cur.push([93,128,111]);
cur.push([39,39,200]);
cur.push([92,92,110]);
transitions.push(cur);
var cur = [];
cur.push([1,9,112]);
cur.push([11,12,112]);
cur.push([14,33,112]);
cur.push([35,91,112]);
cur.push([93,128,112]);
cur.push([34,34,200]);
cur.push([92,92,109]);
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
cur.push([9,10,119]);
cur.push([13,13,119]);
cur.push([32,32,119]);
transitions.push(cur);
var cur = [];
cur.push([9,10,118]);
cur.push([13,13,118]);
cur.push([32,32,118]);
transitions.push(cur);
var cur = [];
cur.push([9,10,118]);
cur.push([13,13,118]);
cur.push([32,32,118]);
cur.push([49,57,219]);
cur.push([48,48,221]);
transitions.push(cur);
var cur = [];
cur.push([9,10,119]);
cur.push([13,13,119]);
cur.push([32,32,119]);
cur.push([49,57,215]);
cur.push([48,48,217]);
transitions.push(cur);
var cur = [];
cur.push([9,10,120]);
cur.push([13,13,120]);
cur.push([32,32,120]);
cur.push([49,57,211]);
cur.push([48,48,213]);
transitions.push(cur);
var cur = [];
cur.push([9,10,121]);
cur.push([13,13,121]);
cur.push([32,32,121]);
cur.push([49,57,207]);
cur.push([48,48,209]);
transitions.push(cur);
var cur = [];
cur.push([9,10,122]);
cur.push([13,13,122]);
cur.push([32,32,122]);
cur.push([49,57,203]);
cur.push([48,48,205]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([102,102,156]);
cur.push([116,116,181]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([102,102,157]);
cur.push([116,116,180]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([102,102,158]);
cur.push([116,116,179]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([102,102,159]);
cur.push([116,116,178]);
transitions.push(cur);
var cur = [];
cur.push([9,10,196]);
cur.push([13,13,196]);
cur.push([32,32,196]);
cur.push([34,34,112]);
cur.push([39,39,111]);
cur.push([40,40,201]);
cur.push([41,41,202]);
cur.push([48,48,199]);
cur.push([49,57,197]);
cur.push([65,65,139]);
cur.push([66,66,144]);
cur.push([67,67,137]);
cur.push([68,68,146]);
cur.push([69,69,136]);
cur.push([70,70,130]);
cur.push([71,71,148]);
cur.push([72,72,145]);
cur.push([73,73,131]);
cur.push([76,76,149]);
cur.push([77,77,128]);
cur.push([78,78,129]);
cur.push([79,79,132]);
cur.push([80,80,133]);
cur.push([81,81,150]);
cur.push([82,82,141]);
cur.push([83,83,134]);
cur.push([84,84,142]);
cur.push([85,85,147]);
cur.push([86,86,143]);
cur.push([87,87,135]);
cur.push([88,88,140]);
cur.push([89,89,138]);
cur.push([98,98,165]);
cur.push([99,99,176]);
cur.push([105,105,173]);
cur.push([112,112,175]);
cur.push([115,115,164]);
transitions.push(cur);
var cur = [];
cur.push([65,65,52]);
cur.push([66,66,85]);
cur.push([68,68,51]);
cur.push([73,73,50]);
cur.push([82,82,32]);
cur.push([84,84,93]);
transitions.push(cur);
var cur = [];
cur.push([65,65,79]);
cur.push([67,67,70]);
cur.push([69,69,69]);
cur.push([77,77,78]);
cur.push([79,79,49]);
cur.push([80,80,31]);
cur.push([82,82,77]);
cur.push([83,83,76]);
cur.push([86,86,75]);
cur.push([87,87,63]);
cur.push([89,89,74]);
transitions.push(cur);
var cur = [];
cur.push([65,65,81]);
cur.push([67,67,20]);
cur.push([76,76,97]);
cur.push([79,79,19]);
cur.push([82,82,57]);
cur.push([87,87,21]);
transitions.push(cur);
var cur = [];
cur.push([65,65,54]);
cur.push([68,68,17]);
cur.push([70,70,16]);
cur.push([78,78,15]);
cur.push([79,79,14]);
transitions.push(cur);
var cur = [];
cur.push([66,66,48]);
cur.push([67,67,13]);
cur.push([70,70,47]);
cur.push([82,82,46]);
cur.push([85,85,45]);
transitions.push(cur);
var cur = [];
cur.push([67,67,12]);
cur.push([68,68,30]);
cur.push([79,79,11]);
cur.push([80,80,10]);
cur.push([82,82,44]);
cur.push([84,84,29]);
transitions.push(cur);
var cur = [];
cur.push([67,67,66]);
cur.push([69,69,67]);
cur.push([76,76,43]);
cur.push([78,78,42]);
cur.push([80,80,62]);
cur.push([82,82,8]);
cur.push([85,85,92]);
cur.push([86,86,41]);
cur.push([87,87,65]);
transitions.push(cur);
var cur = [];
cur.push([67,67,64]);
cur.push([72,72,4]);
cur.push([73,73,60]);
cur.push([82,82,0]);
cur.push([86,86,86]);
transitions.push(cur);
var cur = [];
cur.push([67,67,68]);
cur.push([76,76,23]);
cur.push([82,82,34]);
cur.push([83,83,82]);
cur.push([88,88,22]);
transitions.push(cur);
var cur = [];
cur.push([67,67,59]);
cur.push([83,83,83]);
cur.push([84,84,96]);
cur.push([85,85,71]);
cur.push([86,86,95]);
transitions.push(cur);
var cur = [];
cur.push([68,68,1]);
cur.push([69,69,38]);
cur.push([83,83,73]);
transitions.push(cur);
var cur = [];
cur.push([68,68,37]);
cur.push([76,76,27]);
cur.push([77,77,98]);
cur.push([78,78,26]);
cur.push([79,79,36]);
cur.push([85,85,61]);
transitions.push(cur);
var cur = [];
cur.push([68,68,3]);
cur.push([79,79,2]);
transitions.push(cur);
var cur = [];
cur.push([69,69,87]);
cur.push([84,84,89]);
transitions.push(cur);
var cur = [];
cur.push([72,72,40]);
cur.push([77,77,39]);
cur.push([82,82,7]);
transitions.push(cur);
var cur = [];
cur.push([73,73,91]);
cur.push([83,83,5]);
transitions.push(cur);
var cur = [];
cur.push([76,76,88]);
cur.push([78,78,72]);
cur.push([80,80,84]);
cur.push([84,84,35]);
cur.push([87,87,25]);
transitions.push(cur);
var cur = [];
cur.push([76,76,94]);
cur.push([79,79,18]);
cur.push([83,83,80]);
cur.push([85,85,55]);
transitions.push(cur);
var cur = [];
cur.push([77,77,24]);
cur.push([82,82,58]);
cur.push([83,83,90]);
transitions.push(cur);
var cur = [];
cur.push([78,78,28]);
cur.push([79,79,6]);
transitions.push(cur);
var cur = [];
cur.push([79,79,56]);
transitions.push(cur);
var cur = [];
cur.push([79,79,53]);
cur.push([86,86,33]);
transitions.push(cur);
var cur = [];
cur.push([82,82,9]);
transitions.push(cur);
var cur = [];
cur.push([97,97,184]);
transitions.push(cur);
var cur = [];
cur.push([97,97,183]);
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
cur.push([97,97,169]);
transitions.push(cur);
var cur = [];
cur.push([97,97,168]);
transitions.push(cur);
var cur = [];
cur.push([97,97,167]);
transitions.push(cur);
var cur = [];
cur.push([97,97,166]);
transitions.push(cur);
var cur = [];
cur.push([97,97,115]);
transitions.push(cur);
var cur = [];
cur.push([99,99,177]);
transitions.push(cur);
var cur = [];
cur.push([100,100,114]);
transitions.push(cur);
var cur = [];
cur.push([101,101,182]);
transitions.push(cur);
var cur = [];
cur.push([101,101,160]);
transitions.push(cur);
var cur = [];
cur.push([105,105,161]);
transitions.push(cur);
var cur = [];
cur.push([108,108,188]);
transitions.push(cur);
var cur = [];
cur.push([108,108,187]);
transitions.push(cur);
var cur = [];
cur.push([108,108,186]);
transitions.push(cur);
var cur = [];
cur.push([108,108,185]);
transitions.push(cur);
var cur = [];
cur.push([108,108,153]);
transitions.push(cur);
var cur = [];
cur.push([108,108,117]);
transitions.push(cur);
var cur = [];
cur.push([108,108,116]);
transitions.push(cur);
var cur = [];
cur.push([110,110,170]);
transitions.push(cur);
var cur = [];
cur.push([110,110,162]);
transitions.push(cur);
var cur = [];
cur.push([111,111,195]);
transitions.push(cur);
var cur = [];
cur.push([111,111,152]);
transitions.push(cur);
var cur = [];
cur.push([111,111,151]);
transitions.push(cur);
var cur = [];
cur.push([114,114,194]);
transitions.push(cur);
var cur = [];
cur.push([114,114,193]);
transitions.push(cur);
var cur = [];
cur.push([114,114,192]);
transitions.push(cur);
var cur = [];
cur.push([114,114,191]);
transitions.push(cur);
var cur = [];
cur.push([114,114,113]);
transitions.push(cur);
var cur = [];
cur.push([115,115,190]);
transitions.push(cur);
var cur = [];
cur.push([115,115,189]);
transitions.push(cur);
var cur = [];
cur.push([115,115,106]);
transitions.push(cur);
var cur = [];
cur.push([115,115,104]);
transitions.push(cur);
var cur = [];
cur.push([115,115,102]);
transitions.push(cur);
var cur = [];
cur.push([115,115,100]);
transitions.push(cur);
var cur = [];
cur.push([116,116,155]);
transitions.push(cur);
var cur = [];
cur.push([116,116,154]);
transitions.push(cur);
var cur = [];
cur.push([117,117,106]);
transitions.push(cur);
var cur = [];
cur.push([117,117,104]);
transitions.push(cur);
var cur = [];
cur.push([117,117,102]);
transitions.push(cur);
var cur = [];
cur.push([117,117,100]);
transitions.push(cur);
var cur = [];
cur.push([119,119,163]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([48,57,197]);
transitions.push(cur);
var cur = [];
cur.push([48,57,198]);
cur.push([65,70,198]);
cur.push([97,102,198]);
transitions.push(cur);
var cur = [];
cur.push([48,57,197]);
cur.push([120,120,108]);
transitions.push(cur);
transitions.push(null);
transitions.push(null);
transitions.push(null);
var cur = [];
cur.push([48,57,203]);
transitions.push(cur);
var cur = [];
cur.push([48,57,204]);
cur.push([65,70,204]);
cur.push([97,102,204]);
transitions.push(cur);
var cur = [];
cur.push([48,57,203]);
cur.push([120,120,107]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([48,57,207]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([48,57,208]);
cur.push([65,70,208]);
cur.push([97,102,208]);
transitions.push(cur);
var cur = [];
cur.push([9,10,123]);
cur.push([13,13,123]);
cur.push([32,32,123]);
cur.push([48,57,207]);
cur.push([120,120,105]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([48,57,211]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([48,57,212]);
cur.push([65,70,212]);
cur.push([97,102,212]);
transitions.push(cur);
var cur = [];
cur.push([9,10,124]);
cur.push([13,13,124]);
cur.push([32,32,124]);
cur.push([48,57,211]);
cur.push([120,120,103]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,215]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,216]);
cur.push([65,70,216]);
cur.push([97,102,216]);
transitions.push(cur);
var cur = [];
cur.push([9,10,125]);
cur.push([13,13,125]);
cur.push([32,32,125]);
cur.push([48,57,215]);
cur.push([120,120,101]);
transitions.push(cur);
transitions.push(null);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,219]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,220]);
cur.push([65,70,220]);
cur.push([97,102,220]);
transitions.push(cur);
var cur = [];
cur.push([9,10,126]);
cur.push([13,13,126]);
cur.push([32,32,126]);
cur.push([48,57,219]);
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
}

        static var accepting = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false].concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]).concat([false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]).concat([true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]);

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
            case 197:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 198:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 199:
				return ({ tInteger(Std.parseInt( hxl_match )); });
            case 200:
				return ({ tText( hxl_match .substr(1, hxl_match .length-2)); });
            case 201:
				return ({ tLeftParen;  });
            case 202:
				return ({ tRightParen; });
            case 203:
				return ({
	var xs = ((~/[\n\r \t]+/).replace( hxl_match ," ")).split(" ");
	tPower(Std.parseInt(xs[1]));
});
            case 204:
				return ({
	var xs = ((~/[\n\r \t]+/).replace( hxl_match ," ")).split(" ");
	tPower(Std.parseInt(xs[1]));
});
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
				return ({ tOrderNote(onNST); });
            case 251:
				return ({ tOrderNote(onNoSuchUnit); });
            case 252:
				return ({ tOrderNote(onNotValidRetreat); });
            case 253:
				return ({ tOrderNote(onNotYourUnit); });
            case 254:
				return ({ tOrderNote(onNotYourSupply); });
            case 255:
				return ({ tResult(rSuccess); });
            case 256:
				return ({ tResult(rMoveBounced); });
            case 257:
				return ({ tResult(rSupportCut); });
            case 258:
				return ({ tResult(rConvoyDisrupted); });
            case 259:
				return ({ tResult(rFLD); });
            case 260:
				return ({ tResult(rNoSuchOrder); });
            case 261:
				return ({ tResult(rDislodged); });
            case 262:
				return ({ tCoast(cNorth); });
            case 263:
				return ({ tCoast(cNorthEast); });
            case 264:
				return ({ tCoast(cEast); });
            case 265:
				return ({ tCoast(cSouthEast); });
            case 266:
				return ({ tCoast(cSouth); });
            case 267:
				return ({ tCoast(cSouthWest); });
            case 268:
				return ({ tCoast(cWest); });
            case 269:
				return ({ tCoast(cNorthWest); });
            case 270:
				return ({ tPhase(pSpring); });
            case 271:
				return ({ tPhase(pSummer); });
            case 272:
				return ({ tPhase(pFall); });
            case 273:
				return ({ tPhase(pAutumn); });
            case 274:
				return ({ tPhase(pWinter); });
            case 275:
				return ({ tCommand(coPowerInCivilDisorder); });
            case 276:
				return ({ tCommand(coDraw); });
            case 277:
				return ({ tCommand(coMessageFrom); });
            case 278:
				return ({ tCommand(coGoFlag); });
            case 279:
				return ({ tCommand(coHello); });
            case 280:
				return ({ tCommand(coHistory); });
            case 281:
				return ({ tCommand(coHuh); });
            case 282:
				return ({ tCommand(coIAm); });
            case 283:
				return ({ tCommand(coLoadGame); });
            case 284:
				return ({ tCommand(coMap); });
            case 285:
				return ({ tCommand(coMapDefinition); });
            case 286:
				return ({ tCommand(coMissingOrders); });
            case 287:
				return ({ tCommand(coName); });
            case 288:
				return ({ tCommand(coNOT); });
            case 289:
				return ({ tCommand(coCurrentPosition); });
            case 290:
				return ({ tCommand(coObserver); });
            case 291:
				return ({ tCommand(coTurnOff); });
            case 292:
				return ({ tCommand(coOrderResult); });
            case 293:
				return ({ tCommand(coPowerEliminated); });
            case 294:
				return ({ tCommand(coParenthesisError); });
            case 295:
				return ({ tCommand(coReject); });
            case 296:
				return ({ tCommand(coSupplyOwnership); });
            case 297:
				return ({ tCommand(coSolo); });
            case 298:
				return ({ tCommand(coSendMessage); });
            case 299:
				return ({ tCommand(coSubmitOrder); });
            case 300:
				return ({ tCommand(coSaveGame); });
            case 301:
				return ({ tCommand(coThink); });
            case 302:
				return ({ tCommand(coTimeToDeadline); });
            case 303:
				return ({ tCommand(coAccept); });
            case 304:
				return ({ tCommand(coAdmin); });
            case 305:
				return ({ tParameter(paAnyOrder); });
            case 306:
				return ({ tParameter(paBuildTimeLimit); });
            case 307:
				return ({ tParameter(paLocationError); });
            case 308:
				return ({ tParameter(paLevel); });
            case 309:
				return ({ tParameter(paMustRetreat); });
            case 310:
				return ({ tParameter(paMoveTimeLimit); });
            case 311:
				return ({ tParameter(paNoPressDuringBuild); });
            case 312:
				return ({ tParameter(paNoPressDuringRetreat); });
            case 313:
				return ({ tParameter(paPartialDrawsAllowed); });
            case 314:
				return ({ tParameter(paPressTimeLimit); });
            case 315:
				return ({ tParameter(paRetreatTimeLimit); });
            case 316:
				return ({ tParameter(paUnowned); });
            case 317:
				return ({ tParameter(paDeadlineDisconnect); });
            case 318:
				return ({ tPress(prAlly); });
            case 319:
				return ({ tPress(prAND); });
            case 320:
				return ({ tPress(prNoneOfYourBusiness); });
            case 321:
				return ({ tPress(prDemiliterisedZone); });
            case 322:
				return ({ tPress(prELSE); });
            case 323:
				return ({ tPress(prExplain); });
            case 324:
				return ({ tPress(prRequestForward); });
            case 325:
				return ({ tPress(prFact); });
            case 326:
				return ({ tPress(prForTurn); });
            case 327:
				return ({ tPress(prHowToAttack); });
            case 328:
				return ({ tPress(prIDontKnow); });
            case 329:
				return ({ tPress(prIF); });
            case 330:
				return ({ tPress(prInsist); });
            case 331:
				return ({ tPress(prIOU); });
            case 332:
				return ({ tPress(prOccupy); });
            case 333:
				return ({ tPress(prOR); });
            case 334:
				return ({ tPress(prPeace); });
            case 335:
				return ({ tPress(prPosition); });
            case 336:
				return ({ tPress(prPPT); });
            case 337:
				return ({ tPress(prPropose); });
            case 338:
				return ({ tPress(prQuery); });
            case 339:
				return ({ tPress(prSupplyDistro); });
            case 340:
				return ({ tPress(prSorry); });
            case 341:
				return ({ tPress(prSuggest); });
            case 342:
				return ({ tPress(prThink); });
            case 343:
				return ({ tPress(prThen); });
            case 344:
				return ({ tPress(prTry); });
            case 345:
				return ({ tPress(prUOM); });
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
				return ({ tPress(prWRT); });
        }
	}
}
