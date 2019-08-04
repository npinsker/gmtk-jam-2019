package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import nova.animation.AnimationSet;
import nova.render.FlxLocalSprite;
import nova.utils.Pair;
import openfl.display.BitmapData;
import openfl.display.Sprite;

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
	public var type:String;
	public var name:String;
	public var zOffset:Int = 0;
	
	public var scratch:Dynamic = {};
	public var facingDir:Direction;
	public var spriteRef:FlxSprite = null;

	public function new(type:String, ?bitmapData:BitmapData, ?animationSet:AnimationSet) {
		super();
		id = __next_id++;
		
		this.type = type;

		if (bitmapData == null) {
			this.makeGraphic(32, 32, FlxColor.BLUE);
			width = height = 32;
			_internal_hitbox = new FlxRect(0, 8, 32, 24);
			return;
		}
		
		if (animationSet == null) {
			var newSprite:LocalSpriteWrapper = LocalSpriteWrapper.fromGraphic(bitmapData);
			spriteRef = newSprite._sprite;
			width = newSprite.width;
			height = newSprite.height;
			add(newSprite);
			return;
		}
		
		var newSprite:LocalSpriteWrapper = LocalSpriteWrapper.fromGraphic(bitmapData, {
			frameSize: [animationSet.spriteSize.x, animationSet.spriteSize.y]
		});
		width = newSprite.width;
		height = newSprite.height;
		animationSet.addToFlxSprite(newSprite._sprite);
		if (animationSet.names().indexOf('stand') != -1) {
			newSprite._sprite.animation.play('stand');
		}
		spriteRef = newSprite._sprite;
		add(newSprite);
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

	public function getDirectionString():String {
		if (facingDir == LEFT) return 'l';
		if (facingDir == RIGHT) return 'r';
		if (facingDir == UP) return 'u';
		if (facingDir == DOWN) return 'd';
		return null;
	}
	
	public static function getNextID():Int {
		return __next_id;
	}
}