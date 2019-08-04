package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import openfl.display.BitmapData;
import shaders.InvertShader;

using nova.animation.Director;

class RhythmGame extends ArcadeCabinet {
	public var reticle:LocalSpriteWrapper;
	public var BPM:Float = 103.055;
	public var OFFSET:Float = 0.303;
	public var INPUT_LAG:Float = 0.01666;
	public var SCROLL_SPEED:Float = 220.0;
	
	public var notes:Array<Float> = [
		9, 11, 13, 14, 15,
		
		17, 19, 21, 22, 23,
		
		25, 27, 29, 30, 31,
		
		33, 35, 37, 38, 39,
		
		41, 43, 45, 46, 47,
		
		49, 50, 51, 53, 54, 55,
		
		57, 58, 59, 61, 62, 63,
		
		65, 66, 67, 69, 70, 71, 72,

		73, 74, 75, 77, 78, 79, 80,
		
		81, 83, 85, 86, 87,
		
		89, 91, 93, 94, 95,
		
		97, 99, 101, 102, 103,
		
		105, 107, 109, 110, 111,
		
		113
	];
	
	public var noteSprites:Array<LocalSpriteWrapper>;
	
	public var score:Int;
	public var maxScore:Int;
	public var scoreDisplay:LocalWrapper<FlxText>;
	public var gradeDisplay:LocalSpriteWrapper;
	public var shaders:Array<InvertShader>;
	public var invertActive:Bool = false;
	public var invertBeats:Array<Float>;
	
