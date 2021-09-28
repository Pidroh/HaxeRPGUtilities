class MainTest {
	static function main() {
		{
			Sys.println("Hard area death test");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.ChangeBattleArea(100);
			for (i in 1...99) {
				bm.update(0.9);
				
			}
			if (bm.getPlayerTimesKilled() < 5) {
				Sys.println("ERROR: Did not die!");
				//Sys.getChar(false);
			}
		}
		{
			Sys.println("Easy area no death");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.ChangeBattleArea(1);
			for (i in 1...4) {
				bm.update(0.9);
				
			}
			if (bm.getPlayerTimesKilled() > 0) {
				Sys.println("ERROR: Died");
				//Sys.getChar(false);
			}
		}
	}
}
