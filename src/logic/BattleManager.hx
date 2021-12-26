// package logic;
import BasicProcedural.ProceduralUnit;
import BasicProcedural.Generation;
import seedyrng.Random;
import RPGData.Balancing;
import js.html.GamepadEvent;
import haxe.Json;
import haxe.ds.Vector;
import RPGData;
import PrototypeItemMaker;
import ProceduralEnemyGeneration;

using PrototypeItemMaker.RandomExtender;

// using ArrayExtender;

typedef PlayerActionExecution = {
	public var actualAction:PlayerAction->Void;
}

typedef RegionPrize = {
	var statBonus:Map<String, Int>;
	var xpPrize:Bool;
}

class ArrayHelper {
	public static function InsertOnEmpty<T>(ele:T, array:Array<T>):Int {
		if (array.contains(null)) {
			var id = array.indexOf(null);
			array[id] = ele;
			return id;
		}
		array.push(ele);
		return array.length - 1;
	}
}

class BattleManager {
	public var wdata:WorldData;

	public var dirty = false;
	public var canRetreat = false;
	public var canAdvance = false;
	public var canLevelUp = false;
	public var areaBonus:ScalingResource;
	public var enemySheets = new Array<ActorSheet>();

	var balancing:Balancing;
	var timePeriod = 0.6;
	var equipDropChance = 30;
	var equipDropChance_Rare = 15;
	var random = new Random();
	var fixedRandom = new Random();

	public var events = new Array<GameEvent>();
	public var playerActions:Map<String, PlayerActionExecution> = new Map<String, PlayerActionExecution>();
	public var regionRequirements:Array<Int> = [0];
	public var regionPrizes:Array<RegionPrize> = [{statBonus: null, xpPrize: true}];
	public var itemBases:Array<ItemBase>;
	public var modBases:Array<ModBase>;
	public var skillBases:Array<Skill>;
	public var skillSlotUnlocklevel = [2, 7, 22, 35];
	public var volatileAttributeList = ["MP", "Life", "MPRechargeCount", "SpeedCount"];
	public var volatileAttributeAux = new Array<Int>();
	public var equipmentToDiscard = new Array<Equipment>();
	public var scheduledSkill:SkillUsable;
	public var enemyAreaFromProcedural = new EnemyAreaFromProceduralUnitRepetition();

	public function GetAttribute(actor:Actor, label:String) {
		var i = actor.attributesCalculated[label];
		if (i < 0)
			i = 0;
		return i;
	}

	public function UseMP(actor:Actor, mpCost, event = true) {
		var mp = actor.attributesCalculated["MP"];
		mp -= mpCost;

		if (mp <= 0) {
			mp = 0;
			actor.attributesCalculated["MPRechargeCount"] = 0;
			if (event) {
				var ev = AddEvent(MPRunOut);
				ev.origin = wdata.hero.reference;
			}
		}
		actor.attributesCalculated["MP"] = mp;
	}

	public function UseSkill(skill:SkillUsable, actor:Actor, activeStep = false) {
		var id = skill.id;
		var skillBase = GetSkillBase(id);

		if (skillBase.turnRecharge > 0) {
			if (actor.turnRecharge == null) {
				actor.turnRecharge = new Array<Int>();
			}
			actor.turnRecharge[actor.usableSkills.indexOf(skill)] = skillBase.turnRecharge;
		}

		if (activeStep == false && skillBase.activeEffect != null) {
			scheduledSkill = skill;
			return;
		}
		if (actor == wdata.hero) {
			wdata.timeCount = 0;
		}

		var executedEffects = 0;
		var efs = skillBase.effects;
		if (activeStep) {
			efs = skillBase.activeEffect;
		}
		var skillUsed = false;
		for (ef in efs) {
			var targets = new Array<Actor>();
			if (ef.target == SELF) {
				targets.push(actor);
			}
			if (ef.target == ENEMY) {
				if (wdata.hero == actor) {
					if (wdata.enemy.attributesCalculated["LifeMax"] == 0) {
						CreateAreaEnemy();
					}
					targets.push(wdata.enemy);
				} else
					targets.push(wdata.hero);
			}
			executedEffects++;

			// use the skill before the first effect,
			// but only if ANY effects are bound to happen
			if (skillUsed == false) {
				skillUsed = true;
				var mpCost = skillBase.mpCost;
				UseMP(actor, mpCost);
				var ev = AddEvent(SkillUse);
				ev.origin = wdata.hero.reference;
				ev.dataString = skill.id;
			}
			ef.effectExecution(this, skill.level, actor, targets);
		}

		// skillBase.effects
	}

	public function Heal(target:Actor, lifeMaxPercentage = 0, rawBonus = 0) {
		var lifem = target.attributesCalculated["LifeMax"];
		var life = target.attributesCalculated["Life"];
		life += rawBonus + Std.int(lifeMaxPercentage * lifem / 100);
		if (life > lifem)
			life = lifem;
		target.attributesCalculated["Life"] = life;
	}

	public function RemoveBuffs(defender:Actor, keepDebuffs = true) {
		if (keepDebuffs == false)
			defender.buffs.resize(0);
		else {
			var i = 0;
			while (i < defender.buffs.length) {
				if (defender.buffs[i].debuff == true) {
					i++;
					continue;
				}
				defender.buffs.remove(defender.buffs[i]);
			}
		}

		RecalculateAttributes(defender);
		AddEvent(BuffRemoval).origin = defender.reference;
	}

