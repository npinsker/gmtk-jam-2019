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
				["Slug*", "jun", "TAG", "Octo", "sota"],
				[772000, 660410, 425500, 353800, 255000]
			),
			'ducky' => new ArcadeCabinet.HighScoreTable(
				["QUEEN", "lil_s", "lil_s", "Borby", "fish"],
				[325, 129, 116, 72, 37]
			),
			'sorting' => new ArcadeCabinet.HighScoreTable(
				["squid", "frog", "Octo", "chaos", "AAA"],
				[63, 54, 49, 32, 27]
			),
		];
	}
}