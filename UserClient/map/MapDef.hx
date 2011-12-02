package map;

import nme.display.BitmapData;
import nme.Assets;

typedef MapDefinition = { regions:String, names:String, mipmap:Array<BitmapData> };
typedef MapDict = { regions:Void->String, names:Void->String, mipmap:Void->Array<BitmapData>, instance:MapDefinition };

/**

	Hold map generator definitions, to be expanded at load/run time and queried when loading a map
	for a game.

	Definitions are factories so as to be constructed lazily with memory.

	# regions : String corresponds to actual .svg file data for map.
	# names : String corresponds to data file mapping province names to province ids.
	# mipmap : Array<BitmapData> corresponds to an ordered (large first) set of bitmaps for rendering.

*/

class MapDef {
	static function instantiate(def:MapDict) {
		def.instance = { regions: def.regions(), names: def.names(), mipmap: def.mipmap() };
	}

	static var dict = new Hash<MapDict>();
	public static function register(name:String, regions:Void->String, names:Void->String, mipmap:Void->Array<BitmapData>) {
		dict.set(name, {regions:regions, names:names, mipmap:mipmap, instance:null});
	}

	public static function lookup(name:String) {
		name = name.toLowerCase();
		if(!dict.exists(name)) throw "map no exista";
		
		var def = dict.get(name);
		if(def.instance == null) instantiate(def);
		
		return def.instance;
	}
}
