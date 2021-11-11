import sys.io.File;
import RPGData;
import haxe.Json;
import SaveAssistant.PersistenceMaster;

class MainTest {
	static function main() {
		{
			Sys.println("resource load text");
			var sj = haxe.Resource.getString("storyjson");
			//Sys.println(sj);
			Json.parse(sj);
		}
		{
			Sys.println("Discard worse equip tests");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Attack" => 2]});
			bm.DiscardWorseEquipment();
			var numberOfNullEquipment = 0;
			for (e in bm.wdata.hero.equipment) {
				if (e == null)
					numberOfNullEquipment++;
			}
			if (numberOfNullEquipment != 0) {
				Sys.println('ERROR: discard worse equipment problem: $numberOfNullEquipment VS 0');
			}

			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Attack" => 2]});
			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Attack" => 1]});
			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Life" => 3]});

			bm.DiscardWorseEquipment();

			numberOfNullEquipment = 0;
			for (e in bm.wdata.hero.equipment) {
				if (e == null)
					numberOfNullEquipment++;
			}
			if (numberOfNullEquipment != 2) {
				Sys.println('ERROR: discard worse equipment problem: $numberOfNullEquipment VS 2');
			}

			if (bm.wdata.hero.equipment[0] == null)
				Sys.println('ERROR: discard worse equipment problem 0');
			if (bm.wdata.hero.equipment[1] != null)
				Sys.println('ERROR: discard worse equipment problem 1');
			if (bm.wdata.hero.equipment[2] != null)
				Sys.println('ERROR: discard worse equipment problem 2');
			if (bm.wdata.hero.equipment[3] == null)
				Sys.println('ERROR: discard worse equipment problem 3');

			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Attack" => 1, "Life" => 2]});
			bm.wdata.hero.equipment.push({seen: false,type: 0, requiredAttributes: null, attributes: ["Attack" => 1, "Defense" => 1]});

			bm.DiscardWorseEquipment();

			numberOfNullEquipment = 0;
			for (e in bm.wdata.hero.equipment) {
				if (e == null)
					numberOfNullEquipment++;
			}
			if (numberOfNullEquipment != 2) {
				Sys.println('ERROR: discard worse equipment problem: $numberOfNullEquipment VS 2 (b)');
			}
		}
		{
			Sys.println("Prestige unlock test");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			var a = bm.wdata.playerActions["prestige"];
			if (a.enabled == true) {
				Sys.println("Error: prestige wrong 1");
			}
			bm.wdata.hero.level = 15;
			for (i in 1...400) {
				bm.update(0.9);
			}
			if (a.enabled == false) {
				Sys.println("Error: prestige wrong 2");
			}
			bm.PrestigeExecute();
			bm.update(0.9);
			bm.update(0.9);
			if (a.enabled == true) {
				Sys.println("Error: prestige wrong 3");
				Sys.println("Level Requirement for prestige "+bm.GetLevelRequirementForPrestige());
			}
			bm.wdata.hero.level = 15;
			for (i in 1...400) {
				bm.update(0.9);
			}
			if (a.enabled == true) {
				Sys.println("Error: prestige wrong 4");
			}
			bm.wdata.hero.level = 25;
			for (i in 1...400) {
				bm.update(0.9);
			}
			if (a.enabled == false) {
				Sys.println("Error: prestige wrong 5");
			}
		}
		//if(false)
		{
			Sys.println("Prestige permanent stat test");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			bm.wdata.hero.level = 200;
			bm.RecalculateAttributes(bm.wdata.hero);

			Sys.println("Accessing Speed 0");
			if (bm.wdata.hero.attributesCalculated["Speed"] != 20) {
				Sys.println("Error: wrong speed 0");
			}

			bm.changeRegion(0);
			bm.changeRegion(1);
			bm.ChangeBattleArea(1);
			for (i in 1...600) {
				bm.update(0.9);
			}
			Sys.println("Accessing Speed 1");
			if (bm.wdata.hero.attributesCalculated["Speed"] != 22) {
				Sys.println("Error: wrong speed 1");
			}
			bm.PrestigeExecute();
			Sys.println("Accessing Speed 2");
			if (bm.wdata.hero.attributesCalculated["Speed"] != 22) {
				Sys.println("Error: wrong speed 2");
				Sys.println("speed is: "+ bm.wdata.hero.attributesCalculated["Speed"]);
			}

			bm.wdata.hero.level = 200;
			bm.RecalculateAttributes(bm.wdata.hero);

			bm.changeRegion(1);
			bm.ChangeBattleArea(1);
			for (i in 1...600) {
				bm.update(0.9);
			}
			Sys.println("Accessing Speed 3");
			if(bm.wdata.hero.attributesCalculated["Speed"] != 24){
				Sys.println("Error: wrong speed 3");
				Sys.println("speed is: "+ bm.wdata.hero.attributesCalculated["Speed"]);
				Sys.println("max area in region 1 is: "+bm.wdata.regionProgress[1].maxArea);
				Sys.println(bm.wdata.hero);
				return;
			}

			bm.ChangeBattleArea(2);
			for (i in 1...600) {
				bm.update(0.9);
			}
			Sys.println("Accessing Speed 4");
			if(bm.wdata.hero.attributesCalculated["Speed"] != 26){
				Sys.println("Error: wrong speed 4");
				Sys.println("speed is: "+ bm.wdata.hero.attributesCalculated["Speed"]);
			}
		}
		{
			Sys.println("Save legacy test");
			for (file in sys.FileSystem.readDirectory("saves/")) {
				trace(file);
				var path = haxe.io.Path.join(["saves/", file]);
				var json = sys.io.File.getContent(path);
				var bm = new BattleManager();
				bm.SendJsonPersistentData(SaveAssistant.GetPersistenceMaster(json).jsonGameplay);
				for (i in 1...400) {
					bm.update(0.9);
				}
			}
		}
		{
			Sys.println("Test region progress");
			var bm:BattleManager = new BattleManager();
			bm.DefaultConfiguration();
			for (i in 0...bm.wdata.regionProgress.length) {
				bm.wdata.regionProgress[i].maxArea = 20;
			}
			for (i in 1...400) {
				bm.update(0.9);
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
				Sys.println("ERROR: Did not die! " + bm.getPlayerTimesKilled());
				// Sys.getChar(false);
			}
			for (i in 1...400) {
				bm.ForceLevelUp();
			}
			for (i in 1...400) {
				bm.update(0.9);
			}
			var json = bm.GetJsonPersistentData();
			// var content:String = sys.io.File.getContent('my_file.txt');
			var fileName = "saves/basic" + bm.wdata.worldVersion + ".json";
			var pm:PersistenceMaster = {worldVersion: bm.wdata.worldVersion, jsonGameplay: json, jsonStory: null};
			sys.io.File.saveContent(fileName, Json.stringify(pm));
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
				// Sys.getChar(false);
			}
		}

