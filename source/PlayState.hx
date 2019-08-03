package;

using nova.utils.ArrayUtils;

import flixel.FlxG;
import flixel.FlxState;
import nova.animation.Director;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.tile.TileUtils;

class PlayState extends FlxState {
	var p:Entity;
	
	var entities:Array<Entity>;
	var entityLayer:FlxLocalSprite;
	
	var focus:Array<Focusable>;
	
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
		
		var rg:RhythmGame = new RhythmGame();
		add(rg);
		rg.xy = [FlxG.width / 2 - rg.width / 2, FlxG.height / 2 - rg.height / 2];
		focus.push(rg);
	}
	
	public function handleInput() {
		if (InputController.pressed(LEFT)) {
			p.x -= 4;
		} else if (InputController.pressed(RIGHT)) {
			p.x += 4;
		}
		
		if (InputController.pressed(UP)) {
			p.y -= 4;
		} else if (InputController.pressed(DOWN)) {
			p.y += 4;
		}
		
		var amt:Float = TileUtils.horizontalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.x += amt;
		
		amt = TileUtils.verticalNudgeOutOfObjects(entities.map(function(k) { return k.hitbox; }), p.hitbox);
		p.y += amt;
	}

	override public function update(elapsed:Float):Void {
		Director.update();
		
		if (focus.length == 0) {
			handleInput();
		} else {
			focus[focus.length - 1].handleInput();
		}
		
		entityLayer.children.sort(function(a, b) {
			return Std.int(cast(a, Entity).hitbox.bottom - cast(b, Entity).hitbox.bottom);
		});
		super.update(elapsed);
	}
}