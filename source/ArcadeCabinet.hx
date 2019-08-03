package;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import nova.input.Focusable;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.utils.BitmapDataUtils;
import nova.utils.Pair;

class ArcadeCabinet extends FlxLocalSprite implements Focusable {
	public var backgroundLayer:FlxLocalSprite;
	public var mainLayer:FlxLocalSprite;
	public var foregroundLayer:FlxLocalSprite;
	public var closeCallback:Void -> Void;
	
	public var tiles:TiledBitmapData;
	public var clipSprites:Array<LocalSpriteWrapper>;

	public function new(cabinetImage:String = null, cabinetOffset:Pair<Int> = null, callback: Void -> Void) {
		super();
		
		backgroundLayer = new FlxLocalSprite();
		mainLayer = new FlxLocalSprite();
		foregroundLayer = new FlxLocalSprite();
		add(backgroundLayer);
		add(mainLayer);
		add(foregroundLayer);
		
		this.closeCallback = callback;
		this.width = 320;
		this.height = 320;
		this.clipSprites = [];
		
		tiles = new TiledBitmapData('assets/images/arcade_tiles_16x16.png', 16, 16, function(b) {
			return BitmapDataUtils.scaleFn(4, 4)(b);
		});
		
		if (cabinetImage != null) {
			var cabinetShell = LocalWrapper.fromGraphic('assets/images/rhythm_cabinet_shell.png', {
				'scale': [4, 4],
			});
			foregroundLayer.add(cabinetShell);
			cabinetShell.xy = -4 * cabinetOffset;
		}
	}

	override public function update(elapsed:Float):Void {
		for (sprite in clipSprites) {
			var left:Float = Math.max(0, -sprite.x);
			var right:Float = sprite.width - Math.max(0, sprite.x - (320 - sprite.width));
			var up:Float = Math.max(0, -sprite.y);
			var down:Float = sprite.height - Math.max(0, sprite.y - (320 - sprite.height));
			sprite._sprite.clipRect = new FlxRect(left, up, right - left, down - up);
		}
		super.update(elapsed);
	}

	public function handleInput():Void {
		trace("Warning: ArcadeCabinet class does not handle input!");
	}
}