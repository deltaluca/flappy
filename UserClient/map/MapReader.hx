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

class Map {
	public var provinces:Array<MapProvince>;
	var tree:AABBTree<MapProvince>;

	public var width:Float;
	public var height:Float;

	public function new(width:Float,height:Float,provinces:Iterable<MapProvince>) {
		this.width = width;
		this.height = height;

		tree = new AABBTree<MapProvince>();
		this.provinces = new Array<MapProvince>();
		for(p in provinces) {
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
			default:
				throw "unhandled transform type";
				return null;
		}
	}

	//take a string corresponding to the map file content
	public static function parse(mapdata:String):Map {
		var dict = new Hash<MapProvince>();

		var x = Xml.parse(mapdata).firstElement();
		for(g in x.elementsNamed("g")) {
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

		var w = Std.parseFloat(x.get("width"));
		var h = Std.parseFloat(x.get("height"));

		return new Map(w,h,dict);
	}	
}
