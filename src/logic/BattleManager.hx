// package logic;
import haxe.Json;
import haxe.ds.Vector;
import RPGData;

class BattleManager {
	public var wdata:WorldData;

	public var dirty = false;
	public var canRetreat = false;
	public var canAdvance = false;
	public var canLevelUp = false;

	public function GetAttribute(actor:Actor, label:String){
		var i = actor.attributesCalculated[label];
		if(i < 0) i = 0;
		return i;
	}

	public function ChangeBattleArea(area:Int) {
		wdata.battleArea = area;
		wdata.necessaryToKillInArea = 5 + area;
		var enemyLife = 6 + area * 3;
		var stats2 = ["Attack" => 2 + area * 3, "Life" => enemyLife, "LifeMax" => enemyLife];
		wdata.enemy = {
			level: 1 + area,
			attributesBase: stats2,
			equipmentSlots: null,
			equipment: null,
			xp: null,
			attributesCalculated: stats2
		};
		dirty = true;
	}

	public function new() {
		var stats = ["Attack" => 5, "Life" => 20, "LifeMax" => 20];
		var stats2 = ["Attack" => 2, "Life" => 6, "LifeMax" => 6];

		var w:WorldData = {
			hero: {
				level: 1,
				attributesBase: stats,
				equipmentSlots: null,
				equipment: null,
				xp: ResourceLogic.getExponentialResource(1.5, 1, 5),
				attributesCalculated: stats.copy()
			},
			enemy: {
				level: 1,
				attributesBase: stats2,
				equipmentSlots: null,
				equipment: null,
				xp: null,
				attributesCalculated: stats2
			},

			maxArea: 0,
			necessaryToKillInArea: 0,
			killedInArea: [],

			timePeriod: 1,
			timeCount: 0,
			playerTimesKilled: 0,
			battleArea: 0,
			turn: false
		};

		wdata = w;
	}

	public function advance() {
		var hero = wdata.hero;
		var enemy = wdata.enemy;
		var event:String = "";
		var killedInArea = wdata.killedInArea;
		var battleArea = wdata.battleArea;

		if (hero.attributesCalculated["Life"] <= 0) {
			wdata.playerTimesKilled++;
			event += "You died\n\n\n";
			hero.attributesCalculated["Life"] = hero.attributesCalculated["LifeMax"];
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
			// c = Sys.getChar(true);
		}

		if (enemy.attributesCalculated["Life"] <= 0) {
			#if !target.static
			if (killedInArea[battleArea] == null) {
				killedInArea[battleArea] = 0;
			}
			#end
			killedInArea[battleArea]++;
			if (killedInArea[battleArea] >= wdata.necessaryToKillInArea) {
				if (wdata.maxArea == wdata.battleArea) {
					wdata.maxArea++;
				}
			}
			hero.xp.value += enemy.level;
			
			event += "New enemy";
			event += "\n\n\n";
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
			// c = Sys.getChar(true);
		}
		var output = BaseInformationFormattedString();
		output += "\n\n";
		output += event;
		// c = Sys.getChar(true);
		var attacker = hero;
		var defender = enemy;
		if (wdata.turn) {
			attacker = enemy;
			defender = hero;
		}
		defender.attributesCalculated["Life"] -= attacker.attributesCalculated["Attack"];
		if(defender.attributesCalculated["Life"] < 0){
			defender.attributesCalculated["Life"] = 0;

		}
		wdata.turn = !wdata.turn;
		return output;
	}

	function BaseInformationFormattedString():String {
		var hero = wdata.hero;
		var maxArea = wdata.maxArea;
		var battleArea = wdata.battleArea;
		var enemy = wdata.enemy;

		var level = hero.level;
		var xp = hero.xp.value;
		var xpmax = hero.xp.calculatedMax;
		var baseInfo = CharacterBaseInfoFormattedString(hero);
		var areaText = "";
		var battleAreaShow = battleArea + 1;
		var maxAreaShow = maxArea + 1;

		if (maxArea > 0) {
			areaText = 'Area: $battleAreaShow / $maxAreaShow';
		}
		var output = '$areaText

\n\nPlayer 
	level: $level
	xp: $xp / $xpmax
$baseInfo';

		baseInfo = CharacterBaseInfoFormattedString(enemy);
		output += "\n\n";
		output += 'Enemy
$baseInfo';
		return output;
	}

	function CharacterBaseInfoFormattedString(actor:Actor):String {
		var life = actor.attributesCalculated["Life"];
		var lifeM = actor.attributesCalculated["LifeMax"];
		var attack = actor.attributesCalculated["Attack"];
		return '	 Life: $life / $lifeM
	Attack: $attack';
	}

	public function update(delta:Float):String {
		wdata.timeCount += delta;

		canAdvance = wdata.battleArea < wdata.maxArea;
		canRetreat = wdata.battleArea > 0;
		canLevelUp = wdata.hero.xp.value >= wdata.hero.xp.calculatedMax;

		
		if (wdata.timeCount >= wdata.timePeriod) {
			wdata.timeCount = 0;
			return advance();
		}
		if (dirty) {
			dirty = false;
			return BaseInformationFormattedString();
		}
		return null;
	}

	public function DefaultConfiguration() {}

	public function getPlayerTimesKilled():Int {
		return wdata.playerTimesKilled;
	}

	public function RetreatArea() {
		if (wdata.battleArea > 0)
			ChangeBattleArea(wdata.battleArea - 1);
	}
	public function LevelUp(){
		var hero = wdata.hero;
		if (canLevelUp) {
			// Hero level up
			hero.xp.value -= hero.xp.calculatedMax;
			hero.level++;
			AttributeLogic.Add(hero.attributesBase, ["Attack" => 1, "LifeMax" => 1, "Life" => 1], hero.level, hero.attributesCalculated);
			ResourceLogic.recalculateScalingResource(hero.level, hero.xp);
		}
	}

	public function AdvanceArea() {
		ChangeBattleArea(wdata.battleArea + 1);
	}

	public function GetJsonPersistentData():String {
		// var data = {maxArea: maxArea, currentArea: battleArea, enemiesKilledInAreas: killedInArea};

		return Json.stringify(wdata);
	}

	public function SendJsonPersistentData(jsonString) {
		wdata = Json.parse(jsonString);
		/*
			var data = Json.parse(jsonString);
			wdata.maxArea = data.maxArea;
			wdata.battleArea = data.currentArea;
			wdata.killedInArea = data.enemiesKilledInAreas;
		 */
	}
}
