// package logic;
import js.html.GamepadEvent;
import haxe.Json;
import haxe.ds.Vector;
import RPGData;

class BattleManager {
	public var wdata:WorldData;

	public var dirty = false;
	public var canRetreat = false;
	public var canAdvance = false;
	public var canLevelUp = false;

	public var events = new Array<GameEvent>();

	public function GetAttribute(actor:Actor, label:String) {
		var i = actor.attributesCalculated[label];
		if (i < 0)
			i = 0;
		return i;
	}

	public function ChangeBattleArea(area:Int) {
		wdata.battleArea = area;
		wdata.necessaryToKillInArea = 0;
		wdata.killedInArea[area] = 0;
		if(area > 0){
			wdata.necessaryToKillInArea = 5 + area;
			var enemyLife = 6 + area * 3;
			var stats2 = ["Attack" => 2 + area * 3, "Life" => enemyLife, "LifeMax" => enemyLife];
			wdata.enemy = {
				level: 1 + area,
				attributesBase: stats2,
				equipmentSlots: null,
				equipment: null,
				xp: null,
				attributesCalculated: stats2,
				reference: new ActorReference(1, 0)
			};
		} else{
			wdata.enemy = null;
		}
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
				attributesCalculated: stats.copy(),
				reference: new ActorReference(0, 0)
			},
			enemy: null,

			maxArea: 1,
			necessaryToKillInArea: 0,
			killedInArea: [0, 0],

			timePeriod: 1,
			timeCount: 0,
			playerTimesKilled: 0,
			battleArea: 0,
			turn: false,
			playerActions: new Map<String, PlayerAction>()
		};
		w.playerActions.set("advance",{
			visible: true, enabled: false
		});
		w.playerActions.set("retreat",{
			visible: false, enabled: false
		});
		w.playerActions.set("levelup",{
			visible: false, enabled: false
		});
		wdata = w;
		ChangeBattleArea(0);
	}

	public function advance() {
		var hero = wdata.hero;
		var enemy = wdata.enemy;
		var event:String = "";
		var killedInArea = wdata.killedInArea;
		var battleArea = wdata.battleArea;
		var attackHappen = true;

		if (hero.attributesCalculated["Life"] <= 0) {
			
			event += "You died\n\n\n";
			hero.attributesCalculated["Life"] = hero.attributesCalculated["LifeMax"];
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
			attackHappen = false;
			// c = Sys.getChar(true);
		}

		if(wdata.battleArea > 0){
			if (enemy.attributesCalculated["Life"] <= 0) {
				attackHappen = false;
				event += "New enemy";
				event += "\n\n\n";
				enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
				// c = Sys.getChar(true);
			}
		}
		if(enemy == null){
			attackHappen = false;
		}
	
		// c = Sys.getChar(true);
		if (attackHappen) {
			var gEvent = AddEvent(ActorAttack);
			var attacker = hero;
			var defender = enemy;
			var which = 0;
			

			if (wdata.turn) {
				attacker = enemy;
				defender = hero;
			}
			
			var damage = attacker.attributesCalculated["Attack"];

			defender.attributesCalculated["Life"] -= damage;
			if (defender.attributesCalculated["Life"] < 0) {
				defender.attributesCalculated["Life"] = 0;
			}
			gEvent.origin = attacker.reference;
			gEvent.target = defender.reference;
			gEvent.data = damage;

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
						killedInArea[wdata.maxArea] = 0;
					}
				}
				hero.xp.value += enemy.level;
				var e = AddEvent(ActorDead);
				e.origin = enemy.reference;
			}
			if (hero.attributesCalculated["Life"] <= 0) {
				var e = AddEvent(ActorDead);
				e.origin = hero.reference;
				wdata.playerTimesKilled++;
			}
		}

		wdata.turn = !wdata.turn;
		return "";
	}

	function AddEvent(eventType): GameEvent{
		var e = new GameEvent(eventType);
		this.events.push(e);
		return e;
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
		{
			var lu = wdata.playerActions["levelup"];
			lu.visible = canLevelUp;
			lu.enabled = canLevelUp;
		}
		{
			var lu = wdata.playerActions["advance"];
			lu.visible = canAdvance || lu.visible;
			lu.enabled = canAdvance;
		}
		{
			var lu = wdata.playerActions["retreat"];
			lu.visible = canRetreat || lu.visible;
			lu.enabled = canRetreat;
		}

		if (wdata.timeCount >= wdata.timePeriod) {
			wdata.timeCount = 0;
			return advance();
		}
		if (dirty) {
			dirty = false;
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

	public function LevelUp() {
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
		if(wdata.battleArea >= wdata.killedInArea.length){
			wdata.battleArea = wdata.killedInArea.length-1;
		}
		if(wdata.maxArea >= wdata.killedInArea.length){
			wdata.maxArea = wdata.killedInArea.length-1;
		}
		/*
			var data = Json.parse(jsonString);
			wdata.maxArea = data.maxArea;
			wdata.battleArea = data.currentArea;
			wdata.killedInArea = data.enemiesKilledInAreas;
		 */
	}
}
