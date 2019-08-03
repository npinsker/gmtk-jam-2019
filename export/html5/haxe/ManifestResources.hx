package;


import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

		}

		if (rootPath == null) {

			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif console
			rootPath = lime.system.System.applicationDirectory;
			#elseif (sys && windows && !cs)
			rootPath = FileSystem.absolutePath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) Sys.programPath () #else Sys.executablePath () #end)) + "/";
			#else
			rootPath = "";
			#end

		}

		Assets.defaultRootPath = rootPath;

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf);
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_monsterrat_ttf);
		
		#end

		var data, manifest, library;

		#if kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":null,"assets":"aoy4:pathy26:assets%2Fdata%2Fdialog.txty4:sizei150y4:typey4:TEXTy2:idR1y7:preloadtgoR0y40:assets%2Fimages%2Farcade_tiles_16x16.pdnR2i5664R3R4R5R7R6tgoR0y40:assets%2Fimages%2Farcade_tiles_16x16.pngR2i1214R3y5:IMAGER5R8R6tgoR0y35:assets%2Fimages%2Fdialog_bubble.pngR2i9206R3R9R5R10R6tgoR0y43:assets%2Fimages%2Foverworld_tiles_32x32.pdnR2i11113R3R4R5R11R6tgoR0y46:assets%2Fimages%2Frhythm_splash%20-%20Copy.pngR2i808R3R9R5R12R6tgoR0y35:assets%2Fimages%2Frhythm_splash.pngR2i808R3R9R5R13R6tgoR0y24:assets%2Fimages%2Fui.pdnR2i4423R3R4R5R14R6tgoR0y24:assets%2Fimages%2Fui.pngR2i604R3R9R5R15R6tgoR2i2313541R3y5:MUSICR5y27:assets%2Fmusic%2Fisland.mp3y9:pathGroupaR17y27:assets%2Fmusic%2Fisland.ogghR6tgoR2i1439569R3R16R5R19R18aR17R19hgoR2i35074R3R16R5y29:assets%2Fsounds%2Fadvance.mp3R18aR20y29:assets%2Fsounds%2Fadvance.ogghR6tgoR2i8923R3y5:SOUNDR5R21R18aR20R21hgoR2i60674R3R16R5y29:assets%2Fsounds%2Fvictory.mp3R18aR23y29:assets%2Fsounds%2Fvictory.ogghR6tgoR2i33195R3R22R5R24R18aR23R24hgoR2i2114R3R16R5y26:flixel%2Fsounds%2Fbeep.mp3R18aR25y26:flixel%2Fsounds%2Fbeep.ogghR6tgoR2i39706R3R16R5y28:flixel%2Fsounds%2Fflixel.mp3R18aR27y28:flixel%2Fsounds%2Fflixel.ogghR6tgoR2i5794R3R22R5R26R18aR25R26hgoR2i33629R3R22R5R28R18aR27R28hgoR2i15744R3y4:FONTy9:classNamey35:__ASSET__flixel_fonts_nokiafc22_ttfR5y30:flixel%2Ffonts%2Fnokiafc22.ttfR6tgoR2i29724R3R29R30y36:__ASSET__flixel_fonts_monsterrat_ttfR5y31:flixel%2Ffonts%2Fmonsterrat.ttfR6tgoR0y33:flixel%2Fimages%2Fui%2Fbutton.pngR2i519R3R9R5R35R6tgoR0y36:flixel%2Fimages%2Flogo%2Fdefault.pngR2i3280R3R9R5R36R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

		#end

	}


}


#if kha

null

#else

#if !display
#if flash

@:keep @:bind #if display private #end class __ASSET__assets_data_dialog_txt extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_images_arcade_tiles_16x16_pdn extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_images_arcade_tiles_16x16_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_images_dialog_bubble_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_images_overworld_tiles_32x32_pdn extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_images_rhythm_splash___copy_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_images_rhythm_splash_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_images_ui_pdn extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_images_ui_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__assets_music_island_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_music_island_ogg extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_sounds_advance_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_sounds_advance_ogg extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_sounds_victory_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__assets_sounds_victory_ogg extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_sounds_beep_ogg extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends null { }
@:keep @:bind #if display private #end class __ASSET__flixel_images_ui_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__flixel_images_logo_default_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("assets/data/dialog.txt") #if display private #end class __ASSET__assets_data_dialog_txt extends haxe.io.Bytes {}
@:keep @:file("assets/images/arcade_tiles_16x16.pdn") #if display private #end class __ASSET__assets_images_arcade_tiles_16x16_pdn extends haxe.io.Bytes {}
@:keep @:image("assets/images/arcade_tiles_16x16.png") #if display private #end class __ASSET__assets_images_arcade_tiles_16x16_png extends lime.graphics.Image {}
@:keep @:image("assets/images/dialog_bubble.png") #if display private #end class __ASSET__assets_images_dialog_bubble_png extends lime.graphics.Image {}
@:keep @:file("assets/images/overworld_tiles_32x32.pdn") #if display private #end class __ASSET__assets_images_overworld_tiles_32x32_pdn extends haxe.io.Bytes {}
@:keep @:image("assets/images/rhythm_splash - Copy.png") #if display private #end class __ASSET__assets_images_rhythm_splash___copy_png extends lime.graphics.Image {}
@:keep @:image("assets/images/rhythm_splash.png") #if display private #end class __ASSET__assets_images_rhythm_splash_png extends lime.graphics.Image {}
@:keep @:file("assets/images/ui.pdn") #if display private #end class __ASSET__assets_images_ui_pdn extends haxe.io.Bytes {}
@:keep @:image("assets/images/ui.png") #if display private #end class __ASSET__assets_images_ui_png extends lime.graphics.Image {}
@:keep @:file("assets/music/island.mp3") #if display private #end class __ASSET__assets_music_island_mp3 extends haxe.io.Bytes {}
@:keep @:file("assets/music/island.ogg") #if display private #end class __ASSET__assets_music_island_ogg extends haxe.io.Bytes {}
@:keep @:file("assets/sounds/advance.mp3") #if display private #end class __ASSET__assets_sounds_advance_mp3 extends haxe.io.Bytes {}
@:keep @:file("assets/sounds/advance.ogg") #if display private #end class __ASSET__assets_sounds_advance_ogg extends haxe.io.Bytes {}
@:keep @:file("assets/sounds/victory.mp3") #if display private #end class __ASSET__assets_sounds_victory_mp3 extends haxe.io.Bytes {}
@:keep @:file("assets/sounds/victory.ogg") #if display private #end class __ASSET__assets_sounds_victory_ogg extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/4,6,1/assets/sounds/beep.mp3") #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/4,6,1/assets/sounds/flixel.mp3") #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/4,6,1/assets/sounds/beep.ogg") #if display private #end class __ASSET__flixel_sounds_beep_ogg extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/4,6,1/assets/sounds/flixel.ogg") #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends haxe.io.Bytes {}
@:keep @:font("export/html5/obj/webfont/nokiafc22.ttf") #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font {}
@:keep @:font("export/html5/obj/webfont/monsterrat.ttf") #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font {}
@:keep @:image("/usr/local/lib/haxe/lib/flixel/4,6,2/assets/images/ui/button.png") #if display private #end class __ASSET__flixel_images_ui_button_png extends lime.graphics.Image {}
@:keep @:image("/usr/local/lib/haxe/lib/flixel/4,6,2/assets/images/logo/default.png") #if display private #end class __ASSET__flixel_images_logo_default_png extends lime.graphics.Image {}
@:keep @:file("") #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__flixel_fonts_nokiafc22_ttf') #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/nokiafc22"; #else ascender = 2048; descender = -512; height = 2816; numGlyphs = 172; underlinePosition = -640; underlineThickness = 256; unitsPerEM = 2048; #end name = "Nokia Cellphone FC Small"; super (); }}
@:keep @:expose('__ASSET__flixel_fonts_monsterrat_ttf') #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/monsterrat"; #else ascender = 968; descender = -251; height = 1219; numGlyphs = 263; underlinePosition = -150; underlineThickness = 50; unitsPerEM = 1000; #end name = "Monsterrat"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#end

#end
#end

#end