	public var background:LocalSpriteWrapper;
	public function new(callback:ArcadeCabinet -> Int -> Void, ?special:Bool = false) {
		super('assets/images/rhythm_cabinet_shell.png', [320, 320], [10, 20], callback);
		background = LocalWrapper.fromGraphic('assets/images/rhythm_splash.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		name = 'rhythm';
		
		noteSprites = [];
		this.special = special;
		
		if (this.special) {
			shaders = [];
			
			notes = [
				9, 11, 13, 13.5, 14, 14.5, 15,
				
				17, 17.5, 18, 19, 21, 21.5, 22, 23,
				
				25, 25.5, 26, 27, 29, 29.5, 30, 31,
				
				33, 33.5, 34, 35, 37, 37.5, 38, 39, 40,
				
				41, 41.5, 42, 43, 44, 45, 45.5, 46, 47,
				
				49, 49.5, 50, 50.5, 51, 53, 53.5, 54, 54.5, 55,
				
				57, 57.5, 58, 59, 60, 61, 61.5, 62, 63,
				
				65, 65.5, 66, 67, 68, 68.5, 69, 69.5, 70, 71, 72,

				73, 73.5, 74, 75, 77, 77.5, 78, 79,
				
				81, 83, 85, 85.5, 86, 86.5, 87, 87.5, 88, 88.5,
				
				89, 91, 93, 93.5, 94, 94.5, 95,
				
				97, 99, 101, 101.5, 102, 102.5, 103, 103.5, 104, 104.5,
				
				105, 107, 109, 109.5, 110, 110.5, 111,
				
				113
			];
			
			invertBeats = [17, 33, 49, 65, 73, 81, 83, 89, 91, 97, 99, 105, 107];
		}
	}
	
	public function initialGameSetup() {
		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic('assets/images/rhythm_bg.png', {
			'scale': [4, 4],
		});
		backgroundLayer.add(background);
		score = 0;
		maxScore = 4 * notes.length;
		scoreDisplay = Utilities.createText();
		scoreDisplay.xy = [25, -8];
		scoreDisplay._sprite.color = FlxColor.BLACK;
		scoreDisplay._sprite.size = 64;
		scoreDisplay._sprite.text = renderScore();
		mainLayer.add(scoreDisplay);

		gradeDisplay = LocalWrapper.fromGraphic(tiles.stitchTiles([30, 31, 32, 33]), {
			frameSize: [64, 64]
		});
		gradeDisplay._sprite.animation.add('c', [0], 1, false);
		gradeDisplay._sprite.animation.add('b', [1], 1, false);
		gradeDisplay._sprite.animation.add('a', [2], 1, false);
		gradeDisplay._sprite.animation.add('s', [3], 1, false);
		mainLayer.add(gradeDisplay);
		gradeDisplay.xy = [width - 24 - gradeDisplay.width, 0];

		reticle = LocalWrapper.fromGraphic(tiles.getTile(1));
		reticle.xy = [25, 160 - reticle.height/2];
		mainLayer.add(reticle);
	}
	
	public function startGame() {
		SoundManager.playMusic('jackpot');
		FlxG.sound.music.onComplete = finishGame;

		for (note in notes) {
			var s:LocalSpriteWrapper = LocalWrapper.fromGraphic(tiles.getTile(0));
			mainLayer.add(s);
			noteSprites.push(s);
			clipSprites.push(s);
			s.y = reticle.y;
		}
		
		var beat = (FlxG.sound.music.time / 1000 + OFFSET) / 60 * BPM;
		setNotePositions(beat);
		phase = 1;
		
		if (special) {
			background._sprite.shader = new InvertShader();
			shaders.push(cast background._sprite.shader);
			shaders[shaders.length - 1].active.value = [false];
			for (child in mainLayer.children) {
				var ls:LocalSpriteWrapper = cast child;
				ls._sprite.shader = new InvertShader();
				shaders.push(cast ls._sprite.shader);
				shaders[shaders.length - 1].active.value = [false];
			}
		}
	}
	
	public function invert() {
		invertActive = !invertActive;
		for (shader in shaders) {
			shader.active.value = [invertActive];
		}
	}
	
	public function handleTap():Void {
		var beat = (FlxG.sound.music.time / 1000 + OFFSET - INPUT_LAG) / 60 * BPM;
		for (i in 0...notes.length) {
			if (!noteSprites[i].visible) continue;

			var note:Float = notes[i];
			var distanceInFrames:Float = Math.abs(note - beat) / BPM * 60 * FlxG.updateFramerate;

			if (distanceInFrames <= 8) {
				noteSprites[i].visible = false;
				var flash:FlxLocalSprite = new FlxLocalSprite();
				flash.xy = reticle.xy;
				
				if (distanceInFrames <= 2) {
					score += 4;
					flash.loadGraphic(tiles.getTile(2));
				} else if (distanceInFrames <= 5) {
					score += 3;
					flash.loadGraphic(tiles.getTile(3));
				} else {
					score += 1;
					flash.loadGraphic(tiles.getTile(4));
				}
				var realScore = getRealScore();
				if (realScore > 970000) {
					gradeDisplay._sprite.animation.play('s');
				} else if (realScore > 800000) {
					gradeDisplay._sprite.animation.play('a');
				} else if (realScore > 650000) {
					gradeDisplay._sprite.animation.play('b');
				} else {
					gradeDisplay._sprite.animation.play('c');
				}
				add(flash);
				
				Director.wait(1).call(function() { remove(flash); });
				
				scoreDisplay._sprite.text = renderScore();
				break;
			}
		}
	}
	
	public function getRealScore() {
		return Std.int(Math.round(score / maxScore * 1000000 / 10) * 10 + 0.5);
	}
	
	public function renderScore() {
		return Std.string(getRealScore());
	}
	
	public function finishGame() {
		phase = 2;
		backgroundLayer.remove(background);
		background = LocalWrapper.fromGraphic(new BitmapData(Std.int(width), Std.int(height), false, 0xFF000000));
		backgroundLayer.add(background);
		FlxG.sound.music.stop();
		
		var idx = PlayerData.instance.highScores.get('rhythm').add(Constants.PLAYER_NAME, getRealScore());
		
		clearScreen();

		var table = ArcadeCabinet.renderHighScores('rhythm');
		mainLayer.add(table);
		if (idx < table.children.length) {
			var nameField:LocalWrapper<FlxText> = cast table.children[idx].children[0];
			var scoreField:LocalWrapper<FlxText> = cast table.children[idx].children[1];
			nameField._sprite.color = new FlxColor(0xFF6600);
			scoreField._sprite.color = new FlxColor(0xFFAA00);
		}
		table.xy = [width/2 - table.width/2, height/2 - table.height/2];
	}
	
	public function setNotePositions(beat:Float):Void {
		for (i in 0...notes.length) {
			noteSprites[i].x = reticle.x + SCROLL_SPEED * (notes[i] - beat);
		}
	}

	override public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (phase == 0) {
				SoundManager.addSound('advance', 0.4);
				phase = -1;
				initialGameSetup();
				Director.wait(30).call(startGame);
			} else if (phase == 1) {
				handleTap();
			} else {
				FlxG.sound.music.stop();
				closeCallback(this, getRealScore());
			}
		}
		if (InputController.justPressed(CANCEL)) {
			FlxG.sound.music.stop();
			closeCallback(this, 0);
		}

		#if debug
		if (InputController.justPressed(X)) {
			FlxG.sound.music.stop();
			closeCallback(this, 1000000);
		}
		#end
	}
	
	override public function update(elapsed:Float):Void {
		if (phase == 1) {
			var beat = (FlxG.sound.music.time / 1000 + OFFSET) / 60 * BPM;
			setNotePositions(beat);
			
			if (special && invertBeats.length > 0 && beat > invertBeats[0]) {
				FlxG.camera.shake(0.008, 0.09);
				invert();
				invertBeats.splice(0, 1);
			}
		}
		
		super.update(elapsed);
	}
}