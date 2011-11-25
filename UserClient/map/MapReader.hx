package map;

import map.Path;

typedef MapProvince = {id:String, paths:Array<Path>};

class MapReader {
	//take a string corresponding to the map file content
	public static function parse(mapdata:String):Array<MapProvince> {
		var dict = new Hash<MapProvince>();
		var ret = new Array<MapProvince>();

		var x = Xml.parse(mapdata).firstElement();
		for(g in x.elementsNamed("g")) {
			for(epath in g.elementsNamed("path")) {
				var id = epath.get("id");
				var path = PathUtils.parse(epath.get("d"));

				if(dict.exists(id))
					dict.get(id).paths.push(path);
				else {
					var prov = {id:id, paths:[path]};
					ret.push(prov);
					dict.set(id, prov);
				}
			}
		}

		return ret;
	}	
}
