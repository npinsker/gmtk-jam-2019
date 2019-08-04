package;

import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import nova.input.Focusable;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;
import nova.utils.Pair;

class HighScore {
	public var name:String;
	public var score:Int;
	
	public function new(name:String, score:Int) {
		this.name = name;
		this.score = score;
	}
}
class HighScoreTable {
	public var rows:Array<HighScore>;
	
	public function new(names:Array<String>, scores:Array<Int>) {
		rows = [];
		for (i in 0...names.length) {
			rows.push(new HighScore(names[i], scores[i]));
		}
	}
	
	public function add(name:String, score:Int):Int {
		rows.push(new HighScore(name, score));
		
		var idx = rows.length - 1;
		while (idx > 0 && rows[idx].score > rows[idx - 1].score) {
			var t = rows[idx - 1];
			rows[idx - 1] = rows[idx];
			rows[idx] = t;
			
			idx -= 1;
		}
		rows.pop();
		
		return idx;
	}
}

class ArcadeCabinet extends FlxLocalSprite implements Focusable {
	public var backgroundLayer:FlxLocalSprite;
	public var mainLayer:FlxLocalSprite;
	public var foregroundLayer:FlxLocalSprite;
	public var closeCallback:Void -> Void;
	public var special:Bool = false;
	
	public var tiles:TiledBitmapData;
	public var clipSprites:Array<LocalSpriteWrapper>;
	public var highScoreTable:HighScoreTable;
	public var phase:Int = 0;

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
	
	public static function renderHighScores(source:String, ?color:FlxColor = FlxColor.WHITE):FlxLocalSprite {
		var highScoreTable = PlayerData.instance.highScores.get(source);
		var table:FlxLocalSprite = new FlxLocalSprite();
		for (i in 0...highScoreTable.rows.length) {
			var COLUMN_SEPARATION:Float = 140;
			var ROW_SEPARATION:Float = 38;

			var row:FlxLocalSprite = new FlxLocalSprite();
			table.add(row);
			row.y = ROW_SEPARATION * i;
			
			var lw:LocalWrapper<FlxText> = Utilities.createText();
			lw._sprite.size = 64;
			lw._sprite.text = highScoreTable.rows[i].name;
			lw._sprite.color = color;
			row.add(lw);

			var lw2:LocalWrapper<FlxText> = Utilities.createText();
			lw2._sprite.size = 64;
			lw2._sprite.text = Std.string(highScoreTable.rows[i].score);
			lw2._sprite.color = color;
			row.add(lw2);
			lw2.x = COLUMN_SEPARATION;
			
			table.width = Math.max(table.width, lw2._sprite.textField.textWidth + COLUMN_SEPARATION);
			table.height = row.y + lw2._sprite.textField.textHeight;
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