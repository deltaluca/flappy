package map;

import map.Path;

class MapReader {
	//take a string corresponding to the map file content
	public static function parse(mapdata:String) {
		var x = Xml.parse(mapdata).firstElement();
		for(g in x.elementsNamed("g")) {
			for(epath in g.elementsNamed("path")) {
				var id = epath.get("id");
				var path = PathUtils.parse(epath.get("d"));
				trace(id +" path= "+path);
			}
		}
	}	
}
