// package logic;
import seedyrng.Random;
import RPGData.Balancing;
import js.html.GamepadEvent;
import haxe.Json;
import haxe.ds.Vector;
import RPGData;

typedef PlayerActionExecution = {
	public var actualAction : PlayerAction->Void;
}	

class BattleManager {

	

	public var wdata:WorldData;

	public var dirty = false;
	public var canRetreat = false;
	public var canAdvance = false;
	public var canLevelUp = false;
	public var areaBonus:ScalingResource;

	var balancing:Balancing;
	var timePeriod = 0.6;
	var equipDropChance = 30;
	var random = new Random();

	public var events = new Array<GameEvent>();

	public var playerActions:Map<String, PlayerActionExecution> = new Map<String, PlayerActionExecution>();

	public function GetAttribute(actor:Actor, label:String) {
		var i = actor.attributesCalculated[label];
		if (i < 0)
			i = 0;
		return i;
	}

	public function ChangeBattleArea(area:Int) {
		// previous area code
		// reset kill count of complete areas when leaving them

		if (wdata.killedInArea[wdata.battleArea] >= wdata.necessaryToKillInArea) {
			wdata.killedInArea[wdata.battleArea] = 0;
		}

		// actual change to area
		wdata.battleArea = area;
		wdata.necessaryToKillInArea = 0;
		if (wdata.killedInArea.length <= area)
			wdata.killedInArea[area] = 0;

		var initialEnemyToKill = Std.int(balancing.timeForFirstAreaProgress / balancing.timeToKillFirstEnemy);

		if (area > 0) {
			wdata.necessaryToKillInArea = initialEnemyToKill * area;

			if (PlayerFightMode()) {
				CreateAreaEnemy();
			}
		} else {
			wdata.enemy = null;
		}

		ResourceLogic.recalculateScalingResource(wdata.battleArea, areaBonus);

		dirty = true;
	}

	function PlayerFightMode(){
		return wdata.recovering != true && wdata.sleeping != true;
	}

	function AwardXP(xpPlus) {
		wdata.hero.xp.value += xpPlus;
		var e = AddEvent(GetXP);
		e.data = xpPlus;
	}

	function CreateAreaEnemy() {
		var area = wdata.battleArea;
		var timeToKillEnemy = balancing.timeToKillFirstEnemy;

		var initialAttackHero = 1; // may have to put this somewhere...
		var heroAttackTime = timePeriod * 2;
		var heroDPS = initialAttackHero / heroAttackTime;

		var initialLifeEnemy = Std.int(heroDPS * timeToKillEnemy);

		var enemyLife = initialLifeEnemy + (area - 1) * (initialLifeEnemy);

		var stats2 = ["Attack" => 1 + (area - 1) * 1, "Life" => enemyLife, "LifeMax" => enemyLife];
		wdata.enemy = {
			level: 1 + area,
			attributesBase: stats2,
			equipmentSlots: null,
			equipment: [],
			xp: null,
			attributesCalculated: stats2,
			reference: new ActorReference(1, 0)
		};
	}

