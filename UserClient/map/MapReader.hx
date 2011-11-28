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
		paths.push(PathUtils.flatten(path,0.1));
	}
}

class MapNode {
	public var path:Polygon; //flattened singular path for containment test
	public var province:MapProvince; //related province in Map

	public function new(province:MapProvince, path:Polygon) {
		this.path = path;
		this.province = province;
	}

	public function bounds():AABB {
		var fst = path[0];
		var ret = new AABB(fst.x,fst.y,fst.x,fst.y);
		for(i in 1...path.length) ret.expand(path[i]);
		return ret;
	}

	// pre : p contained in path AABB
	public function contains(xy:Point) {
		var ret = false;
	
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

		return ret;
	}
}

class Map {
	public var provinces:Array<MapProvince>;
	var tree:AABBTree<MapNode>;

	public var width:Float;
	public var height:Float;

	public function new(width:Float,height:Float,provinces:Iterable<MapProvince>) {
		this.width = width;
		this.height = height;

		tree = new AABBTree<MapNode>();
		this.provinces = new Array<MapProvince>();
		for(p in provinces) {
			this.provinces.push(p);

			//add to tree
			for(path in p.paths) {
				var data = new MapNode(p,path);

				var node = new AABBNode<MapNode>(data);
				node.aabb = data.bounds();

				tree.insertLeaf(node);
			}
		}
	}

	public function province(xy:Point):MapProvince {
		return tree.traverse(xy, function (x:MapNode) return if(x.contains(xy)) x.province else null);	
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
