package;

import flixel.FlxState;
import nova.animation.Director;
import nova.input.InputController;
import nova.render.FlxLocalSprite;

class PlayState extends FlxState {
	var player:FlxLocalSprite;
	
	override public function create():Void {
		super.create();
		
		player = new FlxLocalSprite();
		player.makeGraphic(40, 40, flixel.util.FlxColor.RED);
		add(player);
	}
	
	public function handleKeyPresses() {
		if (InputController.pressed(LEFT)) {
			player.x -= 4;
		} else if (InputController.pressed(RIGHT)) {
			player.x += 4;
		}
		
		if (InputController.pressed(UP)) {
			player.y -= 4;
		} else if (InputController.pressed(DOWN)) {
			player.y += 4;
		}
	}

	override public function update(elapsed:Float):Void {
		Director.update();
		
		handleKeyPresses();
		
		super.update(elapsed);
	}
}