package;
import flixel.text.FlxText;
import nova.render.FlxLocalSprite.LocalWrapper;

class Utilities {
	public function new() {
		
	}
	
	public static function createText() {
		var lw:LocalWrapper<FlxText> = new LocalWrapper<FlxText>(new FlxText());
		lw._sprite.font = 'assets/data/m3x6.ttf';
		
		return lw;
	}
}