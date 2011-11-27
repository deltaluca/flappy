package map;

import map.MapReader;
import nme.display.Sprite;
import nme.display.BitmapData;
import map.Path;

import nape.geom.Mat23;
import gui.MipMap;

class MapRender {

	public static function mipmap(mapdata:Array<MapProvince>) {
		return new MipMap([
//			render(mapdata, 3.5),
			render(mapdata, 3),
//			render(mapdata, 2.5),
			render(mapdata, 2),
//			render(mapdata, 1.5),
			render(mapdata, 1)
//			render(mapdata, 0.5)
		]);
	}

	public static function render_sprite(mapdata:Array<MapProvince>, ?scale:Float=1.0) {
		var spr = new Sprite();
		var g = spr.graphics;

		for(p in mapdata) {
			for(path in p.paths) {
				var polys = PathUtils.flatten(path, 0.4);
				var c = if(p.sea) 0xad834f;
				else {
					//power specific colour
					//hashed unplayable patterns?
					0xa2c2d5;
				}
				for(poly in polys) {
					poly.transform(Mat23.scale(scale,scale));
//					poly = poly.simplify(1);

					g.lineStyle(0,0,0);
					g.beginFill(c,1);
					PathUtils.draw_filled(poly,g);
					g.endFill();

					g.lineStyle(0.1,p.sea ? 0xa27242 : 0,1);
					PathUtils.draw(poly,g);
				}
			}
		}	

		return spr;
	}

	public static function render(mapdata:Array<MapProvince>, scale:Float) {
		var spr = render_sprite(mapdata,scale);
		var bit = new BitmapData(Std.int(spr.width),Std.int(spr.height),false,0);
		bit.draw(spr);
		return bit;
	}

}
