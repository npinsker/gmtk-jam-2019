package;

@:enum
abstract OverallQuestProgress(Int) {
	var JustStarted = 0;
	var TalkedToBartender = 1;
}

@:enum
abstract RhythmKingProgress(Int) {
	var NotStarted = 0;
	var TalkedToKing = 1;
}