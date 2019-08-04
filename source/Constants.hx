package;

import flixel.util.FlxColor;
import nova.ui.dialog.DialogBox;
import nova.ui.dialog.DialogBoxAddons;
import nova.ui.dialog.DialogBoxFactory;
import nova.utils.BitmapDataUtils;

class Constants {
	public static var instance:Constants = new Constants();
	
	public static var OVERALL_QUEST_PROGRESS:String = 'OVERALL_QUEST_PROGRESS';
	public static var RHYTHM_KING_QUEST_PROGRESS:String = 'RHYTHM_KING_QUEST_PROGRESS';
	public static var COUNT_KING_QUEST_PROGRESS:String = 'COUNT_KING_QUEST_PROGRESS';
	public static var SORT_KING_QUEST_PROGRESS:String = 'SORT_KING_QUEST_PROGRESS';

	public static var INTRO_BARTENDER:String = "INTRO_BARTENDER";

	public static var ALL_QUESTS:Array<String> = [
		OVERALL_QUEST_PROGRESS,
		RHYTHM_KING_QUEST_PROGRESS,
		COUNT_KING_QUEST_PROGRESS,
		SORT_KING_QUEST_PROGRESS,

		INTRO_BARTENDER,
	];
	
	public static var PLAYER_NAME:String = 'Miku';

	public var dbf:DialogBoxFactory;
	
	public var idToInfo:Map<String, Map<Int, Dynamic>>;

	private var MARTIAN_HITBOX:Array<Int> = [6, 18, 8, 12];  // formerly [0, 20, 20, 10]

