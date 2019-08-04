package;

class PlayerData {
	public static var instance:PlayerData = new PlayerData();
	
	public static var OVERALL_QUEST:String = 'OVERALL_QUEST';
	public static var RHYTHM_KING_QUEST:String = 'RHYTHM_KING_QUEST';
	public static var ALL_QUESTS:Array<String> = [OVERALL_QUEST, RHYTHM_KING_QUEST];
	
	public static var PLAYER_NAME:String = 'You';
	
	public var highScores:Map<String, ArcadeCabinet.HighScoreTable>;
	

	public function new() {
		highScores = [
			'rhythm' => new ArcadeCabinet.HighScoreTable(
				["Slug*", "jun", "TAG", "Octo", "sota"],
				[682000, 560410, 425500, 353800, 255000]
			),
			'ducky' => new ArcadeCabinet.HighScoreTable(
				["QUEEN", "fish", "fish", "lilskunk", "Borby"],
				[135, 64, 56, 20, 17]
			),
			'sorting' => new ArcadeCabinet.HighScoreTable(
				["squid", "frog", "Octo", "chaos", "AAA"],
				[59, 50, 43, 27, 24]
			),
		];
	}
}