package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.render.NovaEmitter;
import openfl.display.BitmapData;
import nova.input.InputController;
import nova.render.FlxLocalSprite;

using nova.animation.Director;

class SortingGame extends ArcadeCabinet {

	public var score:Int = 0;
	public static var NUMBER_IN_SPECIAL_ROUND:Int = 60;
	
	public var judgeSprite:LocalSpriteWrapper;
	public var judgeIsBlue:Bool = false;
	public var colors:Array<Int> = [];
	public var queuePosition:Int = -5;
	public var scoreDisplay:LocalWrapper<FlxText>;
	public var spritesAdded:Int = 0;
	
	public var background:FlxLocalSprite;
	public function new(callback:ArcadeCabinet -> Int -> Void, ?special:Bool = false) {
		super('assets/images/sorting_cabinet_shell.png', [320, 256], [10, 10], callback);
		
		background = LocalWrapper.fromGraphic('assets/images/sorting_splash.png', {
			'scale': [4, 4],
			'animation': [0, 1],
			'frameRate': 2,
		});
		name = 'sorting';
		backgroundLayer.add(background);
		this.special = special;
		this.special = true;
	}
	
	public function startGame() {
		phase = 1;

		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic('assets/images/sorting_bg.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		
		judgeSprite = LocalWrapper.fromGraphic(tiles.stitchTiles([9, 10]), {
			frameSize: [64, 64]
		});
		judgeSprite._sprite.animation.add('red', [0], 1, false);
		judgeSprite._sprite.animation.add('blue', [1], 1, false);
		judgeSprite._sprite.animation.play('red');
		mainLayer.add(judgeSprite);
		judgeSprite.x = 50;
		judgeSprite.y = 164;

		scoreDisplay = Utilities.createText();
		scoreDisplay.xy = [25, -8];
		scoreDisplay._sprite.color = FlxColor.WHITE;
		scoreDisplay._sprite.size = 64;
		scoreDisplay._sprite.text = "0";
		mainLayer.add(scoreDisplay);
		
		score = 0;
		addBot();
	}
	
	public function addBot() {
		if (!special || spritesAdded < NUMBER_IN_SPECIAL_ROUND) {
			var color = Std.int(Math.random() * 2);
			var tile = (!special ? color + 7 : 23 - color);
			var b:LocalSpriteWrapper = LocalWrapper.fromGraphic(tiles.getTile(tile));
			colors.push(color);
			mainLayer.add(b);
			clipSprites.push(b);
			spritesAdded += 1;
			b.x = judgeSprite.x + 5 * 75;
			b.y = judgeSprite.y;
		}
		
		var moveSpeed:Int = Std.int(60 - Math.min(1.3 * score, 35) - Math.max(0, Math.min((score - 40) / 7, 20)));
		for (b in clipSprites) {
			Director.moveBy(b, [ -75, 0], moveSpeed);
		}
		Director.wait(null, moveSpeed, '__sortingGame').call(checkDone);
	}
	
	public function checkDone() {
		var moveSpeed:Int = Std.int(60 - Math.min(2 * score / 3, 50));
		var waitSpeed:Int = Std.int(Math.max(3, moveSpeed / 4));

		queuePosition += 1;
		if (queuePosition >= 0) {
			var shouldBeBlue = (colors[queuePosition] == 1);
			if (shouldBeBlue == judgeIsBlue) {
				score += 1;
				SoundManager.addSound('advance', 0.4);
				scoreDisplay._sprite.text = Std.string(score);
				
				if (special && score == NUMBER_IN_SPECIAL_ROUND) {
					Director.wait(90).call(function() {
						Director.clearTag('__sortingGame');
						closeCallback(this, 1000);
					});
					return;
				}
				
				var amtToSpawn:Int = Std.int(Math.max(4, 20 - score / 3));
				var px:NovaEmitter = new NovaEmitter(judgeSprite.x, judgeSprite.y);
				px.addSimpleParticles((shouldBeBlue ? 0xFF2211FF : 0xFFFF1122), 4, amtToSpawn);
				mainLayer.add(px);
				px.lifespan = [0.12, 0.35];
				px.endAlpha = [0, 0];
				px.limit = amtToSpawn;
				px.launchAngle = [-Math.PI / 2, -Math.PI / 2];
				px.onCreate = function(p) { p.x = Math.random() * 64; p.y = Math.random() * 10; };
				px.speed = [150, 200];
				px.rate = 0.01;

				Director.wait(null, waitSpeed, '__sortingGame').call(addBot);
				
				if (special && Math.random() < (0.2 + score/300) && clipSprites.length > 8 && clipSprites[8].alpha >= 0.99 && score > 10) {
					Director.fadeOut(clipSprites[8], moveSpeed);
				}
			} else {
				phase = -1;
				FlxG.camera.shake(0.02, 0.2);
				Director.wait(70).call(clearScreen);
				Director.wait(90).call(endGame);
				SoundManager.addSound('explosion', 0.6, 0.6);
			}
		} else {
			Director.wait(waitSpeed).call(addBot);
		}
		
		if (colors.length > 10) {
			mainLayer.remove(clipSprites[0]);
			clipSprites.splice(0, 1);
			colors.splice(0, 1);
			queuePosition -= 1;
		}
	}

	public function handleTap():Void {
		judgeIsBlue = !judgeIsBlue;
		
		if (judgeIsBlue) {
			judgeSprite._sprite.animation.play('blue');
		} else {
			judgeSprite._sprite.animation.play('red');
		}
	}
	
	public function endGame():Void {
		phase = 2;
		
		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic(new BitmapData(Std.int(width), Std.int(height), false, 0xFFEFCB92));
		backgroundLayer.add(background);
		
		var idx = PlayerData.instance.highScores.get('sorting').add(Constants.PLAYER_NAME, score);
		clearScreen();

		var table = ArcadeCabinet.renderHighScores('sorting', FlxColor.BLACK);
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
				Director.clearTag('__sortingGame');
				closeCallback(this, score);
			}
		}
		if (InputController.justPressed(CANCEL)) {
			phase = -1;
			Director.clearTag('__sortingGame');
			closeCallback(this, 0);
		}
		#if debug
		if (InputController.justPressed(X)) {
			Director.clearTag('__sortingGame');
			closeCallback(this, 1000);
		}
		#end
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
}