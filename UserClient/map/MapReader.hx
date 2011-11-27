package map;

import map.Path;
import nape.geom.Mat23;

typedef MapProvince = {id:String, paths:Array<Path>};

class MapReader {

	//should write a simple parser for this to handle everything
	//for now, handle only a single translate, with x,y mandatory and seperated by comma
	static function gettransform(xform:String) {
		if(xform==null) return new Mat23();
		var lr = xform.split("(");
		switch(lr[0]) {
			case "translate":
				var xy = lr[1].substr(0,lr[1].length-1).split(",");
				return Mat23.translation(Std.parseFloat(xy[0]), Std.parseFloat(xy[1]));
			default:
				throw "unhandled transform type";
				return null;
		}
	}

	//take a string corresponding to the map file content
	public static function parse(mapdata:String):Array<MapProvince> {
		var dict = new Hash<MapProvince>();
		var ret = new Array<MapProvince>();

		var x = Xml.parse(mapdata).firstElement();
		for(g in x.elementsNamed("g")) {
			for(epath in g.elementsNamed("path")) {
				var id = epath.get("id");
				var xform = gettransform(epath.get("transform"));
				var path = PathUtils.parse(epath.get("d"), xform);

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
