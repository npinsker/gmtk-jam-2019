package;

import nova.ui.dialog.DialogBox;
import nova.ui.dialog.DialogBoxAddons;
import nova.ui.dialog.DialogBoxFactory;

class Constants {
	public static var instance:Constants = new Constants();

	public var dbf:DialogBoxFactory;

	public function new() {
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
			textPreprocess: function(db:DialogBox, text:String) {
				var a:String = DialogBoxAddons.parsePercentVariables(db, text);
				return a;
			}
		});
	}
}