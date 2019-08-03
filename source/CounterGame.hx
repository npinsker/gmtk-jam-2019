package;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;

using nova.animation.Director;

class CounterGame extends ArcadeCabinet {
	public var reticle:FlxLocalSprite;
	
	public var noteSprites:Array<FlxLocalSprite>;
	
	public var playing:Bool = false;
	public var score:Float = 0;
	public var scoreDisplay:LocalWrapper<FlxText>;
	public var correctNumber:Int;
	public var remaining:Int;
	
	public var sprites:Array<LocalSpriteWrapper>;
	
	public var background:FlxLocalSprite;
	public function new() {
		super('assets/images/rhythm_cabinet_shell.png', [10, 20]);
		
		background = LocalWrapper.fromGraphic('assets/images/counter_splash.png', {
			'scale': [4, 4],
		});
		mainLayer.add(background);
		
		noteSprites = [];
		sprites = [];
	}
	
	public function startGame() {
		mainLayer.remove(background);
		
		playing = true;
		
		correctNumber = Std.int(25 + Math.random() * 15);
		remaining = correctNumber;
		addPotato();
	}
	
	public function addPotato() {
		remaining -= 1;
		var potato:LocalSpriteWrapper = LocalWrapper.fromGraphic(tiles.stitchTiles([5, 6]), {
			animation: [0, 1],
			frameRate: 3,
		});
		clipSprites.push(potato);
		mainLayer.add(potato);
		potato.x = -30 - potato.width;
		potato.y = Math.random() * 380 + 50 - potato.height / 2;
		Director.moveTo(potato, [320 + 30, Std.int(Math.random() * 380 + 50 - potato.height / 2)], Std.int(360 + Math.random() * 25)).call(function() {
			clipSprites.remove(potato);
			mainLayer.remove(potato);
		});
		
		if (remaining > 0) {
			Director.wait(Std.int(15 + 10 * Math.random())).call(function() { addPotato(); });
		} else {
			Director.wait(60).call(function() {
				endCounterPhase();
			});
		}
	}
	
	public function endCounterPhase() {
		
	}

	public function handleTap():Void {
	}

	override public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (!playing) {
				startGame();
			} else {
				handleTap();
			}
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}