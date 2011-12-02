package map;

import map.Path;
import map.DynAABB;
import nme.geom.Matrix;
import nme.geom.Point;

using StringTools;

class MapProvince {
	public var id:String;
	public var paths:Array<Polygon>; //flattened bezier paths

	public function new(id:String, paths:Array<Path>) {
		this.id = id;
		this.paths = new Array<Polygon>();
		concat(paths);
	}

	public function concat(paths:Array<Path>) for(path in paths) push(path)
	inline public function push(path:Path) {
		paths.push(PathUtils.flatten(path,2));
	}	

	public function bounds():AABB {
		var fst = paths[0][0];
		var ret = new AABB(fst.x,fst.y,fst.x,fst.y);
		for(path in paths) {
			for(p in path) ret.expand(p);
		}
		return ret;
	}

	// pre : though uneccesary, we note that we assume xy in bounds() at entry so we need not evaluate that
	public function contains(xy:Point) {
		var ret = false;
	
		for(path in paths) {
			var p0 = null;
			for(p in path) {
				var q = if(p0==null) path[path.length-1] else p0;
	
				if((p.y < xy.y && q.y >= xy.y
				||  q.y < xy.y && p.y >= xy.y)
				&& (p.x <= xy.x || q.x <= xy.x)) {
					if(p.x+(xy.y-p.y)/(q.y-p.y)*(q.x-p.x) < xy.x)
						ret = !ret;
				}
	
				p0 = p;
			}
		}

		return ret;
	}
}

class MapNames {
	//map province id to name
	var names_str:IntHash<String>;
	//map province name to id
	var names_int:Hash<Int>;

	public function nameOf(id:Int) return names_str.get(id)
	public function idOf(name:String) return names_int.get(name)

	public function new(names:Array<{name:String,id:Int}>) {
		names_str = new IntHash<String>();
		names_int = new Hash<Int>();

		for(n in names) {
			names_str.set(n.id,n.name);
			names_int.set(n.name,n.id);
		}
	}
}

class Map {
	public var provinces:Array<MapProvince>;
	var tree:AABBTree<MapProvince>;

	public var supplies:Hash<Point>;

	public var width:Float;
	public var height:Float;
	
	public function new(width:Float,height:Float,provinces:Iterable<MapProvince>) {
		this.width = width;
		this.height = height;

		tree = new AABBTree<MapProvince>();
		this.provinces = new Array<MapProvince>();

		supplies = new Hash<Point>();

		for(p in provinces) {
			//check for supply centre locations!!
			if(p.id.substr(0,3)=="SC ") {
				var bounds = p.bounds();
				supplies.set(p.id.substr(3), new Point(bounds.minx+bounds.width()/2,bounds.miny+bounds.height()/2));
				continue;
			}			

			this.provinces.push(p);

			var node = new AABBNode<MapProvince>(p);
			node.aabb = p.bounds();
			tree.insertLeaf(node);
		}
	}

	public function province(xy:Point):MapProvince {
		return tree.traverse(xy, function (x:MapProvince) return if(x.contains(xy)) x else null);	
	}
}

class MapReader {

	//should write a simple parser for this to handle everything
	//for now, handle only a single translate, with x,y mandatory and seperated by comma
	static function gettransform(xform:String) {
		if(xform==null) return new Matrix();
		var lr = xform.split("(");
		switch(lr[0]) {
			case "translate":
				var xy = lr[1].substr(0,lr[1].length-1).split(",");
				return new Matrix(1,0,0,1,Std.parseFloat(xy[0]), Std.parseFloat(xy[1]));
			case "matrix":
				var xy = lr[1].substr(0,lr[1].length-1).split(",");
				var rs = []; for(x in xy) rs.push(Std.parseFloat(x));
				return new Matrix(rs[0],rs[1],rs[2],rs[3],rs[4],rs[5]);	
			default:
				throw "unhandled transform type";
				return null;
		}
	}

	//take string correpsonding to map name id pairs
	public static function names(mapnames:String):MapNames {
		var names = mapnames.split("\n");
		var ret = [];
		for(n in names) {
			var n2 = (~/[\t\r\n]/g).replace(StringTools.trim(n)," ");
			var rs = n2.split(" ");
			if(rs.length<2) continue;

			ret.push({name:(~/_/g).replace(rs[0]," "),id:Std.parseInt(StringTools.trim(rs[rs.length-1]))});
		}
		return new MapNames(ret);
	}

	//take a string corresponding to the map file content
	public static function parse(mapdata:String):Map {
		var dict = new Hash<MapProvince>();
		var x = Xml.parse(mapdata).firstElement();

		function parseg(g:Xml) {
			for(g2 in g.elementsNamed("g")) parseg(g2);
			for(epath in g.elementsNamed("path")) {
				var id = (~/_/g).replace(epath.get("id"), " ").trim();
				var xform = gettransform(epath.get("transform"));
				var paths = PathUtils.parse(epath.get("d"), xform);

				if(dict.exists(id))
					dict.get(id).concat(paths);
				else {
					var prov = new MapProvince(id,paths);
					dict.set(id, prov);
				}
			}
		}
		parseg(x);

		var w = Std.parseFloat(x.get("width"));
		var h = Std.parseFloat(x.get("height"));

		return new Map(w,h,dict);
	}	
}