		{
			Sys.println("Level up Stat Test");
			var stats = ["Attack" => 5, "Life" => 20, "LifeMax" => 20];
			var hero:Actor = {
				level: 1,
				attributesBase: stats,
				equipmentSlots: null,
				equipment: null,
				xp: ResourceLogic.getExponentialResource(1.5, 1, 5),
				attributesCalculated: stats.copy(),
				reference: new ActorReference(0, 0)
			};
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 1, hero.attributesCalculated);
			if (hero.attributesCalculated["Attack"] != 6) {
				Sys.println("ERROR: Calculated Attack Value Wrong");
				// Sys.getChar(false);
			}
			if (hero.attributesBase["Attack"] != 5) {
				Sys.println("ERROR: Base Attack Value Modified");
				// Sys.getChar(false);
			}
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 1, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 2, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 3, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 4, hero.attributesCalculated);
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], 5, hero.attributesCalculated);
			if (hero.attributesCalculated["Attack"] != (5 + 5)) {
				Sys.println("ERROR: Calculated Attack Value Wrong");
				// Sys.getChar(false);
			}
			if (hero.attributesBase["Attack"] != 5) {
				Sys.println("ERROR: Base Attack Value Modified");
				// Sys.getChar(false);
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

			// 20
			var battleArea = bm.wdata.battleArea;

			// force load
			var json = bm.GetJsonPersistentData();
			bm.SendJsonPersistentData(json);

			if (bm.wdata.battleArea != battleArea) {
				Sys.println("ERROR: Battle Area corrupted when loading");
				Sys.println("ERROR: Battle Area before " + battleArea);
				Sys.println("ERROR: Battle Area after " + bm.wdata.battleArea);
			}

			var json2 = bm.GetJsonPersistentData();

			if (json0 == json2) {
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

				sys.io.File.saveContent('error/json.json', json);
				sys.io.File.saveContent('error/json2.json', json2);
				// Sys.getChar(false);
			}
		}
	}
}
