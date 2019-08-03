package;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import nova.render.FlxLocalSprite;

/**
 * ...
 * @author ...
 */
class Entity extends FlxLocalSprite {
	public var _internal_hitbox:FlxRect = null;

	public function new() {
		super();
		
		this.makeGraphic(32, 32, FlxColor.BLUE);
		_internal_hitbox = new FlxRect(0, 8, 32, 24);
	}
	
	public var hitbox(get, null):FlxRect;
	
	public function get_hitbox():FlxRect {
		if (_internal_hitbox == null) return null;
		
		return new FlxRect(_internal_hitbox.x + globalX,
		                   _internal_hitbox.y + globalY,
						   _internal_hitbox.width, _internal_hitbox.height);
	}
}