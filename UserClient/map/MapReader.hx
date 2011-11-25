package map;

import map.HLlr;
import map.HLex;

class MapReader {
	//take a string corresponding to the map file content
	public static function parse(mapdata:String) {
		var x = Xml.parse(mapdata).firstElement();
		for(g in x.elementsNamed("g")) {
			for(path in g.elementsNamed("path")) {
				var id = path.get("id");
				var d = path.get("d");
				trace(id +" path= "+HLlr.parse(HLex.lexify(d)));
			}
		}
	}	
}
