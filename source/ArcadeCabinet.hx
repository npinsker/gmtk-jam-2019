package;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.input.Focusable;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;
import nova.utils.Pair;

class HighScoreTable {
	public var names:Array<String>;
	public var scores:Array<Int>;
	
	public function new(names:Array<String>, scores:Array<Int>) {
		this.names = names.slice(0);
		this.scores = scores.slice(0);
	}
	
	public function add(name:String, score:Int):Int {
		scores.push(score);
		names.push(name);
		
		var idx = scores.length - 1;
		while (idx > 0 && scores[idx] > scores[idx - 1]) {
			var t = scores[idx - 1];
			scores[idx - 1] = scores[idx];
			scores[idx] = t;
			
			var u = names[idx - 1];
			names[idx - 1] = names[idx];
			names[idx] = u;
			idx -= 1;
		}
		scores.pop();
		names.pop();
		
		return idx;
	}
}

class ArcadeCabinet extends FlxLocalSprite implements Focusable {
	public var backgroundLayer:FlxLocalSprite;
	public var mainLayer:FlxLocalSprite;
	public var foregroundLayer:FlxLocalSprite;
	public var closeCallback:Void -> Void;
	
	public var tiles:TiledBitmapData;
	public var clipSprites:Array<LocalSpriteWrapper>;
	public var highScoreTable:HighScoreTable;

	public function new(cabinetImage:String = null, dims:Pair<Int>, cabinetOffset:Pair<Int> = null, callback: Void -> Void) {
		super();
		
		backgroundLayer = new FlxLocalSprite();
		mainLayer = new FlxLocalSprite();
		foregroundLayer = new FlxLocalSprite();
		add(backgroundLayer);
		add(mainLayer);
		add(foregroundLayer);
		
		this.closeCallback = callback;
		this.width = dims.x;
		this.height = dims.y;
		this.clipSprites = [];
		
		tiles = new TiledBitmapData('assets/images/arcade_tiles_16x16.png', 16, 16, function(b) {
			return BitmapDataUtils.scaleFn(4, 4)(b);
		});
		
		if (cabinetImage != null) {
			var cabinetShell = LocalWrapper.fromGraphic(cabinetImage, {
				'scale': [4, 4],
			});
			foregroundLayer.add(cabinetShell);
			cabinetShell.xy = -4 * cabinetOffset;
		}
	}
	
	public function renderHighScores(?color:FlxColor = FlxColor.WHITE):FlxLocalSprite {
		var table:FlxLocalSprite = new FlxLocalSprite();
		for (i in 0...highScoreTable.names.length) {
			var lw:LocalWrapper<FlxText> = Utilities.createText();
			lw._sprite.size = 64;
			lw._sprite.text = highScoreTable.names[i];
			lw._sprite.color = color;

			var lw2:LocalWrapper<FlxText> = Utilities.createText();
			lw2._sprite.size = 64;
			lw2._sprite.text = Std.string(highScoreTable.scores[i]);
			lw._sprite.color = color;
			
			table.add(lw);
			lw.y = 40 * i;
			
			table.add(lw2);
			
			var COLUMN_SEPARATION:Float = 140;
			var ROW_SEPARATION:Float = 35;
			
			lw2.x = COLUMN_SEPARATION;
			lw2.y = ROW_SEPARATION * i;
			
			table.width = Math.max(table.width, lw2._sprite.textField.textWidth + COLUMN_SEPARATION);
			table.height = lw2.y + lw2._sprite.textField.textHeight;
		}
		
		return table;
	}

	override public function update(elapsed:Float):Void {
		for (sprite in clipSprites) {
			var left:Float = Math.max(0, -sprite.x);
			var right:Float = sprite.width - Math.max(0, sprite.x - (this.width - sprite.width));
			var up:Float = Math.max(0, -sprite.y);
			var down:Float = sprite.height - Math.max(0, sprite.y - (this.height - sprite.height));
			sprite._sprite.clipRect = new FlxRect(left, up, right - left, down - up);
		}
		super.update(elapsed);
	}

	public function handleInput():Void {
		trace("Warning: ArcadeCabinet class does not handle input!");
	}
}