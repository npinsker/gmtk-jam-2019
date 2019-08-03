package;

using nova.utils.ArrayUtils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import nova.animation.AnimationSet;
import nova.animation.Director;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.render.TiledBitmapData;
import nova.tile.TileUtils;
import nova.tiled.TiledRenderer;
import nova.ui.dialog.DialogBox;
import openfl.display.BitmapData;

class PlayState extends FlxState {
	var TILE_WIDTH:Int = 32;
	var TILE_HEIGHT:Int = 32;
	var PLAYER_SPEED:Float = 3.0;  // will be 1.8 in final version
	
	var p:Entity;
	
	var entities:Array<Entity>;
	
	var backgroundLayer:FlxLocalSprite;
	// Must only add Entity to this layer!!
	var entityLayer:FlxLocalSprite;
	var foregroundLayer:FlxLocalSprite;
	var tileAccessor:TiledBitmapData;
	
	var focus:Array<Focusable>;
	var dialogBox:DialogBox;
	var speakTarget:Int = -1;
	
	override public function create():Void {
		super.create();
		
		backgroundLayer = new FlxLocalSprite();
		add(backgroundLayer);
		
		entityLayer = new FlxLocalSprite();
		add(entityLayer);
		
		tileAccessor = new TiledBitmapData('assets/images/test.png', 32, 32);

		var playerBitmap:BitmapData = tileAccessor.stitchTiles([96, 97, 98, 99, 112, 113, 114, 115, 128, 129, 130, 131]);
		var as:AnimationSet = new AnimationSet([32, 32], [
			new AnimationFrames('stand', [0, 1], 3),
			new AnimationFrames('d', [2, 3], 4),
			new AnimationFrames('l', [4, 5], 4),
			new AnimationFrames('r', [6, 7], 4),
			new AnimationFrames('u', [10, 11], 4),
		]);
		p = new Entity(playerBitmap, as);
		p._internal_hitbox = new FlxRect(1, 24, 16, 7);
		entityLayer.add(p);
		
		entities = [];
		
		for (i in 0...10) {
			entities.push(new Entity());
			entities.last().x = Math.random() * (FlxG.width - entities.last().width);
			entities.last().y = Math.random() * (FlxG.height - entities.last().height);
			entityLayer.add(entities.last());
		}
		
		focus = [];
		
		foregroundLayer = new FlxLocalSprite();
		add(foregroundLayer);
	}
	
	public function handleInput() {
		var triedToMove:Bool = false;
		
		if (!triedToMove) {
			if (InputController.pressed(LEFT)) {
				p.x -= PLAYER_SPEED;
				triedToMove = true;
				p.facingDir = Entity.Direction.LEFT;
			} else if (InputController.pressed(RIGHT)) {
				p.x += PLAYER_SPEED;
				triedToMove = true;
				p.facingDir = Entity.Direction.RIGHT;
			}
		}
		
		var amt:Float = TileUtils.horizontalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.x += amt;
		
		if (InputController.pressed(UP)) {
			p.y -= PLAYER_SPEED;
			triedToMove = true;
			p.facingDir = Entity.Direction.UP;
		} else if (InputController.pressed(DOWN)) {
			p.y += PLAYER_SPEED;
			triedToMove = true;
			p.facingDir = Entity.Direction.DOWN;
		}
		
		amt = TileUtils.verticalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.y += amt;

		if (triedToMove) {
			p.spriteRef.animation.play(p.getDirectionString());
		}
		
		if (InputController.justPressed(CONFIRM)) {
			if (speakTarget != -1) {
				dialogBox = Constants.instance.dbf.create(
				["choice_box:", "  \"Hey! Want to play something?\"", "  > \"DDR\" ddr", "  > \"Potato Counter\" count", "  > \"No\" end", "label ddr:", "emit \"play_rhythm\"", "jump end",
				"label count:", "emit \"play_counter\"", "jump end"],
				{
					emitCallback: this.emitCallback,
					callback: this.dialogCallback,
				});
				foregroundLayer.add(dialogBox);
				focus.push(dialogBox);
			}
		}
	}

	public function handleAnimations() {
		var checkTalk = new FlxPoint(p.hitbox.x + p.hitbox.width / 2 + p.getDirection().x * TILE_WIDTH,
		                             p.hitbox.y + p.hitbox.height / 2 + p.getDirection().y * TILE_HEIGHT);

		for (entity in entities) {
			var hasConfirm:Bool = Reflect.hasField(entity.scratch, 'hasConfirm') && entity.scratch.hasConfirm;
			
			if ((speakTarget == -1 || speakTarget == entity.id) && entity.hitbox.containsPoint(checkTalk)) {
				speakTarget = entity.id;
				if (!hasConfirm) {
					if (Reflect.hasField(entity.scratch, 'hasConfirm') && entity.scratch.hasConfirm) {
						foregroundLayer.remove(entity.scratch.confirm);
					}
					var lo:LocalSpriteWrapper = LocalWrapper.fromGraphic('assets/images/ui.png', {
						crop: [[0, 0], [24, 21]],
					});
					entity.scratch.confirm = lo;
					entity.scratch.hasConfirm = true;
					foregroundLayer.add(lo);
					lo.x = entity.x + entity.width / 2 - lo.width / 2;
					lo.y = entity.y - lo.height;
					Director.fadeIn(lo, 3);
				}
			} else if (hasConfirm) {
				speakTarget = -1;
				entity.scratch.hasConfirm = false;
				var lo:LocalSpriteWrapper = entity.scratch.confirm;
				foregroundLayer.remove(lo);
			}
		}
	}
	
	public function dialogCallback(returnString:String):Void {
		focus.remove(dialogBox);
		foregroundLayer.remove(dialogBox);
	}
	
	public function emitCallback(emitString:String):Void {
		trace(emitString);
		if (emitString == 'play_rhythm') {
			var rg:RhythmGame = new RhythmGame();
			foregroundLayer.add(rg);
			rg.xy = [FlxG.width / 2 - rg.width / 2, FlxG.height / 2 - rg.height / 2 - 20];
			focus.push(rg);
			Director.moveBy(rg, [0, 20], 20);
			Director.fadeIn(rg, 20);
			return;
		}
		else if (emitString == 'play_counter') {
			var cg:CounterGame = new CounterGame();
			foregroundLayer.add(cg);
			cg.xy = [FlxG.width / 2 - cg.width / 2, FlxG.height / 2 - cg.height / 2 - 20];
			focus.push(cg);
			Director.moveBy(cg, [0, 20], 20);
			Director.fadeIn(cg, 20);
			return;
		}
	}

	override public function update(elapsed:Float):Void {
		Director.update();
		InputController.update();
		
		if (focus.length == 0) {
			handleInput();
		} else {
			focus[focus.length - 1].handleInput();
		}
		
		handleAnimations();
		
		entityLayer.children.sort(function(a, b) {
			return Std.int(cast(a, Entity).hitbox.bottom - cast(b, Entity).hitbox.bottom);
		});
		super.update(elapsed);
	}
}