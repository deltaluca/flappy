package map;

import nme.display.BitmapData;
import nme.Assets;

typedef MapDefinition = { regions:String, mipmap:Array<BitmapData> };
typedef MapDict = { regions:Void->String, mipmap:Void->Array<BitmapData>, instance:MapDefinition };

class MapDef {
	static function instantiate(def:MapDict) {
		def.instance = { regions: def.regions(), mipmap: def.mipmap() };
	}

	static var dict = new Hash<MapDict>();
	public static function register(name:String, regions:Void->String, mipmap:Void->Array<BitmapData>) {
		dict.set(name, {regions:regions, mipmap:mipmap, instance:null});
	}

	public static function lookup(name:String) {
		name = name.toLowerCase();
		if(!dict.exists(name)) throw "map no exista";
		
		var def = dict.get(name);
		if(def.instance == null) instantiate(def);
		
		return def.instance;
	}
}
