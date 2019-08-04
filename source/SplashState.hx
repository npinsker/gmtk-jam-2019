package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import nova.input.InputController;
import nova.render.FlxLocalSprite;
import openfl.Assets;
import openfl.display.BitmapData;

class SplashState extends FlxTransitionableState {
	public var foreground:BitmapData;
	public var canAdvance:Bool = false;

	public function new(foreground:BitmapData) {
		super();
		this.foreground = foreground;
	}

	override public function create():Void {
		super.create();

		var bgBitmapData:BitmapData = Assets.getBitmapData('assets/images/splash try 3.png');
		var backgroundLayer:LocalSpriteWrapper = LocalWrapper.fromGraphic(bgBitmapData, {
			scale: [3, 3],
			animation: [0, 1],
			frameRate: 1
		});
		add(backgroundLayer);

		var diamond:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData("assets/images/diamond.png"));
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData();
		FlxTransitionableState.defaultTransOut = new TransitionData();
		FlxTransitionableState.defaultTransIn.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransOut.color = FlxColor.BLACK;
		FlxTransitionableState.defaultTransIn.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransOut.type = flixel.addons.transition.TransitionType.TILES;
		FlxTransitionableState.defaultTransIn.tileData = {asset: diamond, width: 32, height: 32};
		FlxTransitionableState.defaultTransOut.tileData = {asset: diamond, width: 32, height: 32};
		transOut = FlxTransitionableState.defaultTransOut;
	}
		
	override public function update(elapsed:Float):Void {
		InputController.update();
		if (InputController.justPressed(CONFIRM)) {
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}