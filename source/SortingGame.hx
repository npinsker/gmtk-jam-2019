package;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;

using nova.animation.Director;

class SortingGame extends ArcadeCabinet {

	public var score:Float = 0;
	
	public var judgeSprite:LocalSpriteWrapper;
	public var judgeIsBlue:Bool = true;
	
	public var background:FlxLocalSprite;
	public function new(callback:Void -> Void) {
		super('assets/images/sorting_cabinet_shell.png', [320, 256], [10, 10], callback);
		
		background = LocalWrapper.fromGraphic('assets/images/counter_splash.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
	}
	
	public function startGame() {
		phase = 1;

		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic('assets/images/counter_bg.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		
		var bx:BitmapData = new BitmapData(64, 64, true, 0xFF0000FF);
		judgeSprite = LocalWrapper.fromGraphic(bx);
		mainLayer.add(judgeSprite);
		judgeSprite.x = 70;
		judgeSprite.y = height / 2 - judgeSprite.height / 2;
		judgeIsBlue = true;
		
		score = 0;
		addBot();
	}
	
	public function addBot() {
		var b:LocalSpriteWrapper = LocalWrapper.fromGraphic(tiles.getTile(Std.int(Math.random() * 2 + 7)));
		mainLayer.add(b);
		clipSprites.push(b);

		b.x = judgeSprite.x + 6 * 60;
		b.y = judgeSprite.y;
		for (b in clipSprites) {
			Director.moveBy(b, [ -60, 0], 60).wait(25);
		}
		Director.wait(60 + 25).call(function() { addBot(); });
	}

	public function handleTap():Void {
		judgeIsBlue = !judgeIsBlue;
		
		if (judgeIsBlue) {
			judgeSprite._sprite.makeGraphic(32, 32, 0xFF0000FF);
		} else {
			judgeSprite._sprite.makeGraphic(32, 32, 0xFFFF0000);
		}
	}

	override public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (phase == 0) {
				startGame();
			} else if (phase == 1) {
				handleTap();
			}
		}
		if (InputController.justPressed(CANCEL)) {
			closeCallback();
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}