package;

using nova.utils.ArrayUtils;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import nova.animation.AnimationSet;
import nova.input.Focusable;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import nova.render.NovaEmitter;
import nova.render.TiledBitmapData;
import nova.tile.TileUtils;
import nova.tiled.TiledObjectLoader;
import nova.tiled.TiledRenderer;
import nova.ui.dialog.DialogBox;
import nova.utils.Pair;
import openfl.Assets;
import openfl.display.BitmapData;

using StringTools;
using nova.animation.Director;

class PlayState extends FlxState {
	var TILE_WIDTH:Int = 32;
	var TILE_HEIGHT:Int = 32;
	var PLAYER_SPEED:Float = 1.6;
	
	var p:Entity;
	
	var entities:Array<Entity>;
	
	var backgroundLayer:FlxLocalSprite;
	// Must only add Entity to this layer!!
	var entityLayer:FlxLocalSprite;
	var foregroundLayer:FlxLocalSprite;
	var tileAccessor:TiledBitmapData;
	
	var focus:Array<Focusable>;
	var dialogBox:DialogBox;
	var dialogMap:Map<String, Array<String>>;
	var speakTarget:Int = -1;
	var triggers:Map<String, Int>;
	var locked:Bool = false;
	
	override public function create():Void {
		super.create();
		
		backgroundLayer = new FlxLocalSprite();
		add(backgroundLayer);
		
		entityLayer = new FlxLocalSprite();
		add(entityLayer);
		
		triggers = new Map<String, Int>();
		for (quest in Constants.ALL_QUESTS) {
			triggers.set(quest, 0);
		}
		
		foregroundLayer = new FlxLocalSprite();
		add(foregroundLayer);
		
		dialogMap = parseDialogFile('assets/data/dialog.txt');
		
		entities = [];
		focus = [];
		
		readdDialogBox('welcome');
	}
	
	public function drawRoom() {
		var map:TiledMap = new TiledMap('assets/data/gmtk_arcade.tmx');
		var tr:TiledRenderer = new TiledRenderer(map);
		var to:TiledObjectLoader = new TiledObjectLoader(Constants.instance.idToInfo, ['test' => 0], [32, 32]);
		
		tileAccessor = new TiledBitmapData('assets/images/test.png', 32, 32);
		var playerBitmap:BitmapData = tileAccessor.stitchTiles([96, 97, 98, 99, 112, 113, 114, 115, 128, 129, 130, 131]);
		var as:AnimationSet = new AnimationSet([32, 32], [
			new AnimationFrames('stand', [0, 1], 3),
			new AnimationFrames('d', [2, 3], 4),
			new AnimationFrames('l', [4, 5], 4),
			new AnimationFrames('r', [6, 7], 4),
			new AnimationFrames('u', [10, 11], 4),
		]);
		p = new Entity('player', playerBitmap, as);
		p._internal_hitbox = new FlxRect(1, 24, 16, 7);
		entityLayer.add(p);
		p.xy = [12 * 32, 10 * 32];
		p.spriteRef.animation.play('u');
		
		var tiles = tr.renderStaticScreen([0, 0, map.width, map.height], to);
		backgroundLayer.add(LocalSpriteWrapper.fromGraphic(tiles));
		
		addEntitiesFromTiled(map, to);
		
		SoundManager.playMusic(Constants.OVERWORLD_MUSIC);
		Director.fadeIn(backgroundLayer, 45);
		Director.fadeIn(entityLayer, 45);
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
		
		// restrict player to a rectangle
		if (p.hitbox.left < 32 * 2) p.x += (32*2 - p.hitbox.left);
		if (p.hitbox.right > FlxG.width - 32 * 2) p.x -= (p.hitbox.right - (FlxG.width - 32 * 2));
		if (p.hitbox.top < 32 * 4) p.y += (32*4 - p.hitbox.top);
		if (p.hitbox.bottom > FlxG.height - 32 * 1) p.y -= (p.hitbox.bottom - (FlxG.height - 32 * 1));
		
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
				var entity = entities.filter(function(x) { return x.id == speakTarget; })[0];
				var dialog:Array<String> = null;
				if (entity.type == 'rhythm_cabinet' || entity.type == 'potato_cabinet' || entity.type == 'sorting_cabinet' || entity.type == 'fishing_cabinet') {
					dialog = dialogMap.get(entity.type);
				} else if (dialogMap.exists(entity.name)) {
					dialog = dialogMap.get(entity.name);
				}
				if (dialog != null) {
					dialogBox = Constants.instance.dbf.create(dialog,
					{
						emitCallback: this.emitCallback,
						callback: this.dialogCallback,
						globalVariables: triggers,
					});
					foregroundLayer.add(dialogBox);
					focus.push(dialogBox);
					SoundManager.addSound('advance', 0.4);
					
					dialogBox.y = FlxG.height - dialogBox.height;
				}
			}
		}
	}
	
	public function getTalkableTarget():Entity {
		var bestDistance:Float = 10000;
		var best:Entity = null;
		for (entity in entities) {
			if (entity.type == 'solid') continue;

			var hitbox = nova.utils.GeomUtils.expand(entity.hitbox, 6);
			var hitEntity:Bool = false;
			var distance:Float = 10000;
			var str = p.getDirectionString();
			if (str == 'r') {
				if (p.hitbox.right < hitbox.right && p.hitbox.top < hitbox.bottom && hitbox.top < p.hitbox.bottom) {
					hitEntity = true;
					distance = Math.max(0, hitbox.left - p.hitbox.right);
				}
			} else if (str == 'l') {
				if (p.hitbox.left > hitbox.left && p.hitbox.top < hitbox.bottom && hitbox.top < p.hitbox.bottom) {
					hitEntity = true;
					distance = Math.max(0, p.hitbox.left - hitbox.right);
				}
			} else if (str == 'd') {
				if (p.hitbox.bottom < hitbox.bottom && p.hitbox.left < hitbox.right && hitbox.left < p.hitbox.right) {
					hitEntity = true;
					distance = Math.max(0, hitbox.top - p.hitbox.bottom);
				}
			} else if (str == 'u') {
				if (p.hitbox.top > hitbox.top && p.hitbox.left < hitbox.right && hitbox.left < p.hitbox.right) {
					hitEntity = true;
					distance = Math.max(0, p.hitbox.top - hitbox.bottom);
				}
			}
			var threshold = 20;
			if (entity.type == 'talkable' && (entity.name == 'bartender' || entity.name == 'lock')) threshold = 44;
			if (distance > threshold) continue;

			if (hitEntity && distance < bestDistance) {
				bestDistance = distance;
				best = entity;
			}
		}
		return best;
	}

	public function handleAnimations() {
		var targetEntity = getTalkableTarget();
		
		if (targetEntity == null) speakTarget = -1;
		for (entity in entities) {
			var hasConfirm:Bool = entity.hasConfirm;
			if (targetEntity != null && targetEntity.id == entity.id) {
				speakTarget = entity.id;
				if (!entity.hasConfirm) {
					var lo:LocalSpriteWrapper = LocalWrapper.fromGraphic('assets/images/ui.png', {
						crop: [[0, 0], [24, 21]],
					});
					entity.confirm = lo;
					entity.hasConfirm = true;
					foregroundLayer.add(lo);
					lo.x = entity.hitbox.x + entity.hitbox.width / 2 - lo.width / 2;
					lo.y = entity.y - lo.height + 4 + (entity.height > 64 ? 16 : 0);
					Director.fadeIn(lo, 3);
				}
			} else if (hasConfirm) {
				entity.hasConfirm = false;
				var lo:LocalSpriteWrapper = entity.confirm;
				foregroundLayer.remove(lo);
			}
		}
	}
	
	public function dialogCallback(returnString:String):Void {
		focus.remove(dialogBox);
		foregroundLayer.remove(dialogBox);
		dialogBox = null;
	}
	
	public function emitCallback(emitString:String):Void {
		if (emitString.startsWith('play_rhythm')) {
			var rg:RhythmGame = new RhythmGame(closeCallback, (emitString.indexOf('special') != -1));
			foregroundLayer.add(rg);
			rg.xy = [FlxG.width / 2 - rg.width / 2, FlxG.height / 2 - rg.height / 2 - 20];
			focus.push(rg);
			Director.moveBy(rg, [0, 20], 20);
			Director.fadeIn(rg, 20);
			return;
		}
		else if (emitString.startsWith('play_counter')) {
			var cg:CounterGame = new CounterGame(closeCallback, (emitString.indexOf('special') != -1));
			foregroundLayer.add(cg);
			cg.xy = [FlxG.width / 2 - cg.width / 2, FlxG.height / 2 - cg.height / 2 - 20];
			focus.push(cg);
			Director.moveBy(cg, [0, 20], 20);
			Director.fadeIn(cg, 20);
			return;
		}
		else if (emitString.startsWith('play_sorting')) {
			var sg:SortingGame = new SortingGame(closeCallback, (emitString.indexOf('special') != -1));
			foregroundLayer.add(sg);
			sg.xy = [FlxG.width / 2 - sg.width / 2, FlxG.height / 2 - sg.height / 2 - 20];
			focus.push(sg);
			Director.moveBy(sg, [0, 20], 20);
			Director.fadeIn(sg, 20);
			return;
		}
		
		if (emitString.startsWith('set')) {
			var tokens = emitString.split(' ');
			triggers.set(tokens[1], Std.parseInt(tokens[2]));
			if (dialogBox != null) {
				dialogBox.globalVariables.set(tokens[1], Std.parseInt(tokens[2]));
			}
		}
		
		if (emitString.startsWith('add')) {
			var tokens = emitString.split(' ');
			var value:Int = cast triggers.get(tokens[1]);
			value += Std.parseInt(tokens[2]);
			triggers.set(tokens[1], value);
			if (dialogBox != null) {
				dialogBox.globalVariables.set(tokens[1], value);
			}
			
			if (tokens[1] == Constants.OVERALL_QUEST_PROGRESS) {
				SoundManager.addSound('victory', 1.0, 0.0, 60);
			}
			
			for (entity in entities) {
				if (entity.type == 'talkable' && entity.name == 'lock') {
					var lsw:Entity = cast entity;
					lsw.spriteRef.animation.play(Std.string(triggers.get(Constants.OVERALL_QUEST_PROGRESS)));
				}
			}
		}
		
		if (emitString == 'end_game') {
			locked = true;
			FlxG.sound.music.pause();
			
			var octopus:Entity = null;
			for (entity in entities) {
				var ex:Entity = cast entity;
				if (ex.type == 'talkable' && ex.name == 'octopus') {
					octopus = ex;
				}
			}
			
			var px:NovaEmitter = new NovaEmitter(octopus.x, octopus.y);
			px.addSimpleParticles(0xFFD9D9FF, 3, 40);
			px.addSimpleParticles(0xFFCCEEFF, 3, 40);
			foregroundLayer.add(px);
			px.lifespan = [0.35, 0.9];
			px.endAlpha = [0, 0];
			px.limit = 120;
			px.launchAngle = [-Math.PI / 2, -Math.PI / 2];
			px.onCreate = function(p) { p.x = Math.random() * 32; p.y = Math.random() * 16; };
			px.speed = [40, 60];
			px.rate = 0.04;
			
			Director.wait(180).call(function() {
				octopus.spriteRef.animation.play('game_genie');
			});
			Director.wait(240).call(function() {
				p.spriteRef.animation.play('l');
				this.readdDialogBox('game_genie');
				FlxG.sound.music.resume();
			});
		}
		
		if (emitString == 'hacky_set_select_size') {
			if (dialogBox != null) {
				dialogBox.options.choiceTextFormat.size = 22;
			}
		}
		
		if (emitString == 'hacky_set_select_size_back') {
			if (dialogBox != null) {
				dialogBox.options.choiceTextFormat.size = 30;
			}
		}
		
		if (emitString == 'hide') {
			if (dialogBox != null) {
				dialogBox.setLocked(true);
				dialogBox.visible = false;
			}
		}
		
		if (emitString == 'show') {
			if (dialogBox != null) {
				dialogBox.setLocked(false);
				dialogBox.visible = true;
			}
		}
		
		if (emitString == 'unlock') {
			locked = false;
		}
		
		if (emitString == 'start') {
			drawRoom();
		}
	}
	
	public function readdDialogBox(dialog_name:String) {
		var dialog:Array<String> = dialogMap.get(dialog_name);
		dialogBox = Constants.instance.dbf.create(dialog,
		{
			globalVariables: triggers,
			emitCallback: this.emitCallback,
			callback: this.dialogCallback,
		});
		dialogBox.skip = false;
		foregroundLayer.add(dialogBox);
		focus.push(dialogBox);
		SoundManager.addSound('advance', 0.4);
		dialogBox.y = FlxG.height - dialogBox.height;
	}

	public function closeCallback(game:ArcadeCabinet, score:Int) {
		if (game.name == 'counter' &&
		    !game.special &&
		    score > 57 &&
			triggers.get(Constants.COUNT_KING_QUEST_PROGRESS) < 1) {
			triggers.set(Constants.COUNT_KING_QUEST_PROGRESS, 1);
		}
		if (game.name == 'counter' &&
		    game.special &&
			triggers.get(Constants.COUNT_KING_QUEST_PROGRESS) < 2) {
			if (score >= 990) {
				triggers.set(Constants.COUNT_KING_QUEST_PROGRESS, 2);
				this.readdDialogBox('skunklass');
			} else {
				this.readdDialogBox('skunklass_fail');
			}
		}

		if (game.name == 'rhythm' &&
		    !game.special &&
		    score > 772000 &&
			triggers.get(Constants.RHYTHM_KING_QUEST_PROGRESS) < 1) {
			triggers.set(Constants.RHYTHM_KING_QUEST_PROGRESS, 1);
		}
		if (game.name == 'rhythm' &&
		    game.special &&
			triggers.get(Constants.RHYTHM_KING_QUEST_PROGRESS) < 2) {
			if (score >= 650000) {
				triggers.set(Constants.RHYTHM_KING_QUEST_PROGRESS, 2);
				this.readdDialogBox('slug_shack');
			} else {
				this.readdDialogBox('slug_shack_fail');
			}
		}

		if (game.name == 'sorting' &&
		    !game.special &&
		    score > 59 &&
			triggers.get(Constants.SORT_KING_QUEST_PROGRESS) < 1) {
			triggers.set(Constants.SORT_KING_QUEST_PROGRESS, 1);
		}
		if (game.name == 'sorting' &&
		    game.special &&
			triggers.get(Constants.SORT_KING_QUEST_PROGRESS) < 2) {
			if (score >= 60) {
				triggers.set(Constants.SORT_KING_QUEST_PROGRESS, 2);
				this.readdDialogBox('ramenpus');
			} else {
				this.readdDialogBox('ramenpus_fail');
			}
		}

		foregroundLayer.remove(game);
		focus.remove(game);
	}
	
	public function addEntitiesFromTiled(map:TiledMap, objectLoader:TiledObjectLoader) {
		var objects = objectLoader.loadObjects(map, [0, 0, map.width, map.height]);
		for (object in objects.entities) {
			var bitmap = tileAccessor.stitchTiles(object.tiles, object.columns);
			var type = Reflect.hasField(object, 'type') ? object.type : '';
			
			var an:AnimationSet = null;
			if (Reflect.hasField(object, 'frames')) {
				if (object.name == 'lock') {
					an = new AnimationSet([32, 32], [
						new AnimationFrames('0', [0], 1, false),
						new AnimationFrames('1', [1], 1, false),
						new AnimationFrames('2', [2], 1, false),
						new AnimationFrames('3', [3], 1, false),
					]);
				} else if (object.name == 'octopus') {
					an = new AnimationSet([32, 32], [
						new AnimationFrames('stand', [0, 1], (Reflect.hasField(object, 'fps') ? object.fps : 1), true),
						new AnimationFrames('game_genie', [2, 3], (Reflect.hasField(object, 'fps') ? object.fps : 1), true)
					]);
				} else {
					an = new AnimationSet([32, 32], [
						new AnimationFrames('stand', [for (i in 0...object.frames) i], (Reflect.hasField(object, 'fps') ? object.fps : 1), true)
					]);
				}
			}
			var e:Entity = new Entity(type, bitmap, an);
			e.xy = [object.x, object.y];
			
			if (Reflect.hasField(object, 'name')) {
				e.name = object.name;
			}
			
			if (Reflect.hasField(object, 'zOffset')) {
				e.zOffset = object.zOffset;
			}
			
			if (Reflect.hasField(object, 'hitbox')) {
				e._internal_hitbox = new FlxRect(object.hitbox[0], object.hitbox[1], object.hitbox[2], object.hitbox[3]);
			} else {
				e._internal_hitbox = new FlxRect(0, 0, e.width, e.height);
			}
			
			entities.push(e);
			entityLayer.add(e);
		}
	}

	override public function update(elapsed:Float):Void {
		Director.update();
		InputController.update();
		
		if (focus.length == 0) {
			if (!locked) handleInput();
		} else {
			focus[focus.length - 1].handleInput();
		}
		
		handleAnimations();
		
		entityLayer.children.sort(function(a, b) {
			return Std.int(cast(a, Entity).hitbox.bottom + cast(a, Entity).zOffset - cast(b, Entity).hitbox.bottom - cast(b, Entity).zOffset);
		});
		super.update(elapsed);
	}
	
	public static function parseDialogFile(path:String):Map<String, Array<String>> {
		var r:Map<String, Array<String>> = new Map<String, Array<String>>();
		if (!Assets.exists(path)) {
		  return r;
		}

		var content:String = Assets.getText(path);
		if (content == null) {
		  return r;
		}
		var lines:Array<String> = content.split('\n').filter(function(s:String) { return s.trim() != ''; }).map(function(s) { return s.replace('\r', ''); });
		
		var anchor = 0;
		var name:String = "";
		
		for (i in 0...lines.length) {
			if (lines[i].indexOf("###") == 0) {
				if (i == anchor) {
					anchor = i + 1;
					continue;
				}
				r.set(name, lines.slice(anchor, i));
				name = "";
			} else if (lines[i].indexOf("DIALOG") == 0) {
				var tok = lines[i].split(' ');
				name = tok[1];
				anchor = i + 1;
			}
		}
		if (anchor < lines.length) {
			if (name == "") {
				trace("Error: no DIALOG tag for dialog box within file " + path + "!");
			} else {
				r.set(name, lines.slice(anchor));
			}
		}
		
		return r;
	}
}