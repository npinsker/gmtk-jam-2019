package;

import nova.ui.dialog.DialogBox;
import nova.ui.dialog.DialogBoxAddons;
import nova.ui.dialog.DialogBoxFactory;
import nova.utils.BitmapDataUtils;

class Constants {
	public static var instance:Constants = new Constants();
	
	public static var OVERALL_QUEST:String = 'OVERALL_QUEST';
	public static var RHYTHM_KING_QUEST:String = 'RHYTHM_KING_QUEST';
	public static var ALL_QUESTS:Array<String> = [OVERALL_QUEST, RHYTHM_KING_QUEST];
	
	public static var PLAYER_NAME:String = 'Miku';

	public var dbf:DialogBoxFactory;
	
	public var idToInfo:Map<String, Map<Int, Dynamic>>;

	public function new() {
		idToInfo = [
			'test' => [
				75 => {
					tiles: [75, 76, 91, 92, 107, 108], columns: 2, type: 'rhythm_cabinet', hitbox: [0, 70, 56, 26]
				},
				77 => {
					tiles: [77, 78, 93, 94, 109, 110], columns: 2, type: 'fishing_cabinet', hitbox: [0, 70, 48, 26]
				},
				89 => {
					tiles: [89, 90, 105, 106], columns: 2, type: 'sorting_cabinet', hitbox: [0, 36, 38, 26]
				},
				
				// NPCs
				116 => {
					tiles: [116], columns: 1, type: 'talkable', name: 'ramenpuss', hitbox: [2, 13, 29, 13],
				},
				117 => {
					tiles: [117], columns: 1, type: 'talkable', name: 'deadmaus', hitbox: [4, 13, 15, 13],
				},
				118 => {
					tiles: [118], columns: 1, type: 'talkable', name: 'octopus', hitbox: [0, 8, 32, 13],
				},
				
				120 => {
					tiles: [120, 121, 136, 137], columns: 2, type: 'potato_cabinet', hitbox: [0, 36, 45, 26]
				},
				122 => {
					tiles: [122, 123, 138, 139], columns: 2, type: 'solid', hitbox: [13, 10, 38, 54]
				},
				124 => {
					tiles: [124, 125, 140, 141], columns: 2, type: 'solid', hitbox: [13, 10, 38, 54]
				},
				126 => {
					tiles: [126], columns: 1, type: 'solid', hitbox: [6, 13, 26, 19]
				},
				142 => {
					tiles: [142, 143, 158, 159], columns: 2, type: 'solid', hitbox: [17, 32, 47, 32]
				}
			]
		];
		dbf = new DialogBoxFactory({
			background: {
				image: 'assets/images/dialog_bubble.png',
			},
			advanceCallback: function() {
				SoundManager.addSound('advance', 0.75);
			},
			textFormat: {
				size: 24,
			},
			choiceTextFormat: {
				size: 24,
			},
			textOffset: [40, 50],
			advanceStyle: TYPEWRITER,
			selectOptionSprite: {
				image: 'assets/images/ui.png',
				transform: function(b) { return BitmapDataUtils.crop(b, [24, 0], [27, 18]); },
				offset: [0, 10],
			},
			textPreprocess: function(db:DialogBox, text:String) {
				var a:String = DialogBoxAddons.parsePercentVariables(db, text);
				return a;
			}
		});
	}
}