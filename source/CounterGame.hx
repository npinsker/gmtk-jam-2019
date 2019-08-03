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
	
	public var phase:Int = 0;
	public var score:Float = 0;
	public var wonRound:Bool = false;
	public var correctNumber:Int;
	public var remaining:Int;
	public var guessed:Int;
	public var guessedText:LocalWrapper<FlxText>;
	public var trueText:LocalWrapper<FlxText>;
	
	public var sprites:Array<LocalSpriteWrapper>;
	
	public var background:FlxLocalSprite;
	public function new(callback:Void -> Void) {
		super('assets/images/counter_cabinet_shell.png', [320, 256], [10, 10], callback);
		
		background = LocalWrapper.fromGraphic('assets/images/counter_splash.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		
		noteSprites = [];
		sprites = [];
	}
	
	public function startGame() {
		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic('assets/images/counter_bg.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		
		phase = 1;
		guessed = 0;
		guessedText = Utilities.createText();
		guessedText._sprite.size = 36;
		guessedText._sprite.text = "0";
		mainLayer.add(guessedText);
		
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
		potato.y = Math.random() * 204 + 30 - potato.height / 2;
		Director.moveTo(potato, [Std.int(this.width) + 30, Std.int(Math.random() * 204 + 30 - potato.height / 2)], Std.int(360 + Math.random() * 25)).call(function() {
			clipSprites.remove(potato);
			mainLayer.remove(potato);
		});
		
		if (remaining > 0) {
			Director.wait(Std.int(15 + 10 * Math.random())).call(function() { addPotato(); });
		} else {
			Director.wait(360).call(function() {
				endCounterPhase();
			});
		}
	}
	
	public function endCounterPhase() {
		wonRound = (guessed == correctNumber);
		mainLayer.remove(guessedText);
		phase = 2;
		
		guessedText._sprite.size = 96;
		
		trueText = new LocalWrapper<FlxText>(new FlxText());
		trueText._sprite.size = 96;
		trueText._sprite.font = 'assets/data/m3x6.ttf';
		trueText._sprite.text = Std.string(correctNumber);
		
		mainLayer.add(guessedText);
		mainLayer.add(trueText);
		
		guessedText.x = 100;
		trueText.x = this.width - 100 - trueText._sprite.textField.textWidth;
	}

	public function handleTap():Void {
		guessed += 1;
		guessedText._sprite.text = Std.string(guessed);
		Director.jumpInArc(guessedText, 8, 4).jumpInArc(3, 3);
	}

	public function handleAdvanceRound():Void {
		phase = 1;
		if (wonRound) {
			mainLayer.remove(guessedText);
			mainLayer.remove(trueText);
			startGame();
		} else {
			closeCallback();
		}
	}

	override public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (phase == 0) {
				startGame();
			} else if (phase == 1) {
				handleTap();
			} else if (phase == 2) {
				handleAdvanceRound();
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