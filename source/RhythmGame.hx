package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;

using nova.animation.Director;

class RhythmGame extends FlxLocalSprite implements Focusable {
	public var reticle:FlxLocalSprite;
	public var BPM:Float = 85.000;
	public var OFFSET:Float = 0.122;
	public var INPUT_LAG:Float = 0.01666;
	public var SCROLL_SPEED:Float = 320.0;
	
	public var tiles:TiledBitmapData;
	
	public var notes:Array<Float> = [
		5, 7, 9, 11, 12, 12.83333, 13, 14, 14.83333, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37,
		39, 41, 43, 44, 45, 46, 47, 48, 49, 50, 51, 51.83333, 52,
		53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64,
		64.5, 64.83333, 65.16666, 65.5, 65.83333, 66.16666, 66.5,
		68.5, 69.5, 70.5, 71.5, 72.5, 72.83333, 73.16666, 73.5, 73.83333, 74.16666, 74.5, 75.5,
		76.5, 77.5, 78.5, 79.5, 80.5, 81, 81.5, 82, 82.5, 83, 83.5, 84,
		84.5, 85.5, 86.5,
	];
	
	public var noteSprites:Array<FlxLocalSprite>;
	
	public var playing:Bool = false;
	public var score:Float = 0;
	public var scoreDisplay:LocalWrapper<FlxText>;
	
	public var background:FlxLocalSprite;
	public function new() {
		super();
		
		this.width = 320;
		this.height = 320;
		
		tiles = new TiledBitmapData('assets/images/arcade_tiles_16x16.png', 16, 16, function(b) {
			return BitmapDataUtils.scaleFn(4, 4)(b);
		});
		
		background = LocalWrapper.fromGraphic('assets/images/rhythm_splash.png', {
			'scale': [4, 4],
		});
		add(background);
		
		noteSprites = [];
	}
	
	public function startGame() {
		remove(background);
		SoundManager.playMusic('island');
		
		scoreDisplay = new LocalWrapper<FlxText>(new FlxText());
		scoreDisplay.color = FlxColor.WHITE;
		scoreDisplay.xy = [40, 40];
		scoreDisplay._sprite.size = 36;
		scoreDisplay._sprite.text = "Score: " + score;
		add(scoreDisplay);

		reticle = new FlxLocalSprite();
		reticle.loadGraphic(tiles.getTile(1));
		reticle.xy = [80, 160];
		add(reticle);

		for (note in notes) {
			var s:FlxLocalSprite = new FlxLocalSprite();
			s.loadGraphic(tiles.getTile(0));
			add(s);
			noteSprites.push(s);
			s.y = reticle.y;
		}
		
		var beat = (FlxG.sound.music.time / 1000 + OFFSET) / 60 * BPM;
		setNotePositions(beat);
		playing = true;
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
					score += 3;
					flash.loadGraphic(tiles.getTile(2));
				} else if (distanceInFrames <= 5) {
					score += 2;
					flash.loadGraphic(tiles.getTile(3));
				} else {
					score += 1;
					flash.loadGraphic(tiles.getTile(4));
				}
				add(flash);
				
				Director.wait(1).call(function() { remove(flash); });
				
				scoreDisplay._sprite.text = "Score: " + score;
				break;
			}
		}
	}
	
	public function setNotePositions(beat:Float):Void {
		for (i in 0...notes.length) {
			noteSprites[i].x = reticle.x + SCROLL_SPEED * (notes[i] - beat);
		}
	}

	public function handleInput():Void {
		if (InputController.justPressed(CONFIRM)) {
			if (!playing) {
				startGame();
			} else {
				handleTap();
			}
		}
	}
	
	override public function update(elapsed:Float):Void {
		if (playing) {
			var beat = (FlxG.sound.music.time / 1000 + OFFSET) / 60 * BPM;
			setNotePositions(beat);
		}
	}
}