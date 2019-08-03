package;

import flixel.math.FlxRect;
import flixel.util.FlxColor;
import nova.render.FlxLocalSprite;
import nova.utils.Pair;

enum Direction {
	LEFT;
	UP;
	RIGHT;
	DOWN;
}

class Entity extends FlxLocalSprite {
	private static var __next_id:Int = 0;

	public var _internal_hitbox:FlxRect = null;
	public var id:Int;
	
	public var scratch:Dynamic = {};
	public var facingDir:Direction;

	public function new() {
		super();
		
		this.makeGraphic(32, 32, FlxColor.BLUE);
		_internal_hitbox = new FlxRect(0, 8, 32, 24);
		
		id = __next_id++;
	}
	
	public var hitbox(get, null):FlxRect;
	
	public function get_hitbox():FlxRect {
		if (_internal_hitbox == null) return null;
		
		return new FlxRect(_internal_hitbox.x + globalX,
		                   _internal_hitbox.y + globalY,
						   _internal_hitbox.width, _internal_hitbox.height);
	}
	
	public function getDirection():Pair<Int> {
		if (facingDir == LEFT) return [ -1, 0];
		if (facingDir == RIGHT) return [ 1, 0];
		if (facingDir == UP) return [ 0, -1];
		if (facingDir == DOWN) return [ 0, 1];
		return [0, 0];
	}
	
	public static function getNextID():Int {
		return __next_id;
	}
}