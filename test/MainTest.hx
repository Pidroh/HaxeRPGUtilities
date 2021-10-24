import sys.io.File;
import RPGData;

class MainTest {
	static function main() {
		{
			Sys.println("resource load text");
			Sys.println(haxe.Resource.getString("storyjson"));
		}
		{
			Sys.println("Save legacy test");
			for(file in sys.FileSystem.readDirectory("saves/")){
				var path = haxe.io.Path.join(["saves/", file]);
				var json = sys.io.File.getContent(path);
				var bm = new BattleManager();
				bm.SendJsonPersistentData(json);
				for (i in 1...400) {
					bm.update(0.9);
				}
			}
		}
		{
			Sys.println("Hard area death test");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.ChangeBattleArea(100);
			for (i in 1...400) {
				bm.update(0.9);
			}
			if (bm.getPlayerTimesKilled() < 5) {
				Sys.println("ERROR: Did not die! "+bm.getPlayerTimesKilled());
				//Sys.getChar(false);
			}
			for (i in 1...400) {
				bm.ForceLevelUp();
			}
			for (i in 1...400) {
				bm.update(0.9);
			}
			var json = bm.GetJsonPersistentData();
			//var content:String = sys.io.File.getContent('my_file.txt');
			var fileName = "saves/basic"+bm.wdata.worldVersion+".json";
			sys.io.File.saveContent(fileName,json);
			
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
			xp:ResourceLogic.getExponentialResource(1.5, 1, 5), attributesCalculated: stats.copy(), reference: new ActorReference(0,0)};
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
			
			//20
			var battleArea = bm.wdata.battleArea;

			// force load
			var json = bm.GetJsonPersistentData();
			bm.SendJsonPersistentData(json);

			if(bm.wdata.battleArea != battleArea){
				Sys.println("ERROR: Battle Area corrupted when loading");
				Sys.println("ERROR: Battle Area before "+battleArea);
				Sys.println("ERROR: Battle Area after "+ bm.wdata.battleArea);
			}

			var json2 = bm.GetJsonPersistentData();

			if(json0 == json2){
				Sys.println("ERROR: Data not changed on game progress");
			}
			if (json != json2) {
				Sys.println("ERROR: Data corrupted when loading");
				
				trace("  _____ ");
				trace("  _____ ");
				trace("  _____ ");
				trace(json);
				trace("  _____ ");
				trace("  _____ ");
				trace("  _____ ");
				trace(json2);
				
				sys.io.File.saveContent('error/json.json',json);
				sys.io.File.saveContent('error/json2.json',json2);
				//Sys.getChar(false);
			}
		}
	}
}