	public function new() {
		idToInfo = [
			'test' => [
				1 => {
					tiles: [1], columns: 1, type: 'solid', hitbox: [16, 16, 0, 0], zOffset: 100,
				},
				2 => {
					tiles: [2, 18], columns: 1, type: 'solid', hitbox: [16, 16, 0, 0], zOffset: 100,
				},
				3 => {
					tiles: [3], columns: 1, type: 'solid', hitbox: [16, 16, 0, 0], zOffset: 100,
				},
				32 => {
					tiles: [32, 33, 34, 35], columns: 1, frames: 4, type: 'talkable', name: 'lock', hitbox: [0, 14, 14, 10],
				},
				75 => {
					tiles: [75, 76, 91, 92, 107, 108], columns: 2, type: 'rhythm_cabinet', hitbox: [0, 70, 56, 26]
				},
				77 => {
					tiles: [77, 78, 93, 94, 109, 110], columns: 2, type: 'fishing_cabinet', hitbox: [0, 70, 48, 26]
				},
				89 => {
					tiles: [89, 90, 105, 106], columns: 2, type: 'sorting_cabinet', hitbox: [0, 36, 38, 26]
				},
				120 => {
					tiles: [120, 121, 136, 137], columns: 2, type: 'potato_cabinet', hitbox: [2, 36, 46, 26]
				},
				
				// NPCs
				100 => {
					tiles: [100, 101], columns: 1, frames: 2, type: 'talkable', name: 'ramenpus', hitbox: [2, 13, 29, 13],
				},
				117 => {
					tiles: [116, 117], columns: 1, frames: 2, type: 'talkable', name: 'deadmaus', hitbox: [4, 13, 15, 13], fps: 2,
				},
				118 => {
					tiles: [118, 119], columns: 1, frames: 2, type: 'talkable', name: 'octopus', hitbox: [0, 8, 32, 13], fps: 3,
				},
				133 => {
					tiles: [133, 134], columns: 1, frames: 2, type: 'talkable', name: 'bartender', hitbox: [5, 20, 20, 11], fps: 2, zOffset: 120,
				},
				144 => {
					tiles: [144, 145], columns: 1, frames: 2, type: 'solid', name: 'martian_fwd', hitbox: MARTIAN_HITBOX,
				},
				146 => {
					tiles: [146, 147], columns: 1, frames: 2, type: 'solid', name: 'martian_right', hitbox: MARTIAN_HITBOX, fps: 2,
				},
				148 => {
					tiles: [148, 149], columns: 1, frames: 2, type: 'solid', name: 'martian_right_reach', hitbox: MARTIAN_HITBOX, fps: 3,
				},

				160 => {
					tiles: [160, 161], columns: 1, frames: 2, type: 'solid', name: 'martian_green_fwd', hitbox: MARTIAN_HITBOX, fps: 2,
				},
				163 => {
					tiles: [163, 164], columns: 1, frames: 2, type: 'solid', name: 'martian_green_right_reach', hitbox: [8, 24, 8, 7],
				},
				165 => {
					tiles: [165, 166], columns: 1, frames: 2, type: 'solid', name: 'tv_blue', hitbox: MARTIAN_HITBOX, 
				},
				167 => {
					tiles: [167, 168], columns: 1, frames: 2, type: 'solid', name: 'tv_pink', hitbox: [0, 20, 8, 12], fps: 3,
				},
				178 => {
					tiles: [178, 179], columns: 1, frames: 2, type: 'solid', name: 'dog_red', hitbox: [0, 24, 12, 8],
				},
				180 => {
					tiles: [180, 181], columns: 1, frames: 2, type: 'talkable', name: 'dog_blue', hitbox: [0, 24, 12, 8],
				},
				198 => {
					tiles: [198, 199], columns: 1, frames: 2, type: 'solid', name: 'bear_left', hitbox: MARTIAN_HITBOX,
				},
				195 => {
					tiles: [196, 197, 196, 197, 196, 197, 198, 199, 198, 199, 198, 199], columns: 1, frames: 12, fps: 3, type: 'talkable', name: 'bear_turn', hitbox: [1, 24, 11, 8],
				},

				// Hitbox might be wrong
				182 => {
					tiles: [182, 183], columns: 1, frames: 2, type: 'talkable', name: 'lil_skunk', hitbox: [0, 22, 15, 10],
				},
				// Renamed from lil_skunk
				150 => {
					tiles: [150, 151], columns: 1, frames: 2, type: 'talkable', name: 'skunklass', hitbox: [5, 20, 20, 11], zOffset: 20,
				},
				152 => {
					tiles: [152, 152], columns: 1, frames: 3, type: 'talkable', name: 'frog', hitbox: [5, 23, 20, 8],
				},
				200 => {
					tiles: [200, 201], columns: 1, frames: 2, type: 'talkable', name: 'slug_shack', hitbox: [5, 20, 7, 11],
				},
				
				// Blue right-wall cabinets
				122 => {
					tiles: [122, 138], columns: 1, type: 'solid', hitbox: [13, 10, 19, 54]
				},
				// Blue left-wall cabinets
				123 => {
					tiles: [123, 139], columns: 1, type: 'solid', hitbox: [0, 10, 19, 54]
				},
				// Rainbow cabinets
				124 => {
					tiles: [124, 125, 140, 141], columns: 2, type: 'solid', hitbox: [13, 12, 38, 52]
				},

				// Not used
				// 126 => {
				// 	tiles: [126], columns: 1, type: 'solid', hitbox: [6, 13, 26, 19]
				// },
				// 142 => {
				// 	tiles: [142, 143, 158, 159], columns: 2, type: 'solid', hitbox: [17, 32, 47, 32]
				// },
				
				// Bar
				154 => {
					tiles: [154, 155, 41, 171], columns: 2, type: 'solid', hitbox: [2, 22, 62, 20]
				},
				170 => {
					tiles: [170], columns: 1, type: 'solid', hitbox: [1, 0, 28, 32],
				},
				186 => {
					tiles: [186, 187], columns: 2, type: 'solid', hitbox: [1, 0, 63, 31],
				},

				// Chairs
				// Hitbox might be wrong
				172 => {
					tiles: [172, 188], columns: 1, type: 'solid', hitbox: [3, 32, 27, 11],
				},
				// Big orange machine
				174 => {
					tiles: [174, 190], columns: 1, type: 'solid', hitbox: [0, 30, 25, 34],
				},
			]
		];
		dbf = new DialogBoxFactory({
			background: {
				image: 'assets/images/dialog_box1.png',
			},
			advanceCallback: function() {
				SoundManager.addSound('advance', 0.4);
			},
			advanceLength: 11,
			textFormat: {
				size: 30,
				font: 'assets/data/m3x6.ttf',
				color: FlxColor.WHITE,
			},
			choiceTextFormat: {
				size: 30,
				font: 'assets/data/m3x6.ttf',
				color: FlxColor.WHITE,
			},
			textOffset: [9, 10],
			optionsOffset: [0, -9],
			textPadding: [46, 0],
			advanceStyle: TYPEWRITER,
			skip: false,
			selectOptionSprite: {
				image: 'assets/images/ui.png',
				transform: function(b) { return BitmapDataUtils.crop(b, [24, 0], [27, 25]); },
			},
			textPreprocess: function(db:DialogBox, text:String) {
				var a:String = DialogBoxAddons.parsePercentVariables(db, text);
				return a;
			},
			textAppearCallback: function(frame) {
				if (frame % 4 == 0) {
					SoundManager.addSound('dialog_type', 1.0, 0.6, 6);
				}
			}
		});
	}
}