class MainTest {
	static function main() {
		{
			Sys.println("Hard area death test");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.ChangeBattleArea(100);
			for (i in 1...99) {
				bm.update(0.9);
				if (bm.getPlayerTimesKilled() < 5) {
					Sys.println("Did not die!");
					Sys.getChar();
				}
			}
		}
		{
			Sys.println("Easy area no death");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.ChangeBattleArea(100);
			for (i in 1...99) {
				bm.update(0.9);
				if (bm.getPlayerTimesKilled() < 5) {
					Sys.println("Did not die!");
					Sys.getChar();
				}
			}
		}
	}
}
