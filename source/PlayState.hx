package;

using nova.utils.ArrayUtils;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import nova.animation.Director;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.tile.TileUtils;

class PlayState extends FlxState {
	var TILE_WIDTH:Int = 32;
	var TILE_HEIGHT:Int = 32;
	
	var p:Entity;
	
	var entities:Array<Entity>;
	
	var entityLayer:FlxLocalSprite;
	var foregroundLayer:FlxLocalSprite;
	
	var focus:Array<Focusable>;
	var speakTarget:Int = -1;
	
	override public function create():Void {
		super.create();
		
		entityLayer = new FlxLocalSprite();
		add(entityLayer);

		p = new Entity();
		p.makeGraphic(32, 32, flixel.util.FlxColor.RED);
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
		if (InputController.pressed(LEFT)) {
			p.x -= 4;
			p.facingDir = Entity.Direction.LEFT;
		} else if (InputController.pressed(RIGHT)) {
			p.x += 4;
			p.facingDir = Entity.Direction.RIGHT;
		}
		
		var amt:Float = TileUtils.horizontalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.x += amt;
		
		if (InputController.pressed(UP)) {
			p.y -= 4;
			p.facingDir = Entity.Direction.UP;
		} else if (InputController.pressed(DOWN)) {
			p.y += 4;
			p.facingDir = Entity.Direction.DOWN;
		}
		
		amt = TileUtils.verticalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.y += amt;
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
						scale: [2, 2]
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

	override public function update(elapsed:Float):Void {
		Director.update();
		
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