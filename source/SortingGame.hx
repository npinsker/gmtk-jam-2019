package;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.render.NovaEmitter;
import openfl.display.BitmapData;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;

using nova.animation.Director;

class SortingGame extends ArcadeCabinet {

	public var score:Int = 0;
	
	public var judgeSprite:LocalSpriteWrapper;
	public var judgeIsBlue:Bool = false;
	public var colors:Array<Int> = [];
	public var queuePosition:Int = -5;
	public var scoreDisplay:LocalWrapper<FlxText>;
	
	public var background:FlxLocalSprite;
	public function new(callback:Void -> Void, ?special:Bool = false) {
		super('assets/images/sorting_cabinet_shell.png', [320, 256], [10, 10], callback);
		
		background = LocalWrapper.fromGraphic('assets/images/sorting_splash.png', {
			'scale': [4, 4],
		});
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
		judgeSprite.x = 70;
		judgeSprite.y = height / 2 - judgeSprite.height / 2;

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
		var color = Std.int(Math.random() * 2);
		var tile = (!special ? color + 7 : 23 - color);
		var b:LocalSpriteWrapper = LocalWrapper.fromGraphic(tiles.getTile(tile));
		colors.push(color);
		mainLayer.add(b);
		clipSprites.push(b);
		
		var moveSpeed:Int = Std.int(60 - Math.min(2 * score / 3, 35) - Math.max(0, Math.min((score - 60) / 7, 20)));

		b.x = judgeSprite.x + 5 * 75;
		b.y = judgeSprite.y;
		for (b in clipSprites) {
			Director.moveBy(b, [ -75, 0], moveSpeed);
		}
		Director.wait(moveSpeed).call(checkDone);
	}
	
	public function checkDone() {
		var moveSpeed:Int = Std.int(60 - Math.min(2 * score / 3, 50));
		var waitSpeed:Int = Std.int(Math.max(3, moveSpeed / 4));

		queuePosition += 1;
		if (queuePosition >= 0) {
			var shouldBeBlue = (colors[queuePosition] == 1);
			if (shouldBeBlue == judgeIsBlue) {
				score += 1;
				
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

				scoreDisplay._sprite.text = Std.string(score);
				Director.wait(waitSpeed).call(addBot);
				
				if (special && Math.random() < 0.2 && clipSprites.length > 6) {
					Director.fadeOut(clipSprites[6], moveSpeed);
				}
			} else {
				endGame();
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
		var children = mainLayer.children.slice(0);
		for (child in children) {
			mainLayer.remove(child);
		}

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