package;

class PlayerData {
	public static var instance:PlayerData = new PlayerData();
	
	public static var OVERALL_QUEST:String = 'OVERALL_QUEST';
	public static var RHYTHM_KING_QUEST:String = 'RHYTHM_KING_QUEST';
	public static var ALL_QUESTS:Array<String> = [OVERALL_QUEST, RHYTHM_KING_QUEST];
	
	public static var PLAYER_NAME:String = 'Miku';
	
	public var highScores:Map<String, ArcadeCabinet.HighScoreTable>;
	

	public function new() {
		highScores = [
			'rhythm' => new ArcadeCabinet.HighScoreTable(
				["Kot", "Pup", "Swang", "Jurgz", "Froggo"],
				[999000, 910000, 855160, 123230, 55000]
			),
			'ducky' => new ArcadeCabinet.HighScoreTable(
				["Kot", "m4u5", "Swang", "Kanga", "Octo"],
				[225, 129, 49, 22, 17]
			),
			'sorting' => new ArcadeCabinet.HighScoreTable(
				["Kot", "AAA", "Octo", "Borby", "Kot"],
				[83, 64, 49, 22, 17]
			),
		];
	}
}