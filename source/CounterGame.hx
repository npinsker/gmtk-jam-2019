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

class CounterGame extends FlxLocalSprite implements Focusable {
	public var reticle:FlxLocalSprite;
	
	public var tiles:TiledBitmapData;
	
	public var noteSprites:Array<FlxLocalSprite>;
	
	public var playing:Bool = false;
	public var score:Float = 0;
	public var scoreDisplay:LocalWrapper<FlxText>;
	public var correctNumber:Int;
	public var remaining:Int;
	
	public var sprites:Array<LocalSpriteWrapper>;
	
	public var mainLayer:FlxLocalSprite;
	public var foregroundLayer:FlxLocalSprite;
	
	public var background:FlxLocalSprite;
	public function new() {
		super();
		
		mainLayer = new FlxLocalSprite();
		foregroundLayer = new FlxLocalSprite();
		add(mainLayer);
		add(foregroundLayer);
		
		this.width = 320;
		this.height = 320;
		
		tiles = new TiledBitmapData('assets/images/arcade_tiles_16x16.png', 16, 16, function(b) {
			return BitmapDataUtils.scaleFn(4, 4)(b);
		});
		
		background = LocalWrapper.fromGraphic('assets/images/rhythm_splash.png', {
			'scale': [4, 4],
		});
		mainLayer.add(background);
		
		var cabinetShell = LocalWrapper.fromGraphic('assets/images/rhythm_cabinet_shell.png', {
			'scale': [4, 4],
		});
		foregroundLayer.add(cabinetShell);
		cabinetShell.xy = [ -40, -80];
		
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
		sprites.push(potato);
		mainLayer.add(potato);
		potato.x = -30 - potato.width;
		potato.y = Math.random() * 380 + 50 - potato.height / 2;
		Director.moveTo(potato, [320 + 30, Std.int(Math.random() * 380 + 50 - potato.height / 2)], Std.int(60 + Math.random() * 25)).call(function() {
			sprites.remove(potato);
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
		super.update(elapsed);
		
		for (sprite in sprites) {
			var left:Float = Math.max(0, -sprite.x);
			var right:Float = Math.min(320 - sprite.width, sprite.x);
			var up:Float = Math.max(0, -sprite.y);
			var down:Float = Math.min(320 - sprite.height, sprite.y);
			sprite._sprite.clipRect.set(left, up, right - left, down - up);
		}
	}
}