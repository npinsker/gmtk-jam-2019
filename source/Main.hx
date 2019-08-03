package;

import flixel.FlxGame;
import nova.input.InputController;
import openfl.display.Sprite;

class Main extends Sprite {
	public function new() {
		super();

		addChild(new FlxGame(0, 0, PlayState, 1, 60, 60, true));
		
		InputController.addKeyMapping(A, LEFT);
		InputController.addKeyMapping(LEFT, LEFT);
		InputController.addKeyMapping(D, RIGHT);
		InputController.addKeyMapping(RIGHT, RIGHT);
		InputController.addKeyMapping(W, UP);
		InputController.addKeyMapping(UP, UP);
		InputController.addKeyMapping(S, DOWN);
		InputController.addKeyMapping(DOWN, DOWN);
		
		InputController.addKeyMapping(SPACE, CONFIRM);
		InputController.addKeyMapping(BACKSPACE, CANCEL);
		InputController.addKeyMapping(ESCAPE, CANCEL);
		
		#if debug
		InputController.addKeyMapping(X, X);
		#end
	}
}