	public function new() {
		balancing = {
			timeToKillFirstEnemy: 5,
			timeForFirstAreaProgress: 20,
			timeForFirstLevelUpGrind: 90,
			areaBonusXPPercentOfFirstLevelUp: 60
		};

		var stats = ["Attack" => 1, "Life" => 20, "LifeMax" => 20];
		var stats2 = ["Attack" => 2, "Life" => 6, "LifeMax" => 6];

		var w:WorldData = {
			worldVersion: 301,
			hero: {
				level: 1,
				attributesBase: stats,
				equipmentSlots: null,
				equipment: null,
				xp: null,
				attributesCalculated: stats.copy(),
				reference: new ActorReference(0, 0),
			},
			enemy: null,

			maxArea: 1,
			necessaryToKillInArea: 0,
			killedInArea: [0, 0],

			timeCount: 0,
			playerTimesKilled: 0,
			battleArea: 0,
			turn: false,
			playerActions: new Map<String, PlayerAction>(),
			recovering: false,
			sleeping: false
		};
		w.playerActions.set("advance", {
			visible: true,
			enabled: false,
			timesUsed: 0,
			mode: 0
		});
		w.playerActions.set("retreat", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		});
		w.playerActions.set("levelup", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		});
		

		

		wdata = w;

		
		ReinitGameValues();
		ChangeBattleArea(0);
	}

	// currently everything gets saved, even stuff that shouldn't
	// This method will reinit some of those values when loading or creating a new game
	public function ReinitGameValues() {
		var addAction = (id :String, action:PlayerAction, callback : PlayerAction->Void) ->{
			//only if action isn't already defined
			var w = wdata;
			if(wdata.playerActions.exists(id) == false){
				wdata.playerActions[id] = action;
				playerActions[id] = {actionData:w.playerActions[id], actualAction:callback}		
			}
			
		}

		var createAction = ()->{ 
			var a : PlayerAction;
			a = {visible: false, enabled: false, mode: 0, timesUsed: 0};
			return a;
		}
		
		addAction("sleep", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, (a) -> {
			wdata.enemy = null;
			wdata.sleeping = !wdata.sleeping;
		});

		addAction("repeat", createAction(), (a) -> {
			wdata.killedInArea[wdata.battleArea] = 0;
		});


		

		
		var valueXP = 0;
		if (wdata.hero.xp != null) {
			valueXP = wdata.hero.xp.value;
		}

		var timeLevelUpGrind = balancing.timeForFirstLevelUpGrind;
		var initialEnemyXP = 2; // this might need to be in balancing
		var initialXPToLevelUp = Std.int(balancing.timeForFirstLevelUpGrind * initialEnemyXP / balancing.timeToKillFirstEnemy);

		wdata.hero.xp = ResourceLogic.getExponentialResource(1.5, 1, initialXPToLevelUp);
		wdata.hero.xp.value = valueXP;

		ResourceLogic.recalculateScalingResource(wdata.hero.level, wdata.hero.xp);

		areaBonus = ResourceLogic.getExponentialResource(1.5, 1, Std.int(initialXPToLevelUp * balancing.areaBonusXPPercentOfFirstLevelUp / 100));

		if (wdata.hero.equipment == null) {
			wdata.hero.equipment = [];
		}
		if (wdata.hero.equipmentSlots == null) {
			wdata.hero.equipmentSlots = [-1, -1, -1];
		}
	}

	public function advance() {
		var hero = wdata.hero;
		var enemy = wdata.enemy;
		var killedInArea = wdata.killedInArea;
		var battleArea = wdata.battleArea;
		var areaComplete = killedInArea[battleArea] >= wdata.necessaryToKillInArea;
		var attackHappen = true;

		if (areaComplete) {
			wdata.enemy = null;
			attackHappen = false;
		}

		if (wdata.battleArea > 0 && PlayerFightMode() && areaComplete != true) {
			if (enemy == null) {
				CreateAreaEnemy();
				enemy = wdata.enemy;
				attackHappen = false;
			}
			if (enemy.attributesCalculated["Life"] <= 0) {
				attackHappen = false;

				enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
				// c = Sys.getChar(true);
			}
		}

		if (PlayerFightMode() == false || enemy == null) {
			attackHappen = false;
			var life = wdata.hero.attributesCalculated["Life"];
			var lifeMax = wdata.hero.attributesCalculated["LifeMax"];
			life += 2;
			if(wdata.sleeping){
				life += 10;
			}
			if (life > lifeMax)
				life = lifeMax;
			wdata.hero.attributesCalculated["Life"] = life;
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
				if (random.randomInt(0, 100) < equipDropChance) {
					var attackBonus = random.randomInt(1, Std.int(enemy.attributesCalculated["Attack"] / 2 + 2));

					var e:Equipment = {type: 0, requiredAttributes: null, attributes: ["Attack" => attackBonus]};

					if (random.randomInt(0, 100) < 20) {
						var lifeBonus = random.randomInt(1, Std.int(enemy.attributesCalculated["Attack"] / 2 + 2));
						e.attributes["LifeMax"] = lifeBonus;
					}

					wdata.hero.equipment.push(e);
					var e = AddEvent(EquipDrop);
					e.data = wdata.hero.equipment.length - 1;
					e.origin = enemy.reference;
				}

				var e = AddEvent(ActorDead);
				e.origin = enemy.reference;

				var xpGain = enemy.level;
				AwardXP(enemy.level);

				if (killedInArea[battleArea] >= wdata.necessaryToKillInArea) {
					
					this.AddEvent(AreaComplete).data = wdata.battleArea;

					if (wdata.maxArea == wdata.battleArea) {
						// var xpPlus = Std.int(Math.pow((hero.xp.scaling.data1-1)*0.5 +1, wdata.battleArea) * 50);
						ResourceLogic.recalculateScalingResource(wdata.battleArea, areaBonus);
						var xpPlus = areaBonus.calculatedMax;
						AwardXP(xpPlus);
						wdata.maxArea++;
						this.AddEvent(AreaUnlock).data = wdata.maxArea;
						killedInArea[wdata.maxArea] = 0;
					} 
					
				}
			}
			if (hero.attributesCalculated["Life"] <= 0) {
				wdata.recovering = true;
				wdata.enemy = null;
				var e = AddEvent(ActorDead);
				e.origin = hero.reference;
				wdata.playerTimesKilled++;
			}
		}

		wdata.turn = !wdata.turn;
		return "";
	}

	public function DiscardEquipment(pos) {
		wdata.hero.equipment[pos] = null;
		//wdata.hero.equipment.remove(wdata.hero.equipment[pos]);
		RecalculateAttributes(wdata.hero);
	}

	public function ToggleEquipped(pos) {
		if (wdata.hero.equipmentSlots[0] == pos) {
			wdata.hero.equipmentSlots[0] = -1;
		} else {
			wdata.hero.equipmentSlots[0] = pos;
		}
		RecalculateAttributes(wdata.hero);
	}

	public function IsEquipped(pos):Bool {
		return wdata.hero.equipmentSlots.contains(pos);
	}

	function AddEvent(eventType):GameEvent {
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
			lu.enabled = canRetreat;
			lu.visible = lu.enabled || lu.visible;
		}
		{
			var lu = wdata.playerActions["repeat"];
			lu.enabled = wdata.maxArea > wdata.battleArea && wdata.killedInArea[wdata.battleArea] > 0;
			lu.visible = lu.enabled || lu.visible;
		}
		{
			var lu = wdata.playerActions["sleep"];
			if(wdata.sleeping == true){
				lu.mode = 1;
				lu.enabled = true;
				trace(lu.mode);
			} else{
				lu.mode = 0;
				//sleep is okay even when recovered for faster active play
				lu.enabled = wdata.hero.attributesCalculated["Life"] < wdata.hero.attributesCalculated["LifeMax"] && wdata.recovering == false;	
			}
			lu.visible = lu.enabled || lu.visible;
		}

		if (wdata.recovering && wdata.hero.attributesCalculated["Life"] >= wdata.hero.attributesCalculated["LifeMax"]) {
			wdata.hero.attributesCalculated["Life"] = wdata.hero.attributesCalculated["LifeMax"];
			wdata.recovering = false;
		}

		if (wdata.timeCount >= timePeriod) {
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
		if (canLevelUp) {
			ForceLevelUp();
		}
	}

	public function ForceLevelUp() {
		// Hero level up
		var hero = wdata.hero;
		hero.xp.value -= hero.xp.calculatedMax;
		hero.level++;
		AddEvent(ActorLevelUp);
		RecalculateAttributes(hero);
		ResourceLogic.recalculateScalingResource(hero.level, hero.xp);
	}

	public function RecalculateAttributes(actor:Actor) {
		AttributeLogic.Add(actor.attributesBase, ["Attack" => 1, "LifeMax" => 5, "Life" => 5], actor.level, actor.attributesCalculated);
		for (es in actor.equipmentSlots) {
			var e = actor.equipment[es];
			if (e != null)
				AttributeLogic.Add(actor.attributesCalculated, e.attributes, 1, actor.attributesCalculated);
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
		var loadedWdata : WorldData = Json.parse(jsonString);
		if(loadedWdata.worldVersion < 301){
			loadedWdata.worldVersion = 301;
			loadedWdata.sleeping = loadedWdata.sleeping == true;
		}
		wdata = loadedWdata;

		if (wdata.battleArea >= wdata.killedInArea.length) {
			wdata.battleArea = wdata.killedInArea.length - 1;
		}
		if (wdata.maxArea >= wdata.killedInArea.length) {
			wdata.maxArea = wdata.killedInArea.length - 1;
		}
		
		ReinitGameValues();
		/*
			var data = Json.parse(jsonString);
			wdata.maxArea = data.maxArea;
			wdata.battleArea = data.currentArea;
			wdata.killedInArea = data.enemiesKilledInAreas;
		 */
	}
}