	public function AttackExecute(attacker:Actor, defender:Actor, attackRate = 100, attackBonus = 0, defenseRate = 100, element:String = null) {
		var gEvent = AddEvent(ActorAttack);
		var magicAttack = false;
		var enchant = attacker.attributesCalculated["enchant-fire"];
		if (enchant > 0) {
			magicAttack = true;
			attackBonus += enchant;
		}
		if (element != null) {
			magicAttack = true;
			var elementDmg = element + "-damage";
			if (defender.attributesCalculated.exists(elementDmg)) {
				var baseDmg = defender.attributesCalculated[elementDmg];
				attackRate = Std.int(attackRate * baseDmg / 100);
			}
		}
		if (attacker.attributesCalculated["Blood"] > 0) {
			var blood = attacker.attributesCalculated["Blood"];
			var bloodMul = 100;
			if (attacker.attributesCalculated["Bloodthirst"] > 0) {
				bloodMul += attacker.attributesCalculated["Bloodthirst"];
			}
			attackBonus += Std.int((blood * 5 + 10) * bloodMul / 100);
			var life = attacker.attributesCalculated["Life"];
			var decrease = attacker.attributesCalculated["LifeMax"] * blood / 100;
			if (decrease < 1)
				decrease = 1;
			if (decrease >= life - 1) {
				decrease = life - 1;
			}
			life -= Std.int(decrease);
			attacker.attributesCalculated["Life"] = life;
		}

		if (attacker.attributesCalculated["Antibuff"] > 0) {
			RemoveBuffs(defender);
		}

		if (magicAttack == false) {
			if (attacker.attributesCalculated["Piercing"] > 0 == true) {
				defenseRate = defenseRate - attacker.attributesCalculated["Piercing"];
			}
		}
		if (defenseRate < 0)
			defenseRate = 0;

		var attack:Float = 0;
		var defense:Float = 0;
		if (magicAttack) {
			attack = attacker.attributesCalculated["MagicAttack"];
			defense = defender.attributesCalculated["MagicDefense"];
		} else {
			attack = attacker.attributesCalculated["Attack"];
			defense = defender.attributesCalculated["Defense"];
		}
		attack = (attackRate * attack / 100) + attackBonus;
		var damage:Int = Std.int(attack - defense * defenseRate / 100);
		if (damage < 0)
			damage = 0;

		defender.attributesCalculated["Life"] -= damage;
		if (defender.attributesCalculated["Life"] < 0) {
			defender.attributesCalculated["Life"] = 0;
		}
		if (damage >= 1) {
			for (b in defender.buffs) {
				if (b.noble == true) {
					b.duration = 0;
				}
			}
		}
		gEvent.origin = attacker.reference;
		gEvent.target = defender.reference;
		gEvent.data = damage;

		var hero = wdata.hero;
		var enemy = wdata.enemy;
		var killedInArea = wdata.killedInArea;
		var battleArea = wdata.battleArea;
		var areaComplete = killedInArea[battleArea] >= wdata.necessaryToKillInArea;
		if (enemy.attributesCalculated["Life"] <= 0) {
			#if !target.static
			if (killedInArea[battleArea] == null) {
				killedInArea[battleArea] = 0;
			}
			#end
			killedInArea[battleArea]++;

			// only lagrima drops for now
			if (wdata.battleAreaRegion == 0)
				DropItemOrSkillSet(equipDropChance, 1, enemy.level, enemy.reference);

			var e = AddEvent(ActorDead);
			e.origin = enemy.reference;

			var xpGain = enemy.level;
			AwardXP(enemy.level);

			if (killedInArea[battleArea] >= wdata.necessaryToKillInArea) {
				this.AddEvent(AreaComplete).data = wdata.battleArea;

				if (wdata.maxArea == wdata.battleArea) {
					// var xpPlus = Std.int(Math.pow((hero.xp.scaling.data1-1)*0.5 +1, wdata.battleArea) * 50);
					if (regionPrizes[wdata.battleAreaRegion].xpPrize == true) {
						var areaForBonus = wdata.battleArea;
						ResourceLogic.recalculateScalingResource(areaForBonus, areaBonus);
						var xpPlus = areaBonus.calculatedMax;
						AwardXP(xpPlus);
					}
					if (regionPrizes[wdata.battleAreaRegion].statBonus != null) {
						for (su in regionPrizes[wdata.battleAreaRegion].statBonus.keyValueIterator()) {
							var e = this.AddEvent(statUpgrade);
							e.dataString = su.key;
							e.data = su.value;
						}
						this.AddEvent(PermanentStatUpgrade);
					}

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

	public function ForceSkillSetDrop(enemyLevel:Int, dropperReference = null, ss:SkillSet, event = true) {
		var scalingStats:Map<String, Float> = [];
		switch random.randomInt(0, 2) {
			case 0:
				scalingStats["Attack"] = 0.3;
			case 1:
				scalingStats["Defense"] = 0.3;
			case 2:
				scalingStats["Speed"] = 0.1;
		}

		var itemB:ItemBase = {
			type: 2,
			statMultipliers: null,
			scalingStats: scalingStats,
			name: null
		};
		if (wdata.skillSets == null)
			wdata.skillSets = new Array<SkillSet>();
		var skillSetPos = ArrayHelper.InsertOnEmpty(ss, wdata.skillSets);
		DropItem(itemB, -1, skillSetPos, enemyLevel, dropperReference, event);
	}

	public function ResetEquipToBaseLevel(equipment:Equipment, level:Int):Bool {
		var baseItem = equipment.generationBaseItem;
		if (baseItem >= 0) {
			var ib = itemBases[baseItem];
			if (ib != null) {
				for (key => value in ib.scalingStats) {
					equipment.attributes[key] = Std.int(value * level);
				}
				equipment.generationLevel = 1;
				return true;
			}
			return false;
		}
		return false;
	}

	public function DropItemOrSkillSet(itemDropProbability:Int, skillSetDropProbability:Int = 2, enemyLevel:Int, dropperReference = null) {
		var baseItem = -1;
		var itemB = null;

		if (random.randomInt(0, 1000) < skillSetDropProbability * 10) {
			var skillPosArray:Array<Int> = [];
			var baseLevel = 1;
			var maxLevel = 1;
			var maxNSkills = 2;
			if (wdata.enemy.level > 5) {
				maxNSkills = 3;
			}
			if (wdata.enemy.level > 10) {
				maxLevel = 2;
			}
			if (wdata.enemy.level > 25) {
				maxNSkills = 4;
			}
			if (wdata.enemy.level > 35) {
				maxLevel = 4;
			}
			var numberOfSkills = random.randomInt(1, maxNSkills);
			for (s in 0...numberOfSkills) {
				var skill = random.randomInt(0, skillBases.length - 1 - s);
				while (skillPosArray.contains(skill)) {
					skill++;
				}
				skillPosArray[s] = skill;
			}
			var ss:SkillSet = {skills: new Array<SkillUsable>()};
			for (j in 0...skillPosArray.length) {
				var level = baseLevel;
				level = random.randomInt(baseLevel, maxLevel);
				if (j >= 2) { // third skill always stronger
					level = maxLevel + 1;
				}
				if (j >= 3) { // fourth skill always stronger
					level = maxLevel + 2;
				}
				var sp = skillPosArray[j];
				ss.skills.push({
					id: skillBases[sp].id,
					level: level
				});
			}
			ForceSkillSetDrop(enemyLevel, dropperReference, ss);
			return;
		}

		if (random.randomInt(0, 100) < itemDropProbability) {
			baseItem = random.randomInt(0, itemBases.length - 1);
			itemB = itemBases[baseItem];
			DropItem(itemB, baseItem, -1, enemyLevel, dropperReference);
		}
	}

	public function DropItem(itemB:ItemBase, baseItem:Int, skillSetPos:Int, enemyLevel:Int, dropperReference = null, event = true) {
		var e:Equipment = null;
		var stat:Map<String, Int> = [];
		var statVar:Map<String, Int> = [];
		var mul:Map<String, Int> = [];
		var mulVar:Map<String, Int> = [];

		var minLevel = Std.int((enemyLevel + 1) / 2 - 3);
		if (minLevel < 1)
			minLevel = 1;
		var maxLevel = Std.int(enemyLevel / 2 + 2);
		var level = random.randomInt(minLevel, maxLevel);
		var prefixPos = -1;
		var prefixSeed = -1;
		var suffixPos = -1;
		var suffixSeed = -1;

		if (itemB.scalingStats != null)
			for (s in itemB.scalingStats.keyValueIterator()) {
				var vari = random.randomInt(80, 100);
				statVar[s.key] = vari;
				var value = s.value * vari * level;
				if (value < 100)
					value = 100;
				stat[s.key] = Std.int(value / 100);
			}
		if (itemB.statMultipliers != null)
			for (s in itemB.statMultipliers.keyValueIterator()) {
				var vari = random.randomInt(0, 100);
				mulVar[s.key] = vari;
				var min = s.value.min;
				var max = s.value.max;
				var range = max - min;
				mul[s.key] = Std.int(min + (range * vari) / 100);
			}
		if (random.randomInt(0, 100) < equipDropChance_Rare) {
			var modType = random.randomInt(0, 2);
			var prefixExist = modType == 0 || modType == 2;
			var suffixExist = modType == 1 || modType == 2;
			if (prefixExist) {
				prefixPos = random.randomInt(0, modBases.length - 1);
				prefixSeed = random.nextInt();
				AddMod(modBases[prefixPos], stat, mul, prefixSeed);
			}
			if (suffixExist) {
				suffixPos = random.randomInt(0, modBases.length - 1);
				suffixSeed = random.nextInt();
				AddMod(modBases[suffixPos], stat, mul, suffixSeed);
			}
		}
		for (m in mul.keyValueIterator()) {
			if (m.value % 5 != 0) {
				mul[m.key] = (Std.int((m.value + 4) / 5) * 5);
			}
		}
		var outsideSystem = new Map<String, Int>();

		if (wdata.equipLevels == null) {
			wdata.equipLevels = new Array<EquipmentLevel>();
		}

		if (skillSetPos >= 0) {
			outsideSystem["skillset"] = skillSetPos;
		}

		outsideSystem["level"] = ArrayHelper.InsertOnEmpty({
			level: 0,
			limitbreak: 0,
			ascension: 0
		}, wdata.equipLevels);

		e = {
			type: itemB.type,
			seen: 0,
			requiredAttributes: null,
			attributes: stat,
			generationVariations: statVar,
			generationLevel: level,
			generationBaseItem: baseItem,
			attributeMultiplier: mul,
			generationVariationsMultiplier: mulVar,
			generationSuffixMod: suffixPos,
			generationPrefixMod: prefixPos,
			generationSuffixModSeed: suffixSeed,
			generationPrefixModSeed: prefixSeed,
			outsideSystems: outsideSystem
		};

		var addedIndex = -1;
		for (i in 0...wdata.hero.equipment.length) {
			if (wdata.hero.equipment[i] == null) {
				wdata.hero.equipment[i] = e;
				addedIndex = i;
				break;
			}
		}
		if (addedIndex < 0) {
			wdata.hero.equipment.push(e);
			addedIndex = wdata.hero.equipment.length - 1;
		}

		if (event) {
			var e = AddEvent(EquipDrop);
			e.data = addedIndex;
			e.origin = dropperReference;
		}
	}

	public function AddBuff(buff:Buff, actor:Actor) {
		var addBuff = true;
		if (buff.debuff == true) {
			var debpro = actor.attributesCalculated["DebuffProtection"];
			if (debpro > 0) {
				if (random.randomInt(1, 100) < debpro) {
					AddEvent(DebuffBlock).origin = actor.reference;
					return;
				}
			}
		}
		for (bi in 0...actor.buffs.length) {
			var b = actor.buffs[bi];
			if (b.uniqueId == buff.uniqueId) {
				addBuff = false;
				if (b.strength < buff.strength) {
					actor.buffs[bi] = buff;
					break;
				}
				if (b.strength == buff.strength && b.duration < buff.duration) {
					actor.buffs[bi] = buff;
					break;
				}
			}
		}
		if (addBuff)
			actor.buffs.push(buff);
		RecalculateAttributes(actor);
	}

	public function GetSkillBase(id):Skill {
		for (s in skillBases) {
			if (s.id == id)
				return s;
		}
		return null;
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
			// wdata.necessaryToKillInArea = initialEnemyToKill * area;
			wdata.necessaryToKillInArea = initialEnemyToKill + Std.int((area - 1) * initialEnemyToKill * 0.3);
			if (wdata.necessaryToKillInArea > initialEnemyToKill * 14) {
				wdata.necessaryToKillInArea = initialEnemyToKill * 14;
			}
			var fRand = fixedRandom;
			fRand.seed = area + 1;
			if (area > 4) {
				var mul = fRand.random() * 1.5 + 0.5;
				wdata.necessaryToKillInArea = Std.int(wdata.necessaryToKillInArea * mul);
			}
			if (enemyAreaFromProcedural != null && wdata.battleAreaRegion == 0) {
				var eAI = enemyAreaFromProcedural.GetEnemyAreaInformation(area - 1);
				if (eAI.nEnemies > 0) {
					wdata.necessaryToKillInArea = eAI.nEnemies;
				}
			}

			if (wdata.battleAreaRegion > 0)
				wdata.necessaryToKillInArea = 3;

			if (PlayerFightMode()) {
				CreateAreaEnemy();
			}
		} else {
			wdata.enemy = null;
		}

		ResourceLogic.recalculateScalingResource(wdata.battleArea, areaBonus);

		dirty = true;
	}

	function PlayerFightMode() {
		return wdata.recovering != true && wdata.sleeping != true;
	}

	public function CalculateHeroMaxLevel():Int {
		return wdata.prestigeTimes * GetMaxLevelBonusOnPrestige() + 20;
	}

	function AwardXP(xpPlus) {
		if (wdata.hero.level < CalculateHeroMaxLevel()) {
			xpPlus = xpPlus + Std.int(xpPlus * wdata.prestigeTimes * GetXPBonusOnPrestige());
			wdata.hero.xp.value += xpPlus;
			var e = AddEvent(GetXP);
			e.data = xpPlus;
		}
	}

	public function GetMaxLevelBonusOnPrestige() {
		return 10;
	}

	public function GetXPBonusOnPrestige() {
		return 0.5;
	}

	public function GetLevelRequirementForPrestige():Int {
		return CalculateHeroMaxLevel() - 10;
	}

	public function CreateEnemy(region:Int, area:Int):Actor {
		var enemyLevel = area;

		var sheet = this.enemySheets[region];

		var enemy:Actor;

		if (region > 0) {
			var oldLevel = enemyLevel;
			enemyLevel = 0;
			for (i in 0...oldLevel) {
				enemyLevel += 10;
				enemyLevel += (i) * 10;
			}
			// enemyLevel = (enemyLevel + 1) * 10 - 1;
		}

		var equipment:Equipment = null;

		if (region == 0 && enemyAreaFromProcedural != null && enemyAreaFromProcedural.units != null) {
			var areaInfo = enemyAreaFromProcedural.GetEnemyAreaInformation(area - 1);
			sheet = areaInfo.sheet;
			enemyLevel += areaInfo.level;
			equipment = areaInfo.equipment;
		}

		{
			var timeToKillEnemy = balancing.timeToKillFirstEnemy;

			var initialAttackHero = 1; // may have to put this somewhere...
			var heroAttackTime = timePeriod * 2;
			var heroDPS = initialAttackHero / heroAttackTime;

			var initialLifeEnemy = Std.int(heroDPS * timeToKillEnemy);

			var enemyLife = initialLifeEnemy + (enemyLevel - 1) * (initialLifeEnemy);
			var enemyAttack = 1 + (enemyLevel - 1) * 1;

			var stats2 = [
				"Attack" => enemyAttack,
				"Life" => enemyLife,
				"LifeMax" => enemyLife,
				"Speed" => 20,
				"SpeedCount" => 0,
				"Defense" => 0,
				"MagicDefense" => 0,
				"Piercing" => 0
			];
			enemy = {
				level: 1 + enemyLevel,
				attributesBase: stats2,
				equipment: [],
				xp: null,
				attributesCalculated: stats2,
				reference: new ActorReference(1, 0),
				buffs: [],
				usableSkills: []
			};
			if (equipment != null) {
				enemy.equipment.push(equipment);
				enemy.equipmentSets = [
					{
						equipmentSlots: [0]
					}
				];
				enemy.chosenEquipSet = 0;
			}
			if (sheet != null) {
				var mul = sheet.speciesMultiplier;
				if (mul != null) {
					for (p in mul.attributesBase.keyValueIterator()) {
						var mul = p.value;
						var value = Std.int(enemy.attributesBase[p.key] * mul);
						enemy.attributesBase[p.key] = value;
						enemy.attributesCalculated[p.key] = value;
					}
				}
				if (sheet.speciesAdd != null)
					for (p in sheet.speciesAdd.keyValueIterator()) {
						var add = p.value;
						if (enemy.attributesBase.exists(p.key) == false) {
							enemy.attributesBase[p.key] = add;
							enemy.attributesCalculated[p.key] = add;
						} else {
							enemy.attributesBase[p.key] += add;
							enemy.attributesCalculated[p.key] += add;
						}
					}
				if (sheet.speciesLevelStats != null)
					for (p in sheet.speciesLevelStats.attributesBase.keyValueIterator()) {
						var addLevel = p.value;
						var value = Std.int(enemy.attributesBase[p.key] + addLevel * enemyLevel);
						enemy.attributesBase[p.key] = value;
						enemy.attributesCalculated[p.key] = value;
					}
				if (sheet.initialBuff != null) {
					AddBuff(sheet.initialBuff, enemy);
				}
			}
			RecalculateAttributes(enemy);
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];

			// trace('Enemy speed ' + wdata.enemy.attributesCalculated["Speed"]);
		}
		return enemy;
	}

	// createEnemy
	function CreateAreaEnemy() {
		wdata.enemy = CreateEnemy(wdata.battleAreaRegion, wdata.battleArea);
		return;

		// DELETE THIS TODO
		var region = wdata.battleAreaRegion;
		var enemyLevel = wdata.battleArea;
		var sheet = this.enemySheets[region];

		if (region > 0) {
			var oldLevel = enemyLevel;
			enemyLevel = 0;
			for (i in 0...oldLevel) {
				enemyLevel += 10;
				enemyLevel += (i) * 10;
			}
			// enemyLevel = (enemyLevel + 1) * 10 - 1;
		}

		var equipment:Equipment = null;

		if (region == 0 && enemyAreaFromProcedural != null && enemyAreaFromProcedural.units != null) {
			var areaInfo = enemyAreaFromProcedural.GetEnemyAreaInformation(wdata.battleArea - 1);
			sheet = areaInfo.sheet;
			enemyLevel += areaInfo.level;
			equipment = areaInfo.equipment;
		}

		{
			var timeToKillEnemy = balancing.timeToKillFirstEnemy;

			var initialAttackHero = 1; // may have to put this somewhere...
			var heroAttackTime = timePeriod * 2;
			var heroDPS = initialAttackHero / heroAttackTime;

			var initialLifeEnemy = Std.int(heroDPS * timeToKillEnemy);

			var enemyLife = initialLifeEnemy + (enemyLevel - 1) * (initialLifeEnemy);
			var enemyAttack = 1 + (enemyLevel - 1) * 1;

			var stats2 = [
				"Attack" => enemyAttack,
				"Life" => enemyLife,
				"LifeMax" => enemyLife,
				"Speed" => 20,
				"SpeedCount" => 0,
				"Defense" => 0,
				"MagicDefense" => 0,
				"Piercing" => 0
			];
			wdata.enemy = {
				level: 1 + enemyLevel,
				attributesBase: stats2,
				equipment: [],
				xp: null,
				attributesCalculated: stats2,
				reference: new ActorReference(1, 0),
				buffs: [],
				usableSkills: []
			};
			if (equipment != null) {
				wdata.enemy.equipment.push(equipment);
				wdata.enemy.equipmentSets = [
					{
						equipmentSlots: [0]
					}
				];
				wdata.enemy.chosenEquipSet = 0;
			}
			if (sheet != null) {
				var mul = sheet.speciesMultiplier;
				if (mul != null) {
					for (p in mul.attributesBase.keyValueIterator()) {
						var mul = p.value;
						var value = Std.int(wdata.enemy.attributesBase[p.key] * mul);
						wdata.enemy.attributesBase[p.key] = value;
						wdata.enemy.attributesCalculated[p.key] = value;
					}
				}
				if (sheet.speciesAdd != null)
					for (p in sheet.speciesAdd.keyValueIterator()) {
						var add = p.value;
						if (wdata.enemy.attributesBase.exists(p.key) == false) {
							wdata.enemy.attributesBase[p.key] = add;
							wdata.enemy.attributesCalculated[p.key] = add;
						} else {
							wdata.enemy.attributesBase[p.key] += add;
							wdata.enemy.attributesCalculated[p.key] += add;
						}
					}
				if (sheet.speciesLevelStats != null)
					for (p in sheet.speciesLevelStats.attributesBase.keyValueIterator()) {
						var addLevel = p.value;
						var value = Std.int(wdata.enemy.attributesBase[p.key] + addLevel * enemyLevel);
						wdata.enemy.attributesBase[p.key] = value;
						wdata.enemy.attributesCalculated[p.key] = value;
					}
				if (sheet.initialBuff != null) {
					AddBuff(sheet.initialBuff, wdata.enemy);
				}
			}
			RecalculateAttributes(wdata.enemy);
			wdata.enemy.attributesCalculated["Life"] = wdata.enemy.attributesCalculated["LifeMax"];

			// trace('Enemy speed ' + wdata.enemy.attributesCalculated["Speed"]);
		}
	}

	public function new() {
		balancing = {
			timeToKillFirstEnemy: 5,
			timeForFirstAreaProgress: 20,
			timeForFirstLevelUpGrind: 90,
			areaBonusXPPercentOfFirstLevelUp: 60
		};

		var bm = this;
		// goblin
		bm.enemySheets.push({speciesMultiplier: null, speciesLevelStats: null, speciesAdd: null});
		// wolf
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 0.55, "Speed" => 3.3, "LifeMax" => 1.6]
			},
			speciesAdd: null,
			speciesLevelStats: {attributesBase: ["Speed" => 1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Speed" => 2, "LifeMax" => 3]});
		// Tonberry
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 4, "Speed" => 0.09, "LifeMax" => 4]
			},
			speciesAdd: null,
			speciesLevelStats: {attributesBase: ["Speed" => 0.05, "Defense" => 0.4]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Attack" => 2, "LifeMax" => 5]});
		// Turtle
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.4, "Speed" => 0.15, "LifeMax" => 5.5]
			},
			speciesAdd: ["Defense" => 5],
			speciesLevelStats: {attributesBase: ["Defense" => 1, "Speed" => 0.05]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Defense" => 1, "LifeMax" => 8]});
		// Cactuar
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.4, "Speed" => 1.1, "LifeMax" => 1.7]
			},
			speciesAdd: ["Piercing" => 100],
			speciesLevelStats: {attributesBase: ["Defense" => 0.2, "Speed" => 0.1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Attack" => 1, "Speed" => 1, "LifeMax" => 3]});

		// Reaper
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 10, "Speed" => 3.5, "LifeMax" => 0.1]
			},
			speciesAdd: null,
			speciesLevelStats: {attributesBase: ["Defense" => 0.2, "Speed" => 0.1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Attack" => 3, "Speed" => 2]});

		// Antibuffer
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 0.5, "Speed" => 2.9, "LifeMax" => 2, "Defense" => 0.3]
			},
			speciesAdd: ["Antibuff" => 1],
			speciesLevelStats: {attributesBase: ["Defense" => 0.2, "Speed" => 0.1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Speed" => 2, "LifeMax" => 3]});

		// Buffed
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1, "Speed" => 0.8, "LifeMax" => 2, "Defense" => 0.4]
			},
			speciesAdd: null,
			initialBuff: {
				uniqueId: "Power Up",
				mulStats: ["Attack" => 800, "Defense" => 800],
				duration: 3,
				addStats: null,
				strength: 100
			},
			speciesLevelStats: {attributesBase: ["Defense" => 0.2, "Speed" => 0.1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Attack" => 2, "LifeMax" => 3]});

		// Debuff immunity
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.8, "Speed" => 1.4, "LifeMax" => 2, "Defense" => 0.5]
			},
			speciesAdd: ["DebuffProtection" => 100],
			speciesLevelStats: {attributesBase: ["Defense" => 0.2, "Speed" => 0.1]}
		});
		bm.regionPrizes.push({xpPrize: false, statBonus: ["Attack" => 1, "Defense" => 1, "LifeMax" => 3]});

		bm.regionRequirements = [0, 5, 9, 14, 18, 22, 30, 42, 50];

		if (bm.regionPrizes.length > bm.regionRequirements.length) {
			trace("PROBLEM: Tell developer to add more region requirements!!!");
		}

		// Goblin
		enemyAreaFromProcedural.enemySheets.push({speciesMultiplier: null, speciesLevelStats: null, speciesAdd: null});
		enemyAreaFromProcedural.equipments.push(null);
		// Dog
		enemyAreaFromProcedural.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 0.6, "Speed" => 1.3, "LifeMax" => 0.85]
			},
			speciesAdd: null,
			speciesLevelStats: {attributesBase: ["Speed" => 0.6]}
		});
		enemyAreaFromProcedural.equipments.push(null);
		// Giant
		enemyAreaFromProcedural.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.8, "Speed" => 0.3, "LifeMax" => 1.2]
			},
			speciesAdd: null,
			speciesLevelStats: {attributesBase: ["Speed" => 0.05, "Defense" => 0.05]}
		});
		enemyAreaFromProcedural.equipments.push(null);
		// Turtle
		enemyAreaFromProcedural.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 0.9, "Speed" => 0.5, "LifeMax" => 1.3]
			},
			speciesAdd: ["Defense" => 1],
			speciesLevelStats: {attributesBase: ["Defense" => 0.1, "Speed" => 0]}
		});
		enemyAreaFromProcedural.equipments.push(null);

		// all enemies in combination
		enemyAreaFromProcedural.equipments.push(null);

		// fire area
		enemyAreaFromProcedural.equipments.push({
			type: 0,
			seen: 2,
			requiredAttributes: null,
			attributes: ["thunder-damage" => 250, "fire-damage" => 30]
		});

		// ice area
		enemyAreaFromProcedural.equipments.push({
			type: 0,
			seen: 2,
			requiredAttributes: null,
			attributes: ["fire-damage" => 250, "ice-damage" => 30]
		});

		// thunder area
		enemyAreaFromProcedural.equipments.push({
			type: 0,
			seen: 2,
			requiredAttributes: null,
			attributes: ["ice-damage" => 250, "thunder-damage" => 30]
		});

		var pus:Array<ProceduralUnit> = [];
		{
			var pu = new ProceduralUnit();
			pu.characteristics.push(0);
			pu.characteristics.push(0);
			pu.repeat = 0;
			pus.push(pu);
		}
		{
			var pu = new ProceduralUnit();
			pu.characteristics.push(1);
			pu.characteristics.push(0);
			pu.repeat = 0;
			pus.push(pu);
		}
		pus = Generation.Generate("w1", 8, 1, 3, pus, [0, 1]);
		var purs = Generation.GenerateRepetitions("w1", pus, {min: 3, max: 6});
		enemyAreaFromProcedural.units = purs;

		var stats = ["Attack" => 1, "Life" => 20, "LifeMax" => 20, "Speed" => 20, "SpeedCount" => 0];

		var w:WorldData = {
			worldVersion: 1501,
			hero: {
				level: 1,
				attributesBase: null,
				equipment: null,
				xp: null,
				attributesCalculated: stats,
				reference: new ActorReference(0, 0),
			},
			enemy: null,

			maxArea: 1,
			necessaryToKillInArea: 0,
			killedInArea: [0, 0],
			prestigeTimes: 0,

			timeCount: 0,
			playerTimesKilled: 0,
			battleArea: 0,
			battleAreaRegion: 0,
			battleAreaRegionMax: 1,
			playerActions: new Map<String, PlayerAction>(),
			recovering: false,
			sleeping: false,
			regionProgress: []
		};

		wdata = w;

		ReinitGameValues();
		ChangeBattleArea(0);
		wdata.hero.attributesCalculated["Life"] = wdata.hero.attributesCalculated["LifeMax"];
	}

	public static function IsLimitBreakable(e:Equipment, wdata:WorldData):Bool {
		var level = wdata.equipLevels[e.outsideSystems["level"]];
		return level.limitbreak < 3;
	}

	public static function IsUpgradable(e:Equipment, wdata:WorldData):Bool {
		var level = wdata.equipLevels[e.outsideSystems["level"]];
		var maxLevel = level.limitbreak * 3 + 3;
		var upgradable = level.level < maxLevel;

		return upgradable;
	}

	public static function GetLimitBreakCost(e, wdata):Int {
		return Std.int((GetCost(e, wdata) + 1) / 5) * 3;
	}

	public static function GetSellPrize(e:Equipment, wdata:WorldData):Int {
		return Std.int(GetCost(e, wdata) / 5);
	}

	public static function GetCost(e:Equipment, wdata:WorldData):Int {
		var genLevel:Float = 1;
		if (e.generationLevel >= 0) {
			genLevel = e.generationLevel;
		}

		// increases cost to upgrade every 5 levels, by 5. So 5, 10, 15, 20, etc
		if (e.generationPrefixMod >= 0) {
			// genLevel *= 1.5;
			genLevel += 5;
		}
		if (e.generationSuffixMod >= 0) {
			// genLevel *= 1.5;
			genLevel += 5;
		}

		return Std.int(genLevel / 5) * 5 + 5;
	}

	public static function CanUpgrade(e:Equipment, wdata:WorldData):Bool {
		if (IsUpgradable(e, wdata) == false)
			return false;

		return (GetCost(e, wdata) <= wdata.currency.currencies["Lagrima"].value);
	}

	public static function CanLimitBreak(e:Equipment, wdata:WorldData):Bool {
		if (IsLimitBreakable(e, wdata) == false)
			return false;

		return (GetLimitBreakCost(e, wdata) <= wdata.currency.currencies["Lagrima Stone"].value);
	}

	public static function LimitBreak(e:Equipment, wdata:WorldData) {
		var cost = GetLimitBreakCost(e, wdata);
		wdata.currency.currencies["Lagrima Stone"].value -= cost;
		var level = wdata.equipLevels[e.outsideSystems["level"]];
		level.limitbreak++;
	}

	public static function Upgrade(e:Equipment, wdata:WorldData, bm:BattleManager) {
		var cost = GetCost(e, wdata);
		wdata.currency.currencies["Lagrima"].value -= cost;
		var level = wdata.equipLevels[e.outsideSystems["level"]];
		level.level++;

		// reached max level
		if (IsUpgradable(e, wdata) == false) {
			var bonus = Std.int(GetLimitBreakCost(e, wdata) / 3);
			wdata.currency.currencies["Lagrima Stone"].value += bonus;
			var e = bm.AddEvent(EquipMaxed);
			e.data = bonus;
			e.dataString = "Lagrima Stone";
		}
		{
			if (e.attributes.exists("Attack")) {
				e.attributes["Attack"]++;
			}
			if (e.attributes.exists("MagicAttack")) {
				e.attributes["MagicAttack"]++;
			}

			if (e.type == 1) {
				if (e.attributes["LifeMax"] >= 0 == false) {
					e.attributes["LifeMax"] = 0;
				}
				e.attributes["LifeMax"] += 2;
			}

			if (level.level % 3 != 0) {
				if (e.attributes.exists("Defense")) {
					e.attributes["Defense"]++;
				}
				if (e.attributes.exists("MagicDefense")) {
					e.attributes["MagicDefense"]++;
				}
			}
		}
	}

	// currently everything gets saved, even stuff that shouldn't
	// This method will reinit some of those values when loading or creating a new game
	public function ReinitGameValues() {
		if (wdata.currency == null)
			wdata.currency = {
				currencies: [
					"Lagrima" => {
						value: 0,
						visible: false
					},
					"Lagrima Stone" => {
						value: 0,
						visible: false
					}
				]
			};

		if (wdata.hero.equipmentSets == null) {
			wdata.hero.equipmentSets = new Array<EquipmentSet>();
			wdata.hero.chosenEquipSet = 0;
		}

		while (wdata.hero.equipmentSets.length < 5) {
			wdata.hero.equipmentSets.push({
				equipmentSlots: [-1, -1, -1]
			});
		}

		if (wdata.hero.equipment != null) {
			while (wdata.hero.equipment.contains(null)) {
				DiscardSingleEquipment(wdata.hero.equipment.indexOf(null));
			}
			for (index => value in wdata.hero.equipment) {
				if (value.outsideSystems == null) {
					value.outsideSystems = new Map<String, Int>();
				}
				if (wdata.equipLevels == null)
					wdata.equipLevels = new Array<EquipmentLevel>();
				if (value.outsideSystems.exists("level") == false) {
					var index = ArrayHelper.InsertOnEmpty({
						level: 0,
						limitbreak: 0,
						ascension: 0
					}, wdata.equipLevels);
					value.outsideSystems["level"] = index;
				}
			}
		}

		if (wdata.regionProgress == null) {
			wdata.regionProgress = [];
		}
		for (i in 0...wdata.regionProgress.length) {
			CheckRegionNull(i);
			var r = wdata.regionProgress[i];
			if (r.maxAreaOnPrestigeRecord == null)
				r.maxAreaOnPrestigeRecord = [];
		}

		if (wdata.battleAreaRegionMax >= 1 == false) {
			wdata.battleAreaRegionMax = 1;
		}
		if (wdata.prestigeTimes >= 0 == false)
			wdata.prestigeTimes = 0;

		if (wdata.hero.buffs != null == false) {
			wdata.hero.buffs = new Array<Buff>();
		}

		if (wdata.hero.usableSkills != null == false) {
			wdata.hero.usableSkills = new Array<SkillUsable>();
		}

		if (wdata.enemy != null)
			if (wdata.enemy.buffs != null == false)
				wdata.enemy.buffs = new Array<Buff>();

		var addAction = (id:String, action:PlayerAction, callback:PlayerAction->Void) -> {
			// only if action isn't already defined
			var w = wdata;
			if (wdata.playerActions.exists(id) == false) {
				wdata.playerActions[id] = action;
				if (callback != null)
					playerActions[id] = {actionData: w.playerActions[id], actualAction: callback}
			}
		}

		var createAction = () -> {
			var a:PlayerAction;
			a = {
				visible: false,
				enabled: false,
				mode: 0,
				timesUsed: 0
			};
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

		addAction("advance", {
			visible: true,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, null);

		addAction("retreat", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, null);
		addAction("levelup", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, null);
		addAction("tabequipment", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, null);
		addAction("tabmemory", {
			visible: false,
			enabled: false,
			timesUsed: 0,
			mode: 0
		}, null);

		addAction("repeat", createAction(), (a) -> {
			wdata.killedInArea[wdata.battleArea] = 0;
		});

		addAction("prestige", createAction(), (a) -> {
			PrestigeExecute();
		});

		for (i in 0...7) {
			var buttonId = i;
			addAction("battleaction_" + i, createAction(), struct -> {
				var skill = wdata.hero.usableSkills[i];
				UseSkill(skill, wdata.hero);
			});
		}

		wdata.hero.attributesBase = [
			"Life" => 20, "LifeMax" => 20, "Speed" => 20, "SpeedCount" => 0, "Attack" => 1, "Defense" => 0, "MagicAttack" => 1, "MagicDefense" => 0,
			"Piercing" => 0, "Regen" => 0, "enchant-fire" => 0, "MP" => 0, "MPMax" => 100, "MPRecharge" => 100, "MPRechargeCount" => 10000
		];

		var valueXP = 0;
		if (wdata.hero.xp != null) {
			valueXP = wdata.hero.xp.value;
		}

		var timeLevelUpGrind = balancing.timeForFirstLevelUpGrind;
		var initialEnemyXP = 2; // this might need to be in balancing
		var initialXPToLevelUp = Std.int(balancing.timeForFirstLevelUpGrind * initialEnemyXP / balancing.timeToKillFirstEnemy);

		wdata.hero.xp = ResourceLogic.getExponentialResource(1.2, 1, initialXPToLevelUp);
		wdata.hero.xp.value = valueXP;

		ResourceLogic.recalculateScalingResource(wdata.hero.level, wdata.hero.xp);

		areaBonus = ResourceLogic.getExponentialResource(1.2, 1, Std.int(initialXPToLevelUp * balancing.areaBonusXPPercentOfFirstLevelUp / 100));

		if (wdata.hero.equipment == null) {
			wdata.hero.equipment = [];
		}
		if (wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots == null) {
			wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots = [-1, -1, -1];
		}
		RecalculateAttributes(wdata.hero);
	}

	public function PrestigeExecute() {
		wdata.enemy = null;
		wdata.hero.level = 1;
		wdata.hero.xp.value = 0;
		var hero = wdata.hero;
		ResourceLogic.recalculateScalingResource(hero.level, hero.xp);
		for (i in 0...wdata.regionProgress.length) {
			wdata.regionProgress[i].maxAreaOnPrestigeRecord.push(wdata.regionProgress[i].maxArea);
			wdata.regionProgress[i].area = 0;
			wdata.regionProgress[i].maxArea = 1;
			wdata.regionProgress[i].amountEnemyKilledInArea = 0;
			wdata.killedInArea = [0];
		}
		wdata.battleAreaRegion = 0;
		wdata.battleArea = 0;
		wdata.maxArea = 1;
		wdata.battleAreaRegionMax = 1;
		wdata.prestigeTimes++;
		RecalculateAttributes(wdata.hero);
		for (i in 0...wdata.hero.equipment.length) {
			var equipKept = false;
			for (j in 0...wdata.hero.equipmentSets.length) {
				if (wdata.hero.equipmentSets[j].equipmentSlots.contains(i)) {
					var e = wdata.hero.equipment[i];
					if (e != null) {
						var reset = ResetEquipToBaseLevel(e, 1);
						if (reset == false) {
							// base item-less items will not get reset

							/* 
								for (s in e.attributes.keys()) {
									e.attributes[s] = Std.int(e.attributes[s] * 0.2);
								}
							 */
						}
						if (e.outsideSystems.exists("level")) {
							var levelId = e.outsideSystems["level"];
							if (levelId >= 0) {
								var el = wdata.equipLevels[levelId];
								el.ascension = 0;
								el.level = 0;
								el.limitbreak = 0;
							}
						}
					}
					equipKept = true;
					break;
				}
			}

			if (equipKept == false) {
				wdata.hero.equipment[i] = null;
			}
		}
	}

	public function CheckRegionNull(region) {
		if (wdata.regionProgress[region] == null)
			wdata.regionProgress[region] = {
				area: 0,
				maxArea: 1,
				amountEnemyKilledInArea: 0,
				maxAreaRecord: 1,
				maxAreaOnPrestigeRecord: []
			}
	}

	public function changeRegion(region) {
		wdata.battleAreaRegion = region;
		CheckRegionNull(region);
		ChangeBattleArea(wdata.regionProgress[region].area);
		// wdata.battleArea = wdata.regionProgress[region].area;
		wdata.maxArea = wdata.regionProgress[region].maxArea;
		wdata.killedInArea[wdata.battleArea] = wdata.regionProgress[region].amountEnemyKilledInArea;
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

				CreateAreaEnemy();
				// c = Sys.getChar(true);
			}
		}

		if (PlayerFightMode() == false || enemy == null) {
			attackHappen = false;
			var chargeMultiplier = 3;
			var max = 99999;
			var restMultiplier = 1;

			// do not do MP for now
			for (i in 0...1) {
				var valueK = "Life";
				var valueMaxK = "LifeMax";

				// WARNING: old legacy code, not happening now
				if (i == 1) {
					valueK = "MP";
					valueMaxK = "MPMax";
				}
				if (i == 2) {
					valueK = "MPRechargeCount";
					valueMaxK = null;
					max = 10000;
					restMultiplier = 500;
				}
				var value = wdata.hero.attributesCalculated[valueK];

				if (valueMaxK != null)
					max = wdata.hero.attributesCalculated[valueMaxK];

				// value += 2 * restMultiplier;
				value += Std.int(max * 0.05);
				if (wdata.sleeping) {
					value += Std.int(max * 0.3);
				}
				if (value > max)
					value = max;
				wdata.hero.attributesCalculated[valueK] = value;
			}
		}
		for (i in 0...2) {
			var actor = wdata.hero;
			if (i == 1)
				actor = wdata.enemy;
			if (actor == null)
				continue;
			{
				var regen = actor.attributesCalculated["Regen"];
				if (regen > 0) {
					var recovery = regen * actor.attributesCalculated["LifeMax"] / 100;
					if (recovery < 1)
						recovery = 1;
					actor.attributesCalculated["Life"] += Std.int(recovery);
				}
			}
			if (actor.attributesCalculated["Life"] > actor.attributesCalculated["LifeMax"]) {
				actor.attributesCalculated["Life"] = actor.attributesCalculated["LifeMax"];
			}
		}
		// c = Sys.getChar(true);
		if (attackHappen) {
			// var which = 0;
			var attacker:Actor = null;
			var defender:Actor = null;
			// Decide attacker and defender
			{
				var decided = false;
				attacker = hero;
				defender = enemy;
				for (i in 0...100) { // should be a while(true) but just to be safer
					for (battleActor in 0...2) {
						var bActor = hero;
						if (battleActor == 1)
							bActor = enemy;
						bActor.attributesCalculated["SpeedCount"] += bActor.attributesCalculated["Speed"];
						var sc = bActor.attributesCalculated["SpeedCount"];
						// trace('$battleActor speed count $sc');
						if (decided == false) {
							if (bActor.attributesCalculated["SpeedCount"] > 1000) {
								bActor.attributesCalculated["SpeedCount"] = bActor.attributesCalculated["SpeedCount"] - 1000;
								if (battleActor == 1) {
									attacker = enemy;
									defender = hero;
								}
								decided = true;
							}
						}
					}
					if (decided)
						break;
				}
			}

			if (attacker == wdata.hero && scheduledSkill != null) {
				UseSkill(scheduledSkill, attacker, true);
				scheduledSkill = null;
			} else {
				AttackExecute(attacker, defender);
			}
			if (attacker.turnRecharge != null) {
				for (i in 0...attacker.turnRecharge.length) {
					if (attacker.turnRecharge[i] > 0)
						attacker.turnRecharge[i]--;
				}
			}

			for (b in 0...attacker.buffs.length) {
				var bu = attacker.buffs[b];
				if (attacker.buffs[b] != null) {
					bu.duration -= 1;
				}
			}
			CheckRemoveMod(attacker);
			CheckRemoveMod(defender);
		} else {
			if (wdata.hero.turnRecharge != null)
				wdata.hero.turnRecharge.resize(0);
		}

		return "";
	}

	public function CheckRemoveMod(actor:Actor) {
		var attackerBuffChanged = false;
		for (b in 0...actor.buffs.length) {
			var bu = actor.buffs[b];
			if (bu.duration <= 0) {
				attackerBuffChanged = true;
				actor.buffs[b] = null;
			}
		}
		while (actor.buffs.remove(null)) {};
		if (attackerBuffChanged)
			RecalculateAttributes(actor);
	}

	public function AddMod(modBase:ModBase, statAdd:Map<String, Int>, statMul:Map<String, Int>, seed) {
		var mulAdd = modBase.statMultipliers;
		var rand = fixedRandom;
		rand.seed = seed;
		if (mulAdd != null)
			for (m in mulAdd.keyValueIterator()) {
				var val = rand.Range(mulAdd[m.key]);
				if (statMul.exists(m.key)) {
					statMul[m.key] = Std.int(statMul[m.key] * val / 100);
				} else {
					statMul[m.key] = val;
				}
			}
		if (modBase.statAdds != null)
			for (m in modBase.statAdds.keyValueIterator()) {
				var val = rand.Range(modBase.statAdds[m.key]);
				if (statAdd.exists(m.key)) {
					statAdd[m.key] = Std.int(statAdd[m.key] + val);
				} else {
					statAdd[m.key] = val;
				}
			}
	}

	public function LimitBreakEquipment(pos) {
		var e = wdata.hero.equipment[pos];
		BattleManager.LimitBreak(e, wdata);
	}

	public function ChangeEquipmentSet(pos) {
		wdata.hero.chosenEquipSet = pos;
		RecalculateAttributes(wdata.hero);
	}

	public function UpgradeOrLimitBreakEquipment(pos) {
		var e = wdata.hero.equipment[pos];
		if (IsUpgradable(e, wdata)) {
			BattleManager.Upgrade(e, wdata, this);
		} else {
			BattleManager.LimitBreak(e, wdata);
		}

		RecalculateAttributes(wdata.hero);
	}

	function DiscardSingleEquipment(pos) {
		var e = wdata.hero.equipment[pos];
		wdata.hero.equipment.remove(e);
		for (j in 0...wdata.hero.equipmentSets.length) {
			for (i in 0...wdata.hero.equipmentSets[j].equipmentSlots.length) {
				if (wdata.hero.equipmentSets[j].equipmentSlots[i] >= pos) {
					wdata.hero.equipmentSets[j].equipmentSlots[i]--; // adjust position of higher slots
				}
			}
		}

		if (e != null)
			equipmentToDiscard.push(e);
	}

	public function SellSingleEquipment(pos) {
		var prize = GetSellPrize(wdata.hero.equipment[pos], wdata);
		DiscardSingleEquipment(pos);
		wdata.currency.currencies["Lagrima"].value += prize;
	}

	public function SellEquipment(pos) {
		SellSingleEquipment(pos);
		RecalculateAttributes(wdata.hero);
	}

	public function ToggleEquipped(pos) {
		var slot = wdata.hero.equipment[pos].type;
		if (wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots[slot] == pos) {
			wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots[slot] = -1;
		} else {
			wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots[slot] = pos;
		}
		// UseMP(wdata.hero, 9999, false);
		RecalculateAttributes(wdata.hero);
	}

	public function IsEquipped(pos, anySet = true):Bool {
		if (anySet) {
			for (i in 0...wdata.hero.equipmentSets.length) {
				if (wdata.hero.equipmentSets[i].equipmentSlots.contains(pos)) {
					return true;
				}
			}
			return false;
		} else {
			return wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots.contains(pos);
		}
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

		for (e in equipmentToDiscard) {
			if (e.outsideSystems != null) {
				if (e.outsideSystems.exists("skillset")) {
					var skillsetpos = e.outsideSystems["skillset"];
					wdata.skillSets[skillsetpos] = null;
				}
				if (e.outsideSystems.exists("level")) {
					var level = e.outsideSystems["level"];
					wdata.equipLevels[level] = null;
				}
			}
		}
		equipmentToDiscard.resize(0);

		if (wdata.regionProgress == null) {
			wdata.regionProgress = [];
		}
		while (wdata.regionProgress.length <= wdata.battleAreaRegion) {
			wdata.regionProgress.push({
				area: -1,
				maxArea: -1,
				amountEnemyKilledInArea: -1,
				maxAreaRecord: -1,
				maxAreaOnPrestigeRecord: []
			});
		}
		wdata.regionProgress[wdata.battleAreaRegion].area = wdata.battleArea;
		var recalculate = false;
		if (wdata.regionProgress[wdata.battleAreaRegion].maxArea != wdata.maxArea) {
			recalculate = true;
			wdata.regionProgress[wdata.battleAreaRegion].maxArea = wdata.maxArea;
		}

		for (rp in wdata.regionProgress) {
			if (rp != null)
				if (rp.maxArea > rp.maxAreaRecord) {
					rp.maxAreaRecord = rp.maxArea;
					recalculate = true;
				}
		}

		if (recalculate)
			RecalculateAttributes(wdata.hero);
		wdata.regionProgress[wdata.battleAreaRegion].amountEnemyKilledInArea = wdata.killedInArea[wdata.battleArea];

		// region unlock code ---------------
		if (regionRequirements.length >= wdata.battleAreaRegionMax) {
			var maxArea = wdata.regionProgress[0].maxArea;
			if (maxArea > regionRequirements[wdata.battleAreaRegionMax]) {
				wdata.battleAreaRegionMax++;
				this.AddEvent(RegionUnlock).data = wdata.battleAreaRegionMax - 1;
			}
		}
		//-----------------------------------

		canAdvance = wdata.battleArea < wdata.maxArea;
		canRetreat = wdata.battleArea > 0;
		canLevelUp = wdata.hero.xp.value >= wdata.hero.xp.calculatedMax && wdata.hero.level < CalculateHeroMaxLevel();
		var hasEquipment = wdata.hero.equipment.length > 1; // to account for initial skill set

		{
			var lu = wdata.playerActions["tabequipment"];
			lu.enabled = hasEquipment;
			lu.visible = lu.enabled || lu.visible;
		}

		{
			var lu = wdata.playerActions["levelup"];
			lu.enabled = canLevelUp;
			lu.visible = canLevelUp || lu.visible;
		}
		{
			var lu = wdata.playerActions["prestige"];
			lu.enabled = wdata.hero.level >= GetLevelRequirementForPrestige();
			lu.visible = lu.enabled || lu.visible;
		}
		{
			for (i in 0...7) {
				var buttonId = i;
				var lu = wdata.playerActions["battleaction_" + i];
				var skillUsable = false;
				var skillVisible = false;
				var skillButtonMode = 0;
				if (wdata.hero.level >= skillSlotUnlocklevel[i]) {} else {
					skillButtonMode = 1;
				}
				if (wdata.hero.usableSkills[i] != null) {
					if (wdata.hero.level >= skillSlotUnlocklevel[i]) {
						if (wdata.hero.attributesCalculated["MPRechargeCount"] >= 10000) {
							skillUsable = true;
						}
					}

					if (i == 0 || wdata.hero.level >= skillSlotUnlocklevel[i - 1]) {
						skillVisible = true;
					}

					var sb = GetSkillBase(wdata.hero.usableSkills[i].id);

					if (sb.turnRecharge > 0) {
						if (wdata.hero.turnRecharge == null) {
							wdata.hero.turnRecharge = new Array<Int>();
						}
						if (wdata.hero.turnRecharge[i] > 0) {
							skillUsable = false;
						}
					}

					if (skillUsable && skillVisible // && wdata.killedInArea[wdata.battleArea] >= wdata.necessaryToKillInArea
						&& (wdata.enemy == null // || wdata.enemy.attributesCalculated["Life"] == 0
						)) {
							var efs = sb.effects;
							if (efs == null)
								efs = sb.activeEffect;
							for (e in efs) {
								if (e.target == ENEMY) {
									skillUsable = false;
									break;
								}
							}
					}
				}
				if (scheduledSkill != null) {
					skillUsable = false;
					if (scheduledSkill == wdata.hero.usableSkills[i]) {
						skillButtonMode = 2;
					}
				}
				lu.enabled = skillUsable;
				lu.visible = skillVisible;
				lu.mode = skillButtonMode;
			}
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
			if (wdata.sleeping == true) {
				lu.mode = 1;
				lu.enabled = true;
				// trace(lu.mode);
			} else {
				lu.mode = 0;
				// sleep is okay even when recovered for faster active play
				lu.enabled = wdata.hero.attributesCalculated["Life"] < wdata.hero.attributesCalculated["LifeMax"]
					&& wdata.recovering == false;
			}
			lu.visible = lu.enabled || lu.visible;
		}

		if (wdata.recovering && wdata.hero.attributesCalculated["Life"] >= wdata.hero.attributesCalculated["LifeMax"]) {
			wdata.hero.attributesCalculated["Life"] = wdata.hero.attributesCalculated["LifeMax"];
			wdata.recovering = false;
		}

		var mrc = wdata.hero.attributesCalculated["MPRechargeCount"];
		if (mrc < 10000) {
			mrc += Std.int(wdata.hero.attributesCalculated["MPRecharge"] * delta * 5);
			wdata.hero.attributesCalculated["MPRechargeCount"] = mrc;
			if (mrc >= 10000) {
				wdata.hero.attributesCalculated["MP"] = wdata.hero.attributesCalculated["MPMax"];
			}
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

		hero.attributesCalculated["Life"] = hero.attributesCalculated["LifeMax"];
		hero.attributesCalculated["MP"] = hero.attributesCalculated["MPMax"];
		hero.attributesCalculated["MPRechargeCount"] = 10000;
	}

	public function RecalculateAttributes(actor:Actor) {
		for (i in 0...volatileAttributeList.length) {
			volatileAttributeAux[i] = actor.attributesCalculated[volatileAttributeList[i]];
			if (volatileAttributeAux[i] >= 0 == false)
				volatileAttributeAux[i] = 0;
		}

		if (actor == wdata.hero) {
			var skillSetPos = wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots[2];
			if (skillSetPos >= 0) {
				var e = wdata.hero.equipment[skillSetPos];
				if (e != null && e.type == 2) {
					var skillSet = wdata.skillSets[e.outsideSystems["skillset"]];
					wdata.hero.usableSkills = skillSet.skills;
				}
			}
		}

		if (actor.attributesBase == actor.attributesCalculated) {
			actor.attributesCalculated = new Map<String, Int>();
		}
		actor.attributesCalculated.clear();

		if (actor == wdata.hero) {
			AttributeLogic.Add(actor.attributesBase, [
				"Attack" => 1, "LifeMax" => 5, "Life" => 5, "Speed" => 0, "Defense" => 0, "MagicAttack" => 1, "MagicDefense" => 0, "SpeedCount" => 0,
				"Piercing" => 0, "MPMax" => 2
			], actor.level, actor.attributesCalculated);
		} else {
			for (key => value in actor.attributesBase) {
				actor.attributesCalculated[key] = value;
			}
		}

		// var muls = new Map<String, Int>();

		if (actor == wdata.hero) {
			for (i in 0...wdata.regionProgress.length) {
				CheckRegionNull(i);
				var pro = wdata.regionProgress[i];
				var prize = regionPrizes[i];
				var bonusLevel = 0;

				if (prize.statBonus != null) {
					// should not use record because you are recording all prestige max areas
					if (pro.maxArea >= 2) {
						bonusLevel += pro.maxArea - 1;
					}
					for (maxAreaPrestiges in pro.maxAreaOnPrestigeRecord) {
						if (maxAreaPrestiges >= 2) {
							bonusLevel += maxAreaPrestiges - 1;
						}
					}
					AttributeLogic.Add(actor.attributesCalculated, prize.statBonus, bonusLevel, actor.attributesCalculated);
				}
			}
		}

		// first do adds
		if (actor.equipmentSets != null) {
			if (actor.equipmentSets[actor.chosenEquipSet].equipmentSlots != null) {
				for (es in actor.equipmentSets[actor.chosenEquipSet].equipmentSlots) {
					var e = actor.equipment[es];
					if (e != null) {
						AttributeLogic.Add(actor.attributesCalculated, e.attributes, 1, actor.attributesCalculated);
					}
				}
			}
		}
		for (b in actor.buffs) {
			if (b.addStats != null)
				AttributeLogic.Add(actor.attributesCalculated, b.addStats, 1, actor.attributesCalculated);
		}

		// then do multipliers
		if (actor.equipmentSets != null) {
			if (actor.equipmentSets[actor.chosenEquipSet].equipmentSlots != null) {
				for (es in actor.equipmentSets[actor.chosenEquipSet].equipmentSlots) {
					var e = actor.equipment[es];
					if (e != null) {
						if (e.attributeMultiplier != null) {
							for (a in e.attributeMultiplier.keyValueIterator()) {
								actor.attributesCalculated[a.key] = Std.int(actor.attributesCalculated[a.key] * a.value / 100);
							}
						}
					}
				}
			}
		}
		for (b in actor.buffs) {
			if (b.mulStats != null)
				for (a in b.mulStats.keyValueIterator()) {
					actor.attributesCalculated[a.key] = Std.int(actor.attributesCalculated[a.key] * a.value / 100);
				}
		}

		for (i in 0...volatileAttributeList.length) {
			actor.attributesCalculated[volatileAttributeList[i]] = volatileAttributeAux[i];
		}
	}

	public function AdvanceArea() {
		ChangeBattleArea(wdata.battleArea + 1);
	}

	public function DiscardWorseEquipment() {
		var i = 0;
		var times = 0;
		while (i < wdata.hero.equipment.length) {
			times++;
			if (times > 500) {
				trace("LOOP SCAPE");
				break;
			}
			var e = wdata.hero.equipment[i];
			if (e == null) {
				i++;
				continue;
			}
			if (e.type == 2) {
				i++;
				continue;
			}
			var j = i + 1;
			var times2 = 0;
			while (j < wdata.hero.equipment.length) {
				times2++;
				if (times2 > 500) {
					trace("LOOP SCAPE 2");
					break;
				}
				{
					var e2 = wdata.hero.equipment[j];
					if (e2 == null) {
						j++;
						continue;
					}
					if (e.type != e2.type) {
						j++;
						continue;
					}
					var r = CompareEquipmentStrength(e, e2);
					if (r == 1 || r == 0) { // if they are exactly the same or r1 is better
						if (wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots.contains(j)) {
							j++;
							continue;
						}
						// DiscardSingleEquipment(j);
						SellSingleEquipment(j);
						// j--; //should not decrement because increment wont happen
						continue;
					}
					if (r == 2) {
						if (wdata.hero.equipmentSets[wdata.hero.chosenEquipSet].equipmentSlots.contains(i)) {
							j++;
							continue;
						}
						// DiscardSingleEquipment(i);
						SellSingleEquipment(i);
						i--; // needs to decrement because it is a break, not a continue
						break;
					}
				}
				j++;
			}
			i++;
		}
	}

	public function CompareEquipmentStrength(e1:Equipment, e2:Equipment):Int {
		var e1Superior = 0;
		var e2Superior = 0;

		var mapAttr1 = e1.attributes;
		var mapAttr2 = e2.attributes;
		{
			for (attrKey in mapAttr1.keys()) {
				if (mapAttr2.exists(attrKey)) {
					if (mapAttr1[attrKey] > mapAttr2[attrKey])
						e1Superior = 1;
					if (mapAttr1[attrKey] < mapAttr2[attrKey])
						e2Superior = 1;
				} else {
					e1Superior = 1; // e1 has attribute not in e2, thus superior
				}
				// if it any time both items are superior, they are **different**
				if (e1Superior == 1 && e2Superior == 1)
					return -1;
			}

			for (attrKey in mapAttr2.keys()) {
				if (mapAttr1.exists(attrKey)) {
					if (mapAttr1[attrKey] > mapAttr2[attrKey])
						e1Superior = 1;
					if (mapAttr1[attrKey] < mapAttr2[attrKey])
						e2Superior = 1;
				} else {
					e2Superior = 1; // e2 has attribute not in e1, thus superior
				}
				// if it any time both items are superior, they are **different**
				if (e1Superior == 1 && e2Superior == 1)
					return -1;
			}
		}

		var mapAttr1 = e1.attributeMultiplier;
		var mapAttr2 = e2.attributeMultiplier;
		if (mapAttr1 != null || mapAttr2 != null) {
			if (mapAttr2 == null)
				mapAttr2 = new Map<String, Int>();
			if (mapAttr1 == null)
				mapAttr1 = new Map<String, Int>();
			{
				for (attrKey in mapAttr1.keys()) {
					if (mapAttr2.exists(attrKey)) {
						if (mapAttr1[attrKey] > mapAttr2[attrKey])
							e1Superior = 1;
						if (mapAttr1[attrKey] < mapAttr2[attrKey])
							e2Superior = 1;
					} else {
						if (mapAttr1[attrKey] > 100)
							e1Superior = 1; // e1 has attribute not in e2, and it is improving
						if (mapAttr1[attrKey] < 100)
							e2Superior = 1; // e1 has attribute not in e2, and it is diminishing
					}
					// if it any time both items are superior, they are **different**
					if (e1Superior == 1 && e2Superior == 1)
						return -1;
				}

				for (attrKey in mapAttr2.keys()) {
					if (mapAttr1.exists(attrKey)) {
						if (mapAttr1[attrKey] > mapAttr2[attrKey])
							e1Superior = 1;
						if (mapAttr1[attrKey] < mapAttr2[attrKey])
							e2Superior = 1;
					} else {
						if (mapAttr2[attrKey] > 100)
							e2Superior = 1; // e2 has attribute not in e1, and it is improving, thus superior
						if (mapAttr2[attrKey] < 100)
							e1Superior = 1; // e2 has attribute not in e1, and it is diminishing, thus e2 inferior
					}
					// if it any time both items are superior, they are **different**
					if (e1Superior == 1 && e2Superior == 1)
						return -1;
				}
			}
		}

		if (e1Superior == 1 && e2Superior == 0)
			return 1;
		if (e1Superior == 0 && e2Superior == 1)
			return 2;
		return 0; // this means they are the same
	}

	public function GetJsonPersistentData():String {
		// var data = {maxArea: maxArea, currentArea: battleArea, enemiesKilledInAreas: killedInArea};

		// Don't do this. If there are problems, they are related to dynamic attributes like life or speedcount
		// and they need to be addressed
		// RecalculateAttributes(wdata.hero);
		return Json.stringify(wdata);
	}

	public function SendJsonPersistentData(jsonString) {
		var loadedWdata:WorldData = Json.parse(jsonString);
		if (loadedWdata.worldVersion < 301) {
			loadedWdata.worldVersion = wdata.worldVersion;
			loadedWdata.sleeping = loadedWdata.sleeping == true;
		}
		if (loadedWdata.worldVersion >= 601 == false) {
			loadedWdata.regionProgress = [];
			loadedWdata.regionProgress.push({
				area: loadedWdata.battleArea,
				maxArea: loadedWdata.maxArea,
				amountEnemyKilledInArea: loadedWdata.killedInArea[loadedWdata.battleArea],
				maxAreaRecord: loadedWdata.maxArea,
				maxAreaOnPrestigeRecord: []
			});
			loadedWdata.battleAreaRegion = 0;
			loadedWdata.battleArea = 0;
		}
		if (loadedWdata.worldVersion != wdata.worldVersion) {
			loadedWdata.enemy = null;
		}

		loadedWdata.worldVersion = wdata.worldVersion;
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
