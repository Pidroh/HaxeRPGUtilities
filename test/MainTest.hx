import RPGData;

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

		{
			Sys.println("Level up Stat Test");
			var stats = ["Attack"=> 5, "Life" => 20, "LifeMax" => 20];
        	var hero : Actor = {level:1, attributesBase:stats, equipmentSlots: null, equipment: null, 
			xp:ResourceLogic.getExponentialResource(1.5, 1, 5), attributesCalculated: stats.copy()};
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 1, hero.attributesCalculated);
			if (hero.attributesCalculated["Attack"] != 6) {
				Sys.println("ERROR: Calculated Attack Value Wrong");
				//Sys.getChar(false);
			}
			if (hero.attributesBase["Attack"] != 5) {
				Sys.println("ERROR: Base Attack Value Modified");
				//Sys.getChar(false);
			}
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 1, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 2, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 3, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 4, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], 5, hero.attributesCalculated);
			if (hero.attributesCalculated["Attack"] != (5+5)) {
				Sys.println("ERROR: Calculated Attack Value Wrong");
				//Sys.getChar(false);
			}
			if (hero.attributesBase["Attack"] != 5) {
				Sys.println("ERROR: Base Attack Value Modified");
				//Sys.getChar(false);
			}
		}

		{
			Sys.println("Json parsing save data tests");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			var json0 = bm.GetJsonPersistentData();
			bm.ChangeBattleArea(1);
			for (i in 1...20) {
				bm.update(5);
			}
			bm.ChangeBattleArea(20);
			for (i in 1...20) {
				bm.update(5);
			}
			var json = bm.GetJsonPersistentData();
			bm.SendJsonPersistentData(json);
			var json2 = bm.GetJsonPersistentData();

			if(json0 == json2){
				Sys.println("ERROR: Data not changed on game progress");
			}
			if (json != json2) {
				Sys.println("ERROR: Data corrupted when loading");
				//Sys.getChar(false);
			}
		}
	}
}
