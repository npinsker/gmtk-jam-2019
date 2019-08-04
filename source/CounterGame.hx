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
import openfl.display.BitmapData;

using nova.animation.Director;

class CounterGame extends ArcadeCabinet {
	public var reticle:FlxLocalSprite;
	
	public var noteSprites:Array<FlxLocalSprite>;
	
	public var score:Int = 0;
	public var round:Int = 1;
	public var wonRound:Bool = false;
	public var correctNumber:Int;
	public var remaining:Int;
	public var guessed:Int;
	public var duckyGfx:LocalSpriteWrapper;
	public var guessedText:LocalWrapper<FlxText>;
	public var trueText:LocalWrapper<FlxText>;
	
	public var sprites:Array<LocalSpriteWrapper>;
	
	public var background:FlxLocalSprite;
	public function new(callback:Void -> Void, ?special:Bool = false) {
		super('assets/images/counter_cabinet_shell.png', [320, 256], [10, 10], callback);
		
		background = LocalWrapper.fromGraphic('assets/images/counter_splash.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		
		noteSprites = [];
		sprites = [];
		this.special = special;
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
		guessedText._sprite.color = FlxColor.BLACK;
		guessedText._sprite.size = 64;
		guessedText._sprite.text = "0";
		guessedText.xy = [52, 3];
		mainLayer.add(guessedText);
		
		duckyGfx = LocalWrapper.fromGraphic(tiles.getTile(17));
		duckyGfx.xy = [-9, 0];
		mainLayer.add(duckyGfx);
		
		correctNumber = Std.int(6 + 2 * round + Math.random() * (8 + 2 * round));
		remaining = correctNumber;
		addPotato();
	}
	
	public function addPotato() {
		remaining -= 1;
		var bd:BitmapData = tiles.stitchTiles(!special ? [5, 6] : [20, 21]);
		var destinationX:Float = Std.int(this.width) + 30;
		var flipping:Bool = ((round >= 4 || special) && Math.random() < 0.4);

		if (flipping) {
			bd = BitmapDataUtils.flip(bd, "|");
		}
		var potato:LocalSpriteWrapper = LocalWrapper.fromGraphic(bd, {
			animation: [0, 1],
			frameRate: 3,
		});

		clipSprites.push(potato);
		mainLayer.add(potato);
		potato.x = -30 - potato.width;
		potato.y = Math.random() * 184 + 40 - potato.height / 2;

		if (flipping) {
			var tmp = destinationX;
			destinationX = potato.x;
			potato.x = tmp;
		}
		
		var moveFrames:Int = Std.int(320 + Math.random() * 100 - (round < 15 ? 10 * round : 150));
		if (special && Math.random() < 0.1) {
			moveFrames = Std.int(55 + 20 * Math.random());
		}

		Director.moveTo(potato, [Std.int(destinationX), Std.int(Math.random() * 184 + 40 - potato.height / 2)], moveFrames).call(function() {
			clipSprites.remove(potato);
			mainLayer.remove(potato);
		});
		
		if (remaining > 0) {
			var spread = 30 - (round < 8 ? 2 * round : 16);
			var waitTime:Int = Std.int(60 + spread * Math.random() - (round < 14 ? 2 * round : 28) - (round < 3 ? 10 * round : 30));
			if (special) waitTime = Std.int(0.8 * waitTime);
			Director.wait(waitTime < 2 ? 2 : waitTime).call(function() { addPotato(); });
		} else {
			Director.wait(420).call(function() {
				endCounterPhase();
			});
		}
	}
	
	public function endCounterPhase() {
		wonRound = (guessed == correctNumber);
		phase = -1;
		
		var children = mainLayer.children.slice(0);
		for (child in children) {
			mainLayer.remove(child);
		}
		
		if (wonRound) {
			score += correctNumber;
		}
		
		Director.wait(60).call(function() {
			guessedText._sprite.size = 96;
			guessedText.x = 85;
			mainLayer.add(guessedText);
			
			var leftGfx = LocalWrapper.fromGraphic(tiles.getTile(17));
			leftGfx.xy = [guessedText.x - leftGfx.width - 2, 17];
			mainLayer.add(leftGfx);
		});
		
		Director.wait(120).call(function() {
			trueText = Utilities.createText();
			trueText._sprite.size = 96;
			trueText._sprite.text = Std.string(correctNumber);
			trueText._sprite.color = FlxColor.BLACK;
			trueText.y = guessedText.y;
			
			mainLayer.add(trueText);
			
			trueText.x = this.width - 85 - trueText._sprite.textField.textWidth;
			trueText._sprite.alignment = RIGHT;
			
			var rightGfx = LocalWrapper.fromGraphic(tiles.getTile(!special ? 5 : 20));
			rightGfx.xy = [trueText.x + trueText.width + 38, trueText.y + 17];
			mainLayer.add(rightGfx);
		});
		Director.wait(180).call(function() {
			var roundStatus:LocalSpriteWrapper;
			if (wonRound) {
				roundStatus = LocalWrapper.fromGraphic(tiles.stitchTiles([15]));
			} else {
				roundStatus = LocalWrapper.fromGraphic(tiles.stitchTiles([16]));
			}
			mainLayer.add(roundStatus);
			
			roundStatus.x = width / 2 - roundStatus.width / 2;
			roundStatus.y = height - 80;
			
			phase = 2;
		});
	}

	public function handleTap():Void {
		guessed += 1;
		guessedText._sprite.text = Std.string(guessed);
		Director.jumpInArc(duckyGfx, 8, 4).jumpInArc(3, 3);
		Director.jumpInArc(guessedText, 8, 4).jumpInArc(3, 3);
		SoundManager.addSound('increment', 0.8, 0.75, 6);
	}

	public function handleAdvanceRound():Void {
		phase = 1;
		var children = mainLayer.children.slice(0);
		for (child in children) {
			mainLayer.remove(child);
		}
		if (wonRound) {
			round += 1;
			startGame();
		} else {
			phase = 3;
			finishGame();
		}
	}

	public function finishGame() {
		phase = 3;
		var children = mainLayer.children.slice(0);
		for (child in children) {
			mainLayer.remove(child);
		}
		
		var idx = PlayerData.instance.highScores.get('ducky').add(Constants.PLAYER_NAME, score);

		var table = ArcadeCabinet.renderHighScores('ducky', FlxColor.BLACK);
		mainLayer.add(table);
		if (idx < table.children.length) {
			var nameField:LocalWrapper<FlxText> = cast table.children[idx].children[0];
			var scoreField:LocalWrapper<FlxText> = cast table.children[idx].children[1];
			nameField._sprite.color = new FlxColor(0xFF6600);
			scoreField._sprite.color = new FlxColor(0xFFAA00);
		}
		table.xy = [width/2 - table.width/2, height/2 - table.height/2];
	}

	override public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (phase == 0) {
				startGame();
			} else if (phase == 1) {
				handleTap();
			} else if (phase == 2) {
				handleAdvanceRound();
			} else if (phase == 3) {
				closeCallback();
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