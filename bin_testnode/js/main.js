(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var ArrayHelper = function() { };
ArrayHelper.__name__ = true;
ArrayHelper.InsertOnEmpty = function(ele,array) {
	if(array.indexOf(null) != -1) {
		var id = array.indexOf(null);
		array[id] = ele;
		return id;
	}
	array.push(ele);
	return array.length - 1;
};
var BattleManager = function() {
	this.equipmentToDiscard = [];
	this.volatileAttributeAux = [];
	this.volatileAttributeList = ["MP","Life","MPRechargeCount","SpeedCount"];
	this.skillSlotUnlocklevel = [2,7,22,35];
	this.regionPrizes = [{ statBonus : null, xpPrize : true}];
	this.regionRequirements = [0];
	this.playerActions = new haxe_ds_StringMap();
	this.events = [];
	this.fixedRandom = new seedyrng_Random();
	this.random = new seedyrng_Random();
	this.equipDropChance_Rare = 15;
	this.equipDropChance = 30;
	this.timePeriod = 0.6;
	this.enemySheets = [];
	this.canLevelUp = false;
	this.canAdvance = false;
	this.canRetreat = false;
	this.dirty = false;
	this.balancing = { timeToKillFirstEnemy : 5, timeForFirstAreaProgress : 20, timeForFirstLevelUpGrind : 90, areaBonusXPPercentOfFirstLevelUp : 60};
	var bm = this;
	bm.enemySheets.push({ speciesMultiplier : null, speciesLevelStats : null, speciesAdd : null});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 0.55;
	_g.h["Speed"] = 3.3;
	_g.h["LifeMax"] = 1.6;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Speed"] = 1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, speciesLevelStats : { attributesBase : _g1}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Speed"] = 2;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 4;
	_g.h["Speed"] = 0.09;
	_g.h["LifeMax"] = 4;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Speed"] = 0.05;
	_g1.h["Defense"] = 0.4;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, speciesLevelStats : { attributesBase : _g1}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	_g.h["LifeMax"] = 5;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1.4;
	_g.h["Speed"] = 0.15;
	_g.h["LifeMax"] = 5.5;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Defense"] = 5;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 1;
	_g2.h["Speed"] = 0.05;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : _g1, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Defense"] = 1;
	_g.h["LifeMax"] = 8;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1.4;
	_g.h["Speed"] = 1.1;
	_g.h["LifeMax"] = 1.7;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Piercing"] = 100;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 0.2;
	_g2.h["Speed"] = 0.1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : _g1, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Speed"] = 1;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 10;
	_g.h["Speed"] = 3.5;
	_g.h["LifeMax"] = 0.1;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Defense"] = 0.2;
	_g1.h["Speed"] = 0.1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, speciesLevelStats : { attributesBase : _g1}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 3;
	_g.h["Speed"] = 2;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 0.5;
	_g.h["Speed"] = 2.9;
	_g.h["LifeMax"] = 2;
	_g.h["Defense"] = 0.3;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Antibuff"] = 1;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 0.2;
	_g2.h["Speed"] = 0.1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : _g1, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Speed"] = 2;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Speed"] = 0.8;
	_g.h["LifeMax"] = 2;
	_g.h["Defense"] = 0.4;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Attack"] = 800;
	_g1.h["Defense"] = 800;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 0.2;
	_g2.h["Speed"] = 0.1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, initialBuff : { uniqueId : "Power Up", mulStats : _g1, duration : 3, addStats : null, strength : 100}, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1.8;
	_g.h["Speed"] = 1.4;
	_g.h["LifeMax"] = 2;
	_g.h["Defense"] = 0.5;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["DebuffProtection"] = 100;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 0.2;
	_g2.h["Speed"] = 0.1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : _g1, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Defense"] = 1;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	bm.regionRequirements = [0,5,9,14,18,22,30,42,50];
	if(bm.regionPrizes.length > bm.regionRequirements.length) {
		console.log("src/logic/BattleManager.hx:779:","PROBLEM: Tell developer to add more region requirements!!!");
	}
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	_g.h["Speed"] = 20;
	_g.h["SpeedCount"] = 0;
	var stats = _g;
	var w = { worldVersion : 1005, hero : { level : 1, attributesBase : null, equipmentSlots : null, equipment : null, xp : null, attributesCalculated : stats, reference : new ActorReference(0,0)}, enemy : null, maxArea : 1, necessaryToKillInArea : 0, killedInArea : [0,0], prestigeTimes : 0, timeCount : 0, playerTimesKilled : 0, battleArea : 0, battleAreaRegion : 0, battleAreaRegionMax : 1, playerActions : new haxe_ds_StringMap(), recovering : false, sleeping : false, regionProgress : []};
	this.wdata = w;
	this.ReinitGameValues();
	this.ChangeBattleArea(0);
	var v = this.wdata.hero.attributesCalculated.h["LifeMax"];
	this.wdata.hero.attributesCalculated.h["Life"] = v;
};
BattleManager.__name__ = true;
BattleManager.IsLimitBreakable = function(e,wdata) {
	var level = wdata.equipLevels[e.outsideSystems.h["level"]];
	return level.limitbreak < 3;
};
BattleManager.IsUpgradable = function(e,wdata) {
	var level = wdata.equipLevels[e.outsideSystems.h["level"]];
	var maxLevel = level.limitbreak * 3 + 3;
	var upgradable = level.level < maxLevel;
	return upgradable;
};
BattleManager.GetLimitBreakCost = function(e,wdata) {
	return ((BattleManager.GetCost(e,wdata) + 1) / 5 | 0) * 3;
};
BattleManager.GetSellPrize = function(e,wdata) {
	return BattleManager.GetCost(e,wdata) / 5 | 0;
};
BattleManager.GetCost = function(e,wdata) {
	var genLevel = 1;
	if(e.generationLevel >= 0) {
		genLevel = e.generationLevel;
	}
	if(e.generationPrefixMod >= 0) {
		genLevel *= 1.3;
	}
	if(e.generationSuffixMod >= 0) {
		genLevel *= 1.3;
	}
	return (genLevel / 5 | 0) * 5 + 5;
};
BattleManager.CanUpgrade = function(e,wdata) {
	if(BattleManager.IsUpgradable(e,wdata) == false) {
		return false;
	}
	return BattleManager.GetCost(e,wdata) <= wdata.currency.currencies.h["Lagrima"].value;
};
BattleManager.CanLimitBreak = function(e,wdata) {
	if(BattleManager.IsLimitBreakable(e,wdata) == false) {
		return false;
	}
	return BattleManager.GetLimitBreakCost(e,wdata) <= wdata.currency.currencies.h["Lagrima Stone"].value;
};
BattleManager.LimitBreak = function(e,wdata) {
	var cost = BattleManager.GetLimitBreakCost(e,wdata);
	wdata.currency.currencies.h["Lagrima Stone"].value -= cost;
	var level = wdata.equipLevels[e.outsideSystems.h["level"]];
	level.limitbreak++;
};
BattleManager.Upgrade = function(e,wdata) {
	var cost = BattleManager.GetCost(e,wdata);
	wdata.currency.currencies.h["Lagrima"].value -= cost;
	var level = wdata.equipLevels[e.outsideSystems.h["level"]];
	level.level++;
	if(BattleManager.IsUpgradable(e,wdata) == false) {
		wdata.currency.currencies.h["Lagrima Stone"].value += BattleManager.GetLimitBreakCost(e,wdata) / 3 | 0;
	}
	if(Object.prototype.hasOwnProperty.call(e.attributes.h,"Attack")) {
		var tmp = "Attack";
		var v = e.attributes.h[tmp] + 1;
		e.attributes.h[tmp] = v;
	}
	if(Object.prototype.hasOwnProperty.call(e.attributes.h,"MagicAttack")) {
		var tmp = "MagicAttack";
		var v = e.attributes.h[tmp] + 1;
		e.attributes.h[tmp] = v;
	}
	if(e.type == 1) {
		if(e.attributes.h["LifeMax"] >= 0 == false) {
			e.attributes.h["LifeMax"] = 0;
		}
		var _g = e.attributes;
		var v = _g.h["LifeMax"] + 2;
		_g.h["LifeMax"] = v;
	}
	if(level.level % 3 != 0) {
		if(Object.prototype.hasOwnProperty.call(e.attributes.h,"Defense")) {
			var tmp = "Defense";
			var v = e.attributes.h[tmp] + 1;
			e.attributes.h[tmp] = v;
		}
		if(Object.prototype.hasOwnProperty.call(e.attributes.h,"MagicDefense")) {
			var tmp = "MagicDefense";
			var v = e.attributes.h[tmp] + 1;
			e.attributes.h[tmp] = v;
		}
	}
};
BattleManager.prototype = {
	GetAttribute: function(actor,label) {
		var i = actor.attributesCalculated.h[label];
		if(i < 0) {
			i = 0;
		}
		return i;
	}
	,UseMP: function(actor,mpCost,event) {
		if(event == null) {
			event = true;
		}
		var mp = actor.attributesCalculated.h["MP"];
		mp -= mpCost;
		if(mp <= 0) {
			mp = 0;
			actor.attributesCalculated.h["MPRechargeCount"] = 0;
			if(event) {
				var ev = this.AddEvent(EventTypes.MPRunOut);
				ev.origin = this.wdata.hero.reference;
			}
		}
		actor.attributesCalculated.h["MP"] = mp;
	}
	,UseSkill: function(skill,actor,activeStep) {
		if(activeStep == null) {
			activeStep = false;
		}
		var id = skill.id;
		var skillBase = this.GetSkillBase(id);
		if(skillBase.turnRecharge > 0) {
			if(actor.turnRecharge == null) {
				actor.turnRecharge = [];
			}
			actor.turnRecharge[actor.usableSkills.indexOf(skill)] = skillBase.turnRecharge;
		}
		if(activeStep == false && skillBase.activeEffect != null) {
			this.scheduledSkill = skill;
			return;
		}
		if(actor == this.wdata.hero) {
			this.wdata.timeCount = 0;
		}
		var executedEffects = 0;
		var efs = skillBase.effects;
		if(activeStep) {
			efs = skillBase.activeEffect;
		}
		var skillUsed = false;
		var _g = 0;
		while(_g < efs.length) {
			var ef = efs[_g];
			++_g;
			var targets = [];
			if(ef.target == Target.SELF) {
				targets.push(actor);
			}
			if(ef.target == Target.ENEMY) {
				if(this.wdata.hero == actor) {
					if(this.wdata.enemy.attributesCalculated.h["LifeMax"] == 0) {
						this.CreateAreaEnemy();
					}
					targets.push(this.wdata.enemy);
				} else {
					targets.push(this.wdata.hero);
				}
			}
			++executedEffects;
			if(skillUsed == false) {
				skillUsed = true;
				var mpCost = skillBase.mpCost;
				this.UseMP(actor,mpCost);
				var ev = this.AddEvent(EventTypes.SkillUse);
				ev.origin = this.wdata.hero.reference;
				ev.dataString = skill.id;
			}
			ef.effectExecution(this,skill.level,actor,targets);
		}
	}
	,Heal: function(target,lifeMaxPercentage,rawBonus) {
		if(rawBonus == null) {
			rawBonus = 0;
		}
		if(lifeMaxPercentage == null) {
			lifeMaxPercentage = 0;
		}
		var lifem = target.attributesCalculated.h["LifeMax"];
		var life = target.attributesCalculated.h["Life"];
		life += rawBonus + (lifeMaxPercentage * lifem / 100 | 0);
		if(life > lifem) {
			life = lifem;
		}
		target.attributesCalculated.h["Life"] = life;
	}
	,RemoveBuffs: function(defender,keepDebuffs) {
		if(keepDebuffs == null) {
			keepDebuffs = true;
		}
		if(keepDebuffs == false) {
			defender.buffs.length = 0;
		} else {
			var i = 0;
			while(i < defender.buffs.length) {
				if(defender.buffs[i].debuff == true) {
					++i;
					continue;
				}
				HxOverrides.remove(defender.buffs,defender.buffs[i]);
			}
		}
		this.RecalculateAttributes(defender);
		this.AddEvent(EventTypes.BuffRemoval).origin = defender.reference;
	}
	,AttackExecute: function(attacker,defender,attackRate,attackBonus,defenseRate) {
		if(defenseRate == null) {
			defenseRate = 100;
		}
		if(attackBonus == null) {
			attackBonus = 0;
		}
		if(attackRate == null) {
			attackRate = 100;
		}
		var gEvent = this.AddEvent(EventTypes.ActorAttack);
		var magicAttack = false;
		var enchant = attacker.attributesCalculated.h["enchant-fire"];
		if(enchant > 0) {
			magicAttack = true;
			attackBonus += enchant;
		}
		if(attacker.attributesCalculated.h["Blood"] > 0) {
			var blood = attacker.attributesCalculated.h["Blood"];
			var bloodMul = 100;
			if(attacker.attributesCalculated.h["Bloodthirst"] > 0) {
				bloodMul += attacker.attributesCalculated.h["Bloodthirst"];
			}
			attackBonus += (blood * 5 + 10) * bloodMul / 100 | 0;
			var life = attacker.attributesCalculated.h["Life"];
			var decrease = attacker.attributesCalculated.h["LifeMax"] * blood / 100;
			if(decrease < 1) {
				decrease = 1;
			}
			if(decrease >= life - 1) {
				decrease = life - 1;
			}
			life -= decrease | 0;
			attacker.attributesCalculated.h["Life"] = life;
		}
		if(attacker.attributesCalculated.h["Antibuff"] > 0) {
			this.RemoveBuffs(defender);
		}
		if(magicAttack == false) {
			if(attacker.attributesCalculated.h["Piercing"] > 0 == true) {
				defenseRate -= attacker.attributesCalculated.h["Piercing"];
			}
		}
		if(defenseRate < 0) {
			defenseRate = 0;
		}
		var attack = 0;
		var defense = 0;
		if(magicAttack) {
			attack = attacker.attributesCalculated.h["MagicAttack"];
			defense = defender.attributesCalculated.h["MagicDefense"];
		} else {
			attack = attacker.attributesCalculated.h["Attack"];
			defense = defender.attributesCalculated.h["Defense"];
		}
		attack = attackRate * attack / 100 + attackBonus;
		var damage = attack - defense * defenseRate / 100 | 0;
		if(damage < 0) {
			damage = 0;
		}
		var _g = defender.attributesCalculated;
		var v = _g.h["Life"] - damage;
		_g.h["Life"] = v;
		if(defender.attributesCalculated.h["Life"] < 0) {
			defender.attributesCalculated.h["Life"] = 0;
		}
		if(damage >= 1) {
			var _g = 0;
			var _g1 = defender.buffs;
			while(_g < _g1.length) {
				var b = _g1[_g];
				++_g;
				if(b.noble == true) {
					b.duration = 0;
				}
			}
		}
		gEvent.origin = attacker.reference;
		gEvent.target = defender.reference;
		gEvent.data = damage;
		var hero = this.wdata.hero;
		var enemy = this.wdata.enemy;
		var killedInArea = this.wdata.killedInArea;
		var battleArea = this.wdata.battleArea;
		var areaComplete = killedInArea[battleArea] >= this.wdata.necessaryToKillInArea;
		if(enemy.attributesCalculated.h["Life"] <= 0) {
			if(killedInArea[battleArea] == null) {
				killedInArea[battleArea] = 0;
			}
			killedInArea[battleArea]++;
			if(this.wdata.battleAreaRegion == 0) {
				this.DropItemOrSkillSet(this.equipDropChance,1,enemy.level,enemy.reference);
			}
			var e = this.AddEvent(EventTypes.ActorDead);
			e.origin = enemy.reference;
			var xpGain = enemy.level;
			this.AwardXP(enemy.level);
			if(killedInArea[battleArea] >= this.wdata.necessaryToKillInArea) {
				this.AddEvent(EventTypes.AreaComplete).data = this.wdata.battleArea;
				if(this.wdata.maxArea == this.wdata.battleArea) {
					if(this.regionPrizes[this.wdata.battleAreaRegion].xpPrize == true) {
						var areaForBonus = this.wdata.battleArea;
						ResourceLogic.recalculateScalingResource(areaForBonus,this.areaBonus);
						var xpPlus = this.areaBonus.calculatedMax;
						this.AwardXP(xpPlus);
					}
					if(this.regionPrizes[this.wdata.battleAreaRegion].statBonus != null) {
						var h = this.regionPrizes[this.wdata.battleAreaRegion].statBonus.h;
						var su_h = h;
						var su_keys = Object.keys(h);
						var su_length = su_keys.length;
						var su_current = 0;
						while(su_current < su_length) {
							var key = su_keys[su_current++];
							var su_key = key;
							var su_value = su_h[key];
							var e = this.AddEvent(EventTypes.statUpgrade);
							e.dataString = su_key;
							e.data = su_value;
						}
						this.AddEvent(EventTypes.PermanentStatUpgrade);
					}
					this.wdata.maxArea++;
					this.AddEvent(EventTypes.AreaUnlock).data = this.wdata.maxArea;
					killedInArea[this.wdata.maxArea] = 0;
				}
			}
		}
		if(hero.attributesCalculated.h["Life"] <= 0) {
			this.wdata.recovering = true;
			this.wdata.enemy = null;
			var e = this.AddEvent(EventTypes.ActorDead);
			e.origin = hero.reference;
			this.wdata.playerTimesKilled++;
		}
	}
	,ForceSkillSetDrop: function(enemyLevel,dropperReference,ss,event) {
		if(event == null) {
			event = true;
		}
		var scalingStats = new haxe_ds_StringMap();
		switch(this.random.randomInt(0,2)) {
		case 0:
			scalingStats.h["Attack"] = 0.3;
			break;
		case 1:
			scalingStats.h["Defense"] = 0.3;
			break;
		case 2:
			scalingStats.h["Speed"] = 0.1;
			break;
		}
		var itemB = { type : 2, statMultipliers : null, scalingStats : scalingStats, name : null};
		if(this.wdata.skillSets == null) {
			this.wdata.skillSets = [];
		}
		var skillSetPos = ArrayHelper.InsertOnEmpty(ss,this.wdata.skillSets);
		this.DropItem(itemB,-1,skillSetPos,enemyLevel,dropperReference,event);
	}
	,DropItemOrSkillSet: function(itemDropProbability,skillSetDropProbability,enemyLevel,dropperReference) {
		if(skillSetDropProbability == null) {
			skillSetDropProbability = 2;
		}
		var baseItem = -1;
		var itemB = null;
		if(this.random.randomInt(0,1000) < skillSetDropProbability * 10) {
			var skillPosArray = [];
			var baseLevel = 1;
			var maxLevel = 1;
			var maxNSkills = 2;
			if(this.wdata.enemy.level > 5) {
				maxNSkills = 3;
			}
			if(this.wdata.enemy.level > 10) {
				maxLevel = 2;
			}
			if(this.wdata.enemy.level > 25) {
				maxNSkills = 4;
			}
			if(this.wdata.enemy.level > 35) {
				maxLevel = 4;
			}
			var numberOfSkills = this.random.randomInt(1,maxNSkills);
			var _g = 0;
			var _g1 = numberOfSkills;
			while(_g < _g1) {
				var s = _g++;
				var skill = this.random.randomInt(0,this.skillBases.length - 1 - s);
				while(skillPosArray.indexOf(skill) != -1) ++skill;
				skillPosArray[s] = skill;
			}
			var ss = { skills : []};
			var _g = 0;
			var _g1 = skillPosArray.length;
			while(_g < _g1) {
				var j = _g++;
				var level = baseLevel;
				level = this.random.randomInt(baseLevel,maxLevel);
				if(j >= 2) {
					level = maxLevel + 1;
				}
				if(j >= 3) {
					level = maxLevel + 2;
				}
				var sp = skillPosArray[j];
				ss.skills.push({ id : this.skillBases[sp].id, level : level});
			}
			this.ForceSkillSetDrop(enemyLevel,dropperReference,ss);
			return;
		}
		if(this.random.randomInt(0,100) < itemDropProbability) {
			baseItem = this.random.randomInt(0,this.itemBases.length - 1);
			itemB = this.itemBases[baseItem];
			this.DropItem(itemB,baseItem,-1,enemyLevel,dropperReference);
		}
	}
	,DropItem: function(itemB,baseItem,skillSetPos,enemyLevel,dropperReference,event) {
		if(event == null) {
			event = true;
		}
		var e = null;
		var stat = new haxe_ds_StringMap();
		var statVar = new haxe_ds_StringMap();
		var mul = new haxe_ds_StringMap();
		var mulVar = new haxe_ds_StringMap();
		var minLevel = (enemyLevel + 1) / 2 - 3 | 0;
		if(minLevel < 1) {
			minLevel = 1;
		}
		var maxLevel = enemyLevel / 2 + 2 | 0;
		var level = this.random.randomInt(minLevel,maxLevel);
		var prefixPos = -1;
		var prefixSeed = -1;
		var suffixPos = -1;
		var suffixSeed = -1;
		if(itemB.scalingStats != null) {
			var h = itemB.scalingStats.h;
			var s_h = h;
			var s_keys = Object.keys(h);
			var s_length = s_keys.length;
			var s_current = 0;
			while(s_current < s_length) {
				var key = s_keys[s_current++];
				var s_key = key;
				var s_value = s_h[key];
				var vari = this.random.randomInt(80,100);
				statVar.h[s_key] = vari;
				var value = s_value * vari * level;
				if(value < 100) {
					value = 100;
				}
				var v = value / 100 | 0;
				stat.h[s_key] = v;
			}
		}
		if(itemB.statMultipliers != null) {
			var h = itemB.statMultipliers.h;
			var s_h = h;
			var s_keys = Object.keys(h);
			var s_length = s_keys.length;
			var s_current = 0;
			while(s_current < s_length) {
				var key = s_keys[s_current++];
				var s_key = key;
				var s_value = s_h[key];
				var vari = this.random.randomInt(0,100);
				mulVar.h[s_key] = vari;
				var min = s_value.min;
				var max = s_value.max;
				var range = max - min;
				var v = min + range * vari / 100 | 0;
				mul.h[s_key] = v;
			}
		}
		if(this.random.randomInt(0,100) < this.equipDropChance_Rare) {
			var modType = this.random.randomInt(0,2);
			var prefixExist = modType == 0 || modType == 2;
			var suffixExist = modType == 1 || modType == 2;
			if(prefixExist) {
				prefixPos = this.random.randomInt(0,this.modBases.length - 1);
				prefixSeed = this.random.nextInt();
				var tmp = this.modBases[prefixPos];
				var this1 = new haxe__$Int64__$_$_$Int64(prefixSeed >> 31,prefixSeed);
				this.AddMod(tmp,stat,mul,this1);
			}
			if(suffixExist) {
				suffixPos = this.random.randomInt(0,this.modBases.length - 1);
				suffixSeed = this.random.nextInt();
				var tmp = this.modBases[suffixPos];
				var this1 = new haxe__$Int64__$_$_$Int64(suffixSeed >> 31,suffixSeed);
				this.AddMod(tmp,stat,mul,this1);
			}
		}
		var h = mul.h;
		var m_h = h;
		var m_keys = Object.keys(h);
		var m_length = m_keys.length;
		var m_current = 0;
		while(m_current < m_length) {
			var key = m_keys[m_current++];
			var m_key = key;
			var m_value = m_h[key];
			if(m_value % 5 != 0) {
				var v = ((m_value + 4) / 5 | 0) * 5;
				mul.h[m_key] = v;
			}
		}
		var outsideSystem = new haxe_ds_StringMap();
		if(this.wdata.equipLevels == null) {
			this.wdata.equipLevels = [];
		}
		if(skillSetPos >= 0) {
			outsideSystem.h["skillset"] = skillSetPos;
		}
		var v = ArrayHelper.InsertOnEmpty({ level : 0, limitbreak : 0, ascension : 0},this.wdata.equipLevels);
		outsideSystem.h["level"] = v;
		e = { type : itemB.type, seen : 0, requiredAttributes : null, attributes : stat, generationVariations : statVar, generationLevel : level, generationBaseItem : baseItem, attributeMultiplier : mul, generationVariationsMultiplier : mulVar, generationSuffixMod : suffixPos, generationPrefixMod : prefixPos, generationSuffixModSeed : suffixSeed, generationPrefixModSeed : prefixSeed, outsideSystems : outsideSystem};
		var addedIndex = -1;
		var _g = 0;
		var _g1 = this.wdata.hero.equipment.length;
		while(_g < _g1) {
			var i = _g++;
			if(this.wdata.hero.equipment[i] == null) {
				this.wdata.hero.equipment[i] = e;
				addedIndex = i;
				break;
			}
		}
		if(addedIndex < 0) {
			this.wdata.hero.equipment.push(e);
			addedIndex = this.wdata.hero.equipment.length - 1;
		}
		if(event) {
			var e = this.AddEvent(EventTypes.EquipDrop);
			e.data = addedIndex;
			e.origin = dropperReference;
		}
	}
	,AddBuff: function(buff,actor) {
		var addBuff = true;
		if(buff.debuff == true) {
			var debpro = actor.attributesCalculated.h["DebuffProtection"];
			if(debpro > 0) {
				if(this.random.randomInt(1,100) < debpro) {
					this.AddEvent(EventTypes.DebuffBlock).origin = actor.reference;
					return;
				}
			}
		}
		var _g = 0;
		var _g1 = actor.buffs.length;
		while(_g < _g1) {
			var bi = _g++;
			var b = actor.buffs[bi];
			if(b.uniqueId == buff.uniqueId) {
				addBuff = false;
				if(b.strength < buff.strength) {
					actor.buffs[bi] = buff;
					break;
				}
				if(b.strength == buff.strength && b.duration < buff.duration) {
					actor.buffs[bi] = buff;
					break;
				}
			}
		}
		if(addBuff) {
			actor.buffs.push(buff);
		}
		this.RecalculateAttributes(actor);
	}
	,GetSkillBase: function(id) {
		var _g = 0;
		var _g1 = this.skillBases;
		while(_g < _g1.length) {
			var s = _g1[_g];
			++_g;
			if(s.id == id) {
				return s;
			}
		}
		return null;
	}
	,ChangeBattleArea: function(area) {
		if(this.wdata.killedInArea[this.wdata.battleArea] >= this.wdata.necessaryToKillInArea) {
			this.wdata.killedInArea[this.wdata.battleArea] = 0;
		}
		this.wdata.battleArea = area;
		this.wdata.necessaryToKillInArea = 0;
		if(this.wdata.killedInArea.length <= area) {
			this.wdata.killedInArea[area] = 0;
		}
		var initialEnemyToKill = this.balancing.timeForFirstAreaProgress / this.balancing.timeToKillFirstEnemy | 0;
		if(area > 0) {
			this.wdata.necessaryToKillInArea = initialEnemyToKill + ((area - 1) * initialEnemyToKill * 0.3 | 0);
			if(this.wdata.necessaryToKillInArea > initialEnemyToKill * 14) {
				this.wdata.necessaryToKillInArea = initialEnemyToKill * 14;
			}
			var fRand = this.fixedRandom;
			var x = area + 1;
			var this1 = new haxe__$Int64__$_$_$Int64(x >> 31,x);
			fRand.set_seed(this1);
			if(area > 4) {
				var mul = fRand.random() * 1.5 + 0.5;
				this.wdata.necessaryToKillInArea = this.wdata.necessaryToKillInArea * mul | 0;
			}
			if(this.wdata.battleAreaRegion > 0) {
				this.wdata.necessaryToKillInArea = 3;
			}
			if(this.PlayerFightMode()) {
				this.CreateAreaEnemy();
			}
		} else {
			this.wdata.enemy = null;
		}
		ResourceLogic.recalculateScalingResource(this.wdata.battleArea,this.areaBonus);
		this.dirty = true;
	}
	,PlayerFightMode: function() {
		if(this.wdata.recovering != true) {
			return this.wdata.sleeping != true;
		} else {
			return false;
		}
	}
	,CalculateHeroMaxLevel: function() {
		return this.wdata.prestigeTimes * this.GetMaxLevelBonusOnPrestige() + 20;
	}
	,AwardXP: function(xpPlus) {
		if(this.wdata.hero.level < this.CalculateHeroMaxLevel()) {
			xpPlus += xpPlus * this.wdata.prestigeTimes * this.GetXPBonusOnPrestige() | 0;
			this.wdata.hero.xp.value += xpPlus;
			var e = this.AddEvent(EventTypes.GetXP);
			e.data = xpPlus;
		}
	}
	,GetMaxLevelBonusOnPrestige: function() {
		return 10;
	}
	,GetXPBonusOnPrestige: function() {
		return 0.5;
	}
	,GetLevelRequirementForPrestige: function() {
		return this.CalculateHeroMaxLevel() - 10;
	}
	,CreateAreaEnemy: function() {
		var region = this.wdata.battleAreaRegion;
		var enemyLevel = this.wdata.battleArea;
		var sheet = this.enemySheets[region];
		if(region > 0) {
			var oldLevel = enemyLevel;
			enemyLevel = 0;
			var _g = 0;
			var _g1 = oldLevel;
			while(_g < _g1) {
				var i = _g++;
				enemyLevel += 10;
				enemyLevel += i * 10;
			}
		}
		var timeToKillEnemy = this.balancing.timeToKillFirstEnemy;
		var initialAttackHero = 1;
		var heroAttackTime = this.timePeriod * 2;
		var heroDPS = initialAttackHero / heroAttackTime;
		var initialLifeEnemy = heroDPS * timeToKillEnemy | 0;
		var enemyLife = initialLifeEnemy + (enemyLevel - 1) * initialLifeEnemy;
		var enemyAttack = 1 + (enemyLevel - 1);
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = enemyAttack;
		_g.h["Life"] = enemyLife;
		_g.h["LifeMax"] = enemyLife;
		_g.h["Speed"] = 20;
		_g.h["SpeedCount"] = 0;
		_g.h["Defense"] = 0;
		_g.h["MagicDefense"] = 0;
		_g.h["Piercing"] = 0;
		var stats2 = _g;
		this.wdata.enemy = { level : 1 + enemyLevel, attributesBase : stats2, equipmentSlots : null, equipment : [], xp : null, attributesCalculated : stats2, reference : new ActorReference(1,0), buffs : [], usableSkills : []};
		if(sheet != null) {
			var mul = sheet.speciesMultiplier;
			if(mul != null) {
				var h = mul.attributesBase.h;
				var p_h = h;
				var p_keys = Object.keys(h);
				var p_length = p_keys.length;
				var p_current = 0;
				while(p_current < p_length) {
					var key = p_keys[p_current++];
					var p_key = key;
					var p_value = p_h[key];
					var mul = p_value;
					var value = this.wdata.enemy.attributesBase.h[p_key] * mul | 0;
					this.wdata.enemy.attributesBase.h[p_key] = value;
					this.wdata.enemy.attributesCalculated.h[p_key] = value;
				}
			}
			if(sheet.speciesAdd != null) {
				var h = sheet.speciesAdd.h;
				var p_h = h;
				var p_keys = Object.keys(h);
				var p_length = p_keys.length;
				var p_current = 0;
				while(p_current < p_length) {
					var key = p_keys[p_current++];
					var p_key = key;
					var p_value = p_h[key];
					var add = p_value;
					if(Object.prototype.hasOwnProperty.call(this.wdata.enemy.attributesBase.h,p_key) == false) {
						this.wdata.enemy.attributesBase.h[p_key] = add;
						this.wdata.enemy.attributesCalculated.h[p_key] = add;
					} else {
						var _g = p_key;
						var _g1 = this.wdata.enemy.attributesBase;
						var v = _g1.h[_g] + add;
						_g1.h[_g] = v;
						var _g2 = p_key;
						var _g3 = this.wdata.enemy.attributesCalculated;
						var v1 = _g3.h[_g2] + add;
						_g3.h[_g2] = v1;
					}
				}
			}
			if(sheet.speciesLevelStats != null) {
				var h = sheet.speciesLevelStats.attributesBase.h;
				var p_h = h;
				var p_keys = Object.keys(h);
				var p_length = p_keys.length;
				var p_current = 0;
				while(p_current < p_length) {
					var key = p_keys[p_current++];
					var p_key = key;
					var p_value = p_h[key];
					var addLevel = p_value;
					var value = this.wdata.enemy.attributesBase.h[p_key] + addLevel * enemyLevel | 0;
					this.wdata.enemy.attributesBase.h[p_key] = value;
					this.wdata.enemy.attributesCalculated.h[p_key] = value;
				}
			}
			if(sheet.initialBuff != null) {
				this.AddBuff(sheet.initialBuff,this.wdata.enemy);
			}
		}
		var v = this.wdata.enemy.attributesCalculated.h["LifeMax"];
		this.wdata.enemy.attributesCalculated.h["Life"] = v;
	}
	,ReinitGameValues: function() {
		var _gthis = this;
		if(this.wdata.currency == null) {
			var _g = new haxe_ds_StringMap();
			_g.h["Lagrima"] = { value : 0, visible : false};
			_g.h["Lagrima Stone"] = { value : 0, visible : false};
			this.wdata.currency = { currencies : _g};
		}
		if(this.wdata.hero.equipment != null) {
			while(this.wdata.hero.equipment.indexOf(null) != -1) this.DiscardSingleEquipment(this.wdata.hero.equipment.indexOf(null));
			var _g_current = 0;
			var _g_array = this.wdata.hero.equipment;
			while(_g_current < _g_array.length) {
				var _g1_value = _g_array[_g_current];
				var _g1_key = _g_current++;
				var index = _g1_key;
				var value = _g1_value;
				if(value.outsideSystems == null) {
					value.outsideSystems = new haxe_ds_StringMap();
				}
				if(this.wdata.equipLevels == null) {
					this.wdata.equipLevels = [];
				}
				if(Object.prototype.hasOwnProperty.call(value.outsideSystems.h,"level") == false) {
					var index1 = ArrayHelper.InsertOnEmpty({ level : 0, limitbreak : 0, ascension : 0},this.wdata.equipLevels);
					value.outsideSystems.h["level"] = index1;
				}
			}
		}
		if(this.wdata.regionProgress == null) {
			this.wdata.regionProgress = [];
		}
		var _g = 0;
		var _g1 = this.wdata.regionProgress;
		while(_g < _g1.length) {
			var r = _g1[_g];
			++_g;
			if(r.maxAreaOnPrestigeRecord == null) {
				r.maxAreaOnPrestigeRecord = [];
			}
		}
		if(this.wdata.battleAreaRegionMax >= 1 == false) {
			this.wdata.battleAreaRegionMax = 1;
		}
		if(this.wdata.prestigeTimes >= 0 == false) {
			this.wdata.prestigeTimes = 0;
		}
		if(this.wdata.hero.buffs != null == false) {
			this.wdata.hero.buffs = [];
		}
		if(this.wdata.hero.usableSkills != null == false) {
			this.wdata.hero.usableSkills = [];
		}
		if(this.wdata.enemy != null) {
			if(this.wdata.enemy.buffs != null == false) {
				this.wdata.enemy.buffs = [];
			}
		}
		var addAction = function(id,action,callback) {
			var w = _gthis.wdata;
			if(Object.prototype.hasOwnProperty.call(_gthis.wdata.playerActions.h,id) == false) {
				_gthis.wdata.playerActions.h[id] = action;
				if(callback != null) {
					var v = { actionData : w.playerActions.h[id], actualAction : callback};
					_gthis.playerActions.h[id] = v;
				}
			}
		};
		var createAction = function() {
			var a = { visible : false, enabled : false, mode : 0, timesUsed : 0};
			return a;
		};
		addAction("sleep",{ visible : false, enabled : false, timesUsed : 0, mode : 0},function(a) {
			_gthis.wdata.enemy = null;
			_gthis.wdata.sleeping = !_gthis.wdata.sleeping;
		});
		addAction("advance",{ visible : true, enabled : false, timesUsed : 0, mode : 0},null);
		addAction("retreat",{ visible : false, enabled : false, timesUsed : 0, mode : 0},null);
		addAction("levelup",{ visible : false, enabled : false, timesUsed : 0, mode : 0},null);
		addAction("tabequipment",{ visible : false, enabled : false, timesUsed : 0, mode : 0},null);
		addAction("tabmemory",{ visible : false, enabled : false, timesUsed : 0, mode : 0},null);
		addAction("repeat",createAction(),function(a) {
			_gthis.wdata.killedInArea[_gthis.wdata.battleArea] = 0;
		});
		addAction("prestige",createAction(),function(a) {
			_gthis.PrestigeExecute();
		});
		var buttonId = 0;
		addAction("battleaction_" + 0,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[0];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 1;
		addAction("battleaction_" + 1,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[1];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 2;
		addAction("battleaction_" + 2,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[2];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 3;
		addAction("battleaction_" + 3,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[3];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 4;
		addAction("battleaction_" + 4,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[4];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 5;
		addAction("battleaction_" + 5,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[5];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var buttonId = 6;
		addAction("battleaction_" + 6,createAction(),function(struct) {
			var skill = _gthis.wdata.hero.usableSkills[6];
			_gthis.UseSkill(skill,_gthis.wdata.hero);
		});
		var _g = new haxe_ds_StringMap();
		_g.h["Life"] = 20;
		_g.h["LifeMax"] = 20;
		_g.h["Speed"] = 20;
		_g.h["SpeedCount"] = 0;
		_g.h["Attack"] = 1;
		_g.h["Defense"] = 0;
		_g.h["MagicAttack"] = 1;
		_g.h["MagicDefense"] = 0;
		_g.h["Piercing"] = 0;
		_g.h["Regen"] = 0;
		_g.h["enchant-fire"] = 0;
		_g.h["MP"] = 0;
		_g.h["MPMax"] = 100;
		_g.h["MPRecharge"] = 100;
		_g.h["MPRechargeCount"] = 10000;
		this.wdata.hero.attributesBase = _g;
		var valueXP = 0;
		if(this.wdata.hero.xp != null) {
			valueXP = this.wdata.hero.xp.value;
		}
		var timeLevelUpGrind = this.balancing.timeForFirstLevelUpGrind;
		var initialEnemyXP = 2;
		var initialXPToLevelUp = this.balancing.timeForFirstLevelUpGrind * initialEnemyXP / this.balancing.timeToKillFirstEnemy | 0;
		this.wdata.hero.xp = ResourceLogic.getExponentialResource(1.2,1,initialXPToLevelUp);
		this.wdata.hero.xp.value = valueXP;
		ResourceLogic.recalculateScalingResource(this.wdata.hero.level,this.wdata.hero.xp);
		this.areaBonus = ResourceLogic.getExponentialResource(1.2,1,initialXPToLevelUp * this.balancing.areaBonusXPPercentOfFirstLevelUp / 100 | 0);
		if(this.wdata.hero.equipment == null) {
			this.wdata.hero.equipment = [];
		}
		if(this.wdata.hero.equipmentSlots == null) {
			this.wdata.hero.equipmentSlots = [-1,-1,-1];
		}
		this.RecalculateAttributes(this.wdata.hero);
	}
	,PrestigeExecute: function() {
		this.wdata.enemy = null;
		this.wdata.hero.level = 1;
		this.wdata.hero.xp.value = 0;
		var hero = this.wdata.hero;
		ResourceLogic.recalculateScalingResource(hero.level,hero.xp);
		var _g = 0;
		var _g1 = this.wdata.regionProgress.length;
		while(_g < _g1) {
			var i = _g++;
			this.wdata.regionProgress[i].maxAreaOnPrestigeRecord.push(this.wdata.regionProgress[i].maxArea);
			this.wdata.regionProgress[i].area = 0;
			this.wdata.regionProgress[i].maxArea = 1;
			this.wdata.regionProgress[i].amountEnemyKilledInArea = 0;
			this.wdata.killedInArea = [0];
		}
		this.wdata.battleAreaRegion = 0;
		this.wdata.battleArea = 0;
		this.wdata.maxArea = 1;
		this.wdata.battleAreaRegionMax = 1;
		this.wdata.prestigeTimes++;
		this.RecalculateAttributes(this.wdata.hero);
		var _g = 0;
		var _g1 = this.wdata.hero.equipment.length;
		while(_g < _g1) {
			var i = _g++;
			if(this.wdata.hero.equipmentSlots.indexOf(i) != -1) {
				var e = this.wdata.hero.equipment[i];
				if(e != null) {
					var h = e.attributes.h;
					var s_h = h;
					var s_keys = Object.keys(h);
					var s_length = s_keys.length;
					var s_current = 0;
					while(s_current < s_length) {
						var s = s_keys[s_current++];
						var v = e.attributes.h[s] * 0.2 | 0;
						e.attributes.h[s] = v;
					}
				}
			} else {
				this.wdata.hero.equipment[i] = null;
			}
		}
	}
	,changeRegion: function(region) {
		this.wdata.battleAreaRegion = region;
		if(this.wdata.regionProgress[region] == null) {
			this.wdata.regionProgress[region] = { area : 0, maxArea : 1, amountEnemyKilledInArea : 0, maxAreaRecord : 1, maxAreaOnPrestigeRecord : []};
		}
		this.ChangeBattleArea(this.wdata.regionProgress[region].area);
		this.wdata.maxArea = this.wdata.regionProgress[region].maxArea;
		this.wdata.killedInArea[this.wdata.battleArea] = this.wdata.regionProgress[region].amountEnemyKilledInArea;
	}
	,advance: function() {
		var hero = this.wdata.hero;
		var enemy = this.wdata.enemy;
		var killedInArea = this.wdata.killedInArea;
		var battleArea = this.wdata.battleArea;
		var areaComplete = killedInArea[battleArea] >= this.wdata.necessaryToKillInArea;
		var attackHappen = true;
		if(areaComplete) {
			this.wdata.enemy = null;
			attackHappen = false;
		}
		if(this.wdata.battleArea > 0 && this.PlayerFightMode() && areaComplete != true) {
			if(enemy == null) {
				this.CreateAreaEnemy();
				enemy = this.wdata.enemy;
				attackHappen = false;
			}
			if(enemy.attributesCalculated.h["Life"] <= 0) {
				attackHappen = false;
				this.CreateAreaEnemy();
			}
		}
		if(this.PlayerFightMode() == false || enemy == null) {
			attackHappen = false;
			var chargeMultiplier = 3;
			var max = 99999;
			var restMultiplier = 1;
			var valueK = "Life";
			var valueMaxK = "LifeMax";
			var value = this.wdata.hero.attributesCalculated.h[valueK];
			if(valueMaxK != null) {
				max = this.wdata.hero.attributesCalculated.h[valueMaxK];
			}
			value += max * 0.05 | 0;
			if(this.wdata.sleeping) {
				value += max * 0.3 | 0;
			}
			if(value > max) {
				value = max;
			}
			this.wdata.hero.attributesCalculated.h[valueK] = value;
		}
		var _g = 0;
		while(_g < 2) {
			var i = _g++;
			var actor = this.wdata.hero;
			if(i == 1) {
				actor = this.wdata.enemy;
			}
			if(actor == null) {
				continue;
			}
			var regen = actor.attributesCalculated.h["Regen"];
			if(regen > 0) {
				var recovery = regen * actor.attributesCalculated.h["LifeMax"] / 100;
				if(recovery < 1) {
					recovery = 1;
				}
				var _g1 = actor.attributesCalculated;
				var v = _g1.h["Life"] + (recovery | 0);
				_g1.h["Life"] = v;
			}
			if(actor.attributesCalculated.h["Life"] > actor.attributesCalculated.h["LifeMax"]) {
				var v1 = actor.attributesCalculated.h["LifeMax"];
				actor.attributesCalculated.h["Life"] = v1;
			}
		}
		if(attackHappen) {
			var attacker = null;
			var defender = null;
			var decided = false;
			attacker = hero;
			defender = enemy;
			var _g = 0;
			while(_g < 100) {
				var i = _g++;
				var bActor = hero;
				var _g1 = bActor.attributesCalculated;
				var v = _g1.h["SpeedCount"] + bActor.attributesCalculated.h["Speed"];
				_g1.h["SpeedCount"] = v;
				var sc = bActor.attributesCalculated.h["SpeedCount"];
				if(decided == false) {
					if(bActor.attributesCalculated.h["SpeedCount"] > 1000) {
						var v1 = bActor.attributesCalculated.h["SpeedCount"] - 1000;
						bActor.attributesCalculated.h["SpeedCount"] = v1;
						decided = true;
					}
				}
				var bActor1 = hero;
				bActor1 = enemy;
				var _g2 = bActor1.attributesCalculated;
				var v2 = _g2.h["SpeedCount"] + bActor1.attributesCalculated.h["Speed"];
				_g2.h["SpeedCount"] = v2;
				var sc1 = bActor1.attributesCalculated.h["SpeedCount"];
				if(decided == false) {
					if(bActor1.attributesCalculated.h["SpeedCount"] > 1000) {
						var v3 = bActor1.attributesCalculated.h["SpeedCount"] - 1000;
						bActor1.attributesCalculated.h["SpeedCount"] = v3;
						attacker = enemy;
						defender = hero;
						decided = true;
					}
				}
				if(decided) {
					break;
				}
			}
			if(attacker == this.wdata.hero && this.scheduledSkill != null) {
				this.UseSkill(this.scheduledSkill,attacker,true);
				this.scheduledSkill = null;
			} else {
				this.AttackExecute(attacker,defender);
			}
			if(attacker.turnRecharge != null) {
				var _g = 0;
				var _g1 = attacker.turnRecharge.length;
				while(_g < _g1) {
					var i = _g++;
					if(attacker.turnRecharge[i] > 0) {
						attacker.turnRecharge[i]--;
					}
				}
			}
			var attackerBuffChanged = false;
			var _g = 0;
			var _g1 = attacker.buffs.length;
			while(_g < _g1) {
				var b = _g++;
				var bu = attacker.buffs[b];
				if(attacker.buffs[b] != null) {
					bu.duration -= 1;
					if(bu.duration <= 0) {
						attacker.buffs[b] = null;
						attackerBuffChanged = true;
					}
				}
			}
			while(HxOverrides.remove(attacker.buffs,null)) {
			}
			if(attackerBuffChanged) {
				this.RecalculateAttributes(attacker);
			}
		} else if(this.wdata.hero.turnRecharge != null) {
			this.wdata.hero.turnRecharge.length = 0;
		}
		return "";
	}
	,AddMod: function(modBase,statAdd,statMul,seed) {
		var mulAdd = modBase.statMultipliers;
		var rand = this.fixedRandom;
		rand.set_seed(seed);
		if(mulAdd != null) {
			var h = mulAdd.h;
			var m_h = h;
			var m_keys = Object.keys(h);
			var m_length = m_keys.length;
			var m_current = 0;
			while(m_current < m_length) {
				var key = m_keys[m_current++];
				var m_key = key;
				var m_value = m_h[key];
				var val = RandomExtender.Range(rand,mulAdd.h[m_key]);
				if(Object.prototype.hasOwnProperty.call(statMul.h,m_key)) {
					var v = statMul.h[m_key] * val / 100 | 0;
					statMul.h[m_key] = v;
				} else {
					statMul.h[m_key] = val;
				}
			}
		}
		if(modBase.statAdds != null) {
			var h = modBase.statAdds.h;
			var m_h = h;
			var m_keys = Object.keys(h);
			var m_length = m_keys.length;
			var m_current = 0;
			while(m_current < m_length) {
				var key = m_keys[m_current++];
				var m_key = key;
				var m_value = m_h[key];
				var val = RandomExtender.Range(rand,modBase.statAdds.h[m_key]);
				if(Object.prototype.hasOwnProperty.call(statAdd.h,m_key)) {
					var v = statAdd.h[m_key] + val | 0;
					statAdd.h[m_key] = v;
				} else {
					statAdd.h[m_key] = val;
				}
			}
		}
	}
	,LimitBreakEquipment: function(pos) {
		var e = this.wdata.hero.equipment[pos];
		BattleManager.LimitBreak(e,this.wdata);
	}
	,UpgradeEquipment: function(pos) {
		var e = this.wdata.hero.equipment[pos];
		BattleManager.Upgrade(e,this.wdata);
		this.RecalculateAttributes(this.wdata.hero);
	}
	,DiscardSingleEquipment: function(pos) {
		var e = this.wdata.hero.equipment[pos];
		HxOverrides.remove(this.wdata.hero.equipment,e);
		var _g = 0;
		var _g1 = this.wdata.hero.equipmentSlots.length;
		while(_g < _g1) {
			var i = _g++;
			if(this.wdata.hero.equipmentSlots[i] >= pos) {
				this.wdata.hero.equipmentSlots[i]--;
			}
		}
		if(e != null) {
			this.equipmentToDiscard.push(e);
		}
	}
	,SellSingleEquipment: function(pos) {
		this.DiscardSingleEquipment(pos);
		var prize = BattleManager.GetSellPrize(this.wdata.hero.equipment[pos],this.wdata);
		this.wdata.currency.currencies.h["Lagrima"].value += prize;
	}
	,SellEquipment: function(pos) {
		this.SellSingleEquipment(pos);
		this.RecalculateAttributes(this.wdata.hero);
	}
	,ToggleEquipped: function(pos) {
		var slot = this.wdata.hero.equipment[pos].type;
		if(this.wdata.hero.equipmentSlots[slot] == pos) {
			this.wdata.hero.equipmentSlots[slot] = -1;
		} else {
			this.wdata.hero.equipmentSlots[slot] = pos;
		}
		this.UseMP(this.wdata.hero,9999,false);
		this.RecalculateAttributes(this.wdata.hero);
	}
	,IsEquipped: function(pos) {
		return this.wdata.hero.equipmentSlots.indexOf(pos) != -1;
	}
	,AddEvent: function(eventType) {
		var e = new GameEvent(eventType);
		this.events.push(e);
		return e;
	}
	,BaseInformationFormattedString: function() {
		var hero = this.wdata.hero;
		var maxArea = this.wdata.maxArea;
		var battleArea = this.wdata.battleArea;
		var enemy = this.wdata.enemy;
		var level = hero.level;
		var xp = hero.xp.value;
		var xpmax = hero.xp.calculatedMax;
		var baseInfo = this.CharacterBaseInfoFormattedString(hero);
		var areaText = "";
		var battleAreaShow = battleArea + 1;
		var maxAreaShow = maxArea + 1;
		if(maxArea > 0) {
			areaText = "Area: " + battleAreaShow + " / " + maxAreaShow;
		}
		var output = "" + areaText + "\r\n\r\n\n\nPlayer \r\n\tlevel: " + level + "\r\n\txp: " + xp + " / " + xpmax + "\r\n" + baseInfo;
		baseInfo = this.CharacterBaseInfoFormattedString(enemy);
		output += "\n\n";
		output += "Enemy\r\n" + baseInfo;
		return output;
	}
	,CharacterBaseInfoFormattedString: function(actor) {
		var life = actor.attributesCalculated.h["Life"];
		var lifeM = actor.attributesCalculated.h["LifeMax"];
		var attack = actor.attributesCalculated.h["Attack"];
		return "\t Life: " + life + " / " + lifeM + "\r\n\tAttack: " + attack;
	}
	,update: function(delta) {
		this.wdata.timeCount += delta;
		var _g = 0;
		var _g1 = this.equipmentToDiscard;
		while(_g < _g1.length) {
			var e = _g1[_g];
			++_g;
			if(e.outsideSystems != null) {
				if(Object.prototype.hasOwnProperty.call(e.outsideSystems.h,"skillset")) {
					var skillsetpos = e.outsideSystems.h["skillset"];
					this.wdata.skillSets[skillsetpos] = null;
				}
				if(Object.prototype.hasOwnProperty.call(e.outsideSystems.h,"level")) {
					var level = e.outsideSystems.h["level"];
					this.wdata.equipLevels[level] = null;
				}
			}
		}
		this.equipmentToDiscard.length = 0;
		if(this.wdata.regionProgress == null) {
			this.wdata.regionProgress = [];
		}
		while(this.wdata.regionProgress.length <= this.wdata.battleAreaRegion) this.wdata.regionProgress.push({ area : -1, maxArea : -1, amountEnemyKilledInArea : -1, maxAreaRecord : -1, maxAreaOnPrestigeRecord : []});
		this.wdata.regionProgress[this.wdata.battleAreaRegion].area = this.wdata.battleArea;
		var recalculate = false;
		if(this.wdata.regionProgress[this.wdata.battleAreaRegion].maxArea != this.wdata.maxArea) {
			recalculate = true;
			this.wdata.regionProgress[this.wdata.battleAreaRegion].maxArea = this.wdata.maxArea;
		}
		var _g = 0;
		var _g1 = this.wdata.regionProgress;
		while(_g < _g1.length) {
			var rp = _g1[_g];
			++_g;
			if(rp != null) {
				if(rp.maxArea > rp.maxAreaRecord) {
					rp.maxAreaRecord = rp.maxArea;
					recalculate = true;
				}
			}
		}
		if(recalculate) {
			this.RecalculateAttributes(this.wdata.hero);
		}
		this.wdata.regionProgress[this.wdata.battleAreaRegion].amountEnemyKilledInArea = this.wdata.killedInArea[this.wdata.battleArea];
		if(this.regionRequirements.length >= this.wdata.battleAreaRegionMax) {
			var maxArea = this.wdata.regionProgress[0].maxArea;
			if(maxArea > this.regionRequirements[this.wdata.battleAreaRegionMax]) {
				this.wdata.battleAreaRegionMax++;
				this.AddEvent(EventTypes.RegionUnlock).data = this.wdata.battleAreaRegionMax - 1;
			}
		}
		this.canAdvance = this.wdata.battleArea < this.wdata.maxArea;
		this.canRetreat = this.wdata.battleArea > 0;
		this.canLevelUp = this.wdata.hero.xp.value >= this.wdata.hero.xp.calculatedMax;
		var hasEquipment = this.wdata.hero.equipment.length > 1;
		var lu = this.wdata.playerActions.h["tabequipment"];
		lu.enabled = hasEquipment;
		lu.visible = lu.enabled || lu.visible;
		var lu = this.wdata.playerActions.h["levelup"];
		lu.enabled = this.canLevelUp;
		lu.visible = this.canLevelUp || lu.visible;
		var lu = this.wdata.playerActions.h["prestige"];
		lu.enabled = this.wdata.hero.level >= this.GetLevelRequirementForPrestige();
		lu.visible = lu.enabled || lu.visible;
		var _g = 0;
		while(_g < 7) {
			var i = _g++;
			var buttonId = i;
			var lu = this.wdata.playerActions.h["battleaction_" + i];
			var skillUsable = false;
			var skillVisible = false;
			var skillButtonMode = 0;
			if(this.wdata.hero.level < this.skillSlotUnlocklevel[i]) {
				skillButtonMode = 1;
			}
			if(this.wdata.hero.usableSkills[i] != null) {
				if(this.wdata.hero.level >= this.skillSlotUnlocklevel[i]) {
					if(this.wdata.hero.attributesCalculated.h["MPRechargeCount"] >= 10000) {
						skillUsable = true;
					}
				}
				if(i == 0 || this.wdata.hero.level >= this.skillSlotUnlocklevel[i - 1]) {
					skillVisible = true;
				}
				var sb = this.GetSkillBase(this.wdata.hero.usableSkills[i].id);
				if(sb.turnRecharge > 0) {
					if(this.wdata.hero.turnRecharge == null) {
						this.wdata.hero.turnRecharge = [];
					}
					if(this.wdata.hero.turnRecharge[i] > 0) {
						skillUsable = false;
					}
				}
				if(skillUsable && skillVisible && this.wdata.enemy == null) {
					var efs = sb.effects;
					if(efs == null) {
						efs = sb.activeEffect;
					}
					var _g1 = 0;
					while(_g1 < efs.length) {
						var e = efs[_g1];
						++_g1;
						if(e.target == Target.ENEMY) {
							skillUsable = false;
							break;
						}
					}
				}
			}
			if(this.scheduledSkill != null) {
				skillUsable = false;
				if(this.scheduledSkill == this.wdata.hero.usableSkills[i]) {
					skillButtonMode = 2;
				}
			}
			lu.enabled = skillUsable;
			lu.visible = skillVisible;
			lu.mode = skillButtonMode;
		}
		var lu = this.wdata.playerActions.h["advance"];
		lu.visible = this.canAdvance || lu.visible;
		lu.enabled = this.canAdvance;
		var lu = this.wdata.playerActions.h["retreat"];
		lu.enabled = this.canRetreat;
		lu.visible = lu.enabled || lu.visible;
		var lu = this.wdata.playerActions.h["repeat"];
		lu.enabled = this.wdata.maxArea > this.wdata.battleArea && this.wdata.killedInArea[this.wdata.battleArea] > 0;
		lu.visible = lu.enabled || lu.visible;
		var lu = this.wdata.playerActions.h["sleep"];
		if(this.wdata.sleeping == true) {
			lu.mode = 1;
			lu.enabled = true;
		} else {
			lu.mode = 0;
			lu.enabled = this.wdata.hero.attributesCalculated.h["Life"] < this.wdata.hero.attributesCalculated.h["LifeMax"] && this.wdata.recovering == false;
		}
		lu.visible = lu.enabled || lu.visible;
		if(this.wdata.recovering && this.wdata.hero.attributesCalculated.h["Life"] >= this.wdata.hero.attributesCalculated.h["LifeMax"]) {
			var v = this.wdata.hero.attributesCalculated.h["LifeMax"];
			this.wdata.hero.attributesCalculated.h["Life"] = v;
			this.wdata.recovering = false;
		}
		var mrc = this.wdata.hero.attributesCalculated.h["MPRechargeCount"];
		if(mrc < 10000) {
			mrc += this.wdata.hero.attributesCalculated.h["MPRecharge"] * delta * 5 | 0;
			this.wdata.hero.attributesCalculated.h["MPRechargeCount"] = mrc;
			if(mrc >= 10000) {
				var v = this.wdata.hero.attributesCalculated.h["MPMax"];
				this.wdata.hero.attributesCalculated.h["MP"] = v;
			}
		}
		if(this.wdata.timeCount >= this.timePeriod) {
			this.wdata.timeCount = 0;
			return this.advance();
		}
		if(this.dirty) {
			this.dirty = false;
		}
		return null;
	}
	,DefaultConfiguration: function() {
	}
	,getPlayerTimesKilled: function() {
		return this.wdata.playerTimesKilled;
	}
	,RetreatArea: function() {
		if(this.wdata.battleArea > 0) {
			this.ChangeBattleArea(this.wdata.battleArea - 1);
		}
	}
	,LevelUp: function() {
		if(this.canLevelUp) {
			this.ForceLevelUp();
		}
	}
	,ForceLevelUp: function() {
		var hero = this.wdata.hero;
		hero.xp.value -= hero.xp.calculatedMax;
		hero.level++;
		this.AddEvent(EventTypes.ActorLevelUp);
		this.RecalculateAttributes(hero);
		ResourceLogic.recalculateScalingResource(hero.level,hero.xp);
		var v = hero.attributesCalculated.h["LifeMax"];
		hero.attributesCalculated.h["Life"] = v;
		var v = hero.attributesCalculated.h["MPMax"];
		hero.attributesCalculated.h["MP"] = v;
		hero.attributesCalculated.h["MPRechargeCount"] = 10000;
	}
	,RecalculateAttributes: function(actor) {
		var _g = 0;
		var _g1 = this.volatileAttributeList.length;
		while(_g < _g1) {
			var i = _g++;
			this.volatileAttributeAux[i] = actor.attributesCalculated.h[this.volatileAttributeList[i]];
			if(this.volatileAttributeAux[i] >= 0 == false) {
				this.volatileAttributeAux[i] = 0;
			}
		}
		if(actor == this.wdata.hero) {
			var skillSetPos = this.wdata.hero.equipmentSlots[2];
			if(skillSetPos >= 0) {
				var skillSet = this.wdata.skillSets[this.wdata.hero.equipment[skillSetPos].outsideSystems.h["skillset"]];
				this.wdata.hero.usableSkills = skillSet.skills;
			}
		}
		if(actor.attributesBase == actor.attributesCalculated) {
			actor.attributesCalculated = new haxe_ds_StringMap();
		}
		actor.attributesCalculated.h = Object.create(null);
		if(actor == this.wdata.hero) {
			var actor1 = actor.attributesBase;
			var _g = new haxe_ds_StringMap();
			_g.h["Attack"] = 1;
			_g.h["LifeMax"] = 5;
			_g.h["Life"] = 5;
			_g.h["Speed"] = 0;
			_g.h["Defense"] = 0;
			_g.h["MagicAttack"] = 1;
			_g.h["MagicDefense"] = 0;
			_g.h["SpeedCount"] = 0;
			_g.h["Piercing"] = 0;
			_g.h["MPMax"] = 2;
			AttributeLogic.Add(actor1,_g,actor.level,actor.attributesCalculated);
		} else {
			var h = actor.attributesBase.h;
			var _g2_h = h;
			var _g2_keys = Object.keys(h);
			var _g2_length = _g2_keys.length;
			var _g2_current = 0;
			while(_g2_current < _g2_length) {
				var key = _g2_keys[_g2_current++];
				var _g3_key = key;
				var _g3_value = _g2_h[key];
				var key1 = _g3_key;
				var value = _g3_value;
				actor.attributesCalculated.h[key1] = value;
			}
		}
		if(actor == this.wdata.hero) {
			var _g = 0;
			var _g1 = this.wdata.regionProgress.length;
			while(_g < _g1) {
				var i = _g++;
				var pro = this.wdata.regionProgress[i];
				var prize = this.regionPrizes[i];
				var bonusLevel = 0;
				if(prize.statBonus != null) {
					if(pro.maxArea >= 2) {
						bonusLevel += pro.maxArea - 1;
					}
					var _g2 = 0;
					var _g3 = pro.maxAreaOnPrestigeRecord;
					while(_g2 < _g3.length) {
						var maxAreaPrestiges = _g3[_g2];
						++_g2;
						if(maxAreaPrestiges >= 2) {
							bonusLevel += maxAreaPrestiges - 1;
						}
					}
					AttributeLogic.Add(actor.attributesCalculated,prize.statBonus,bonusLevel,actor.attributesCalculated);
				}
			}
		}
		if(actor.equipmentSlots != null) {
			var _g = 0;
			var _g1 = actor.equipmentSlots;
			while(_g < _g1.length) {
				var es = _g1[_g];
				++_g;
				var e = actor.equipment[es];
				if(e != null) {
					AttributeLogic.Add(actor.attributesCalculated,e.attributes,1,actor.attributesCalculated);
				}
			}
		}
		var _g = 0;
		var _g1 = actor.buffs;
		while(_g < _g1.length) {
			var b = _g1[_g];
			++_g;
			if(b.addStats != null) {
				AttributeLogic.Add(actor.attributesCalculated,b.addStats,1,actor.attributesCalculated);
			}
		}
		if(actor.equipmentSlots != null) {
			var _g = 0;
			var _g1 = actor.equipmentSlots;
			while(_g < _g1.length) {
				var es = _g1[_g];
				++_g;
				var e = actor.equipment[es];
				if(e != null) {
					if(e.attributeMultiplier != null) {
						var h = e.attributeMultiplier.h;
						var a_h = h;
						var a_keys = Object.keys(h);
						var a_length = a_keys.length;
						var a_current = 0;
						while(a_current < a_length) {
							var key = a_keys[a_current++];
							var a_key = key;
							var a_value = a_h[key];
							var v = actor.attributesCalculated.h[a_key] * a_value / 100 | 0;
							actor.attributesCalculated.h[a_key] = v;
						}
					}
				}
			}
		}
		var _g = 0;
		var _g1 = actor.buffs;
		while(_g < _g1.length) {
			var b = _g1[_g];
			++_g;
			if(b.mulStats != null) {
				var h = b.mulStats.h;
				var a_h = h;
				var a_keys = Object.keys(h);
				var a_length = a_keys.length;
				var a_current = 0;
				while(a_current < a_length) {
					var key = a_keys[a_current++];
					var a_key = key;
					var a_value = a_h[key];
					var v = actor.attributesCalculated.h[a_key] * a_value / 100 | 0;
					actor.attributesCalculated.h[a_key] = v;
				}
			}
		}
		var _g = 0;
		var _g1 = this.volatileAttributeList.length;
		while(_g < _g1) {
			var i = _g++;
			var v = this.volatileAttributeAux[i];
			actor.attributesCalculated.h[this.volatileAttributeList[i]] = v;
		}
	}
	,AdvanceArea: function() {
		this.ChangeBattleArea(this.wdata.battleArea + 1);
	}
	,DiscardWorseEquipment: function() {
		var i = 0;
		var times = 0;
		while(i < this.wdata.hero.equipment.length) {
			++times;
			if(times > 500) {
				console.log("src/logic/BattleManager.hx:1738:","LOOP SCAPE");
				break;
			}
			var e = this.wdata.hero.equipment[i];
			if(e == null) {
				++i;
				continue;
			}
			if(e.type == 2) {
				++i;
				continue;
			}
			var j = i + 1;
			var times2 = 0;
			while(j < this.wdata.hero.equipment.length) {
				++times2;
				if(times2 > 500) {
					console.log("src/logic/BattleManager.hx:1755:","LOOP SCAPE 2");
					break;
				}
				var e2 = this.wdata.hero.equipment[j];
				if(e2 == null) {
					++j;
					continue;
				}
				if(e.type != e2.type) {
					++j;
					continue;
				}
				var r = this.CompareEquipmentStrength(e,e2);
				if(r == 1 || r == 0) {
					if(this.wdata.hero.equipmentSlots.indexOf(j) != -1) {
						++j;
						continue;
					}
					this.SellSingleEquipment(j);
					continue;
				}
				if(r == 2) {
					if(this.wdata.hero.equipmentSlots.indexOf(i) != -1) {
						++j;
						continue;
					}
					this.SellSingleEquipment(i);
					--i;
					break;
				}
				++j;
			}
			++i;
		}
	}
	,CompareEquipmentStrength: function(e1,e2) {
		var e1Superior = 0;
		var e2Superior = 0;
		var mapAttr1 = e1.attributes;
		var mapAttr2 = e2.attributes;
		var h = mapAttr1.h;
		var attrKey_h = h;
		var attrKey_keys = Object.keys(h);
		var attrKey_length = attrKey_keys.length;
		var attrKey_current = 0;
		while(attrKey_current < attrKey_length) {
			var attrKey = attrKey_keys[attrKey_current++];
			if(Object.prototype.hasOwnProperty.call(mapAttr2.h,attrKey)) {
				if(mapAttr1.h[attrKey] > mapAttr2.h[attrKey]) {
					e1Superior = 1;
				}
				if(mapAttr1.h[attrKey] < mapAttr2.h[attrKey]) {
					e2Superior = 1;
				}
			} else {
				e1Superior = 1;
			}
			if(e1Superior == 1 && e2Superior == 1) {
				return -1;
			}
		}
		var h = mapAttr2.h;
		var attrKey_h = h;
		var attrKey_keys = Object.keys(h);
		var attrKey_length = attrKey_keys.length;
		var attrKey_current = 0;
		while(attrKey_current < attrKey_length) {
			var attrKey = attrKey_keys[attrKey_current++];
			if(Object.prototype.hasOwnProperty.call(mapAttr1.h,attrKey)) {
				if(mapAttr1.h[attrKey] > mapAttr2.h[attrKey]) {
					e1Superior = 1;
				}
				if(mapAttr1.h[attrKey] < mapAttr2.h[attrKey]) {
					e2Superior = 1;
				}
			} else {
				e2Superior = 1;
			}
			if(e1Superior == 1 && e2Superior == 1) {
				return -1;
			}
		}
		var mapAttr1 = e1.attributeMultiplier;
		var mapAttr2 = e2.attributeMultiplier;
		if(mapAttr1 != null || mapAttr2 != null) {
			if(mapAttr2 == null) {
				mapAttr2 = new haxe_ds_StringMap();
			}
			if(mapAttr1 == null) {
				mapAttr1 = new haxe_ds_StringMap();
			}
			var h = mapAttr1.h;
			var attrKey_h = h;
			var attrKey_keys = Object.keys(h);
			var attrKey_length = attrKey_keys.length;
			var attrKey_current = 0;
			while(attrKey_current < attrKey_length) {
				var attrKey = attrKey_keys[attrKey_current++];
				if(Object.prototype.hasOwnProperty.call(mapAttr2.h,attrKey)) {
					if(mapAttr1.h[attrKey] > mapAttr2.h[attrKey]) {
						e1Superior = 1;
					}
					if(mapAttr1.h[attrKey] < mapAttr2.h[attrKey]) {
						e2Superior = 1;
					}
				} else {
					if(mapAttr1.h[attrKey] > 100) {
						e1Superior = 1;
					}
					if(mapAttr1.h[attrKey] < 100) {
						e2Superior = 1;
					}
				}
				if(e1Superior == 1 && e2Superior == 1) {
					return -1;
				}
			}
			var h = mapAttr2.h;
			var attrKey_h = h;
			var attrKey_keys = Object.keys(h);
			var attrKey_length = attrKey_keys.length;
			var attrKey_current = 0;
			while(attrKey_current < attrKey_length) {
				var attrKey = attrKey_keys[attrKey_current++];
				if(Object.prototype.hasOwnProperty.call(mapAttr1.h,attrKey)) {
					if(mapAttr1.h[attrKey] > mapAttr2.h[attrKey]) {
						e1Superior = 1;
					}
					if(mapAttr1.h[attrKey] < mapAttr2.h[attrKey]) {
						e2Superior = 1;
					}
				} else {
					if(mapAttr2.h[attrKey] > 100) {
						e2Superior = 1;
					}
					if(mapAttr2.h[attrKey] < 100) {
						e1Superior = 1;
					}
				}
				if(e1Superior == 1 && e2Superior == 1) {
					return -1;
				}
			}
		}
		if(e1Superior == 1 && e2Superior == 0) {
			return 1;
		}
		if(e1Superior == 0 && e2Superior == 1) {
			return 2;
		}
		return 0;
	}
	,GetJsonPersistentData: function() {
		return JSON.stringify(this.wdata);
	}
	,SendJsonPersistentData: function(jsonString) {
		var loadedWdata = JSON.parse(jsonString);
		if(loadedWdata.worldVersion < 301) {
			loadedWdata.worldVersion = this.wdata.worldVersion;
			loadedWdata.sleeping = loadedWdata.sleeping == true;
		}
		if(loadedWdata.worldVersion >= 601 == false) {
			loadedWdata.regionProgress = [];
			loadedWdata.regionProgress.push({ area : loadedWdata.battleArea, maxArea : loadedWdata.maxArea, amountEnemyKilledInArea : loadedWdata.killedInArea[loadedWdata.battleArea], maxAreaRecord : loadedWdata.maxArea, maxAreaOnPrestigeRecord : []});
			loadedWdata.battleAreaRegion = 0;
			loadedWdata.battleArea = 0;
		}
		if(loadedWdata.worldVersion != this.wdata.worldVersion) {
			loadedWdata.enemy = null;
		}
		loadedWdata.worldVersion = this.wdata.worldVersion;
		this.wdata = loadedWdata;
		if(this.wdata.battleArea >= this.wdata.killedInArea.length) {
			this.wdata.battleArea = this.wdata.killedInArea.length - 1;
		}
		if(this.wdata.maxArea >= this.wdata.killedInArea.length) {
			this.wdata.maxArea = this.wdata.killedInArea.length - 1;
		}
		this.ReinitGameValues();
	}
};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(len == null) {
		len = s.length;
	} else if(len < 0) {
		if(pos == 0) {
			len = s.length + len;
		} else {
			return "";
		}
	}
	return s.substr(pos,len);
};
HxOverrides.remove = function(a,obj) {
	var i = a.indexOf(obj);
	if(i == -1) {
		return false;
	}
	a.splice(i,1);
	return true;
};
HxOverrides.now = function() {
	return Date.now();
};
var IntIterator = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIterator.__name__ = true;
IntIterator.prototype = {
	hasNext: function() {
		return this.min < this.max;
	}
	,next: function() {
		return this.min++;
	}
};
var MainTest = function() { };
MainTest.__name__ = true;
MainTest.GetBattleManager = function() {
	var bm = new BattleManager();
	bm.DefaultConfiguration();
	var proto = new PrototypeItemMaker();
	var skills = new PrototypeSkillMaker();
	skills.init();
	proto.MakeItems();
	bm.itemBases = proto.items;
	bm.modBases = proto.mods;
	bm.skillBases = skills.skills;
	return bm;
};
MainTest.main = function() {
	process.stdout.write("resource load text");
	process.stdout.write("\n");
	var sj = haxe_Resource.getString("storyjson");
	JSON.parse(sj);
	process.stdout.write("Discard equip slot consistency");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Life"] = 3;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	bm.wdata.hero.equipmentSlots[0] = 2;
	bm.wdata.hero.equipmentSlots[1] = 0;
	var attributes0 = haxe_ds_StringMap.createCopy(bm.wdata.hero.equipment[bm.wdata.hero.equipmentSlots[0]].attributes.h);
	var attributes1 = haxe_ds_StringMap.createCopy(bm.wdata.hero.equipment[bm.wdata.hero.equipmentSlots[1]].attributes.h);
	bm.SellEquipment(1);
	if(attributes0.h["Attack"] != bm.wdata.hero.equipment[bm.wdata.hero.equipmentSlots[0]].attributes.h["Attack"]) {
		process.stdout.write("Error0");
		process.stdout.write("\n");
	}
	if(attributes1.h["Attack"] != bm.wdata.hero.equipment[bm.wdata.hero.equipmentSlots[1]].attributes.h["Attack"]) {
		process.stdout.write("Error1");
		process.stdout.write("\n");
	}
	process.stdout.write("Discard worse equip tests");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var oldEquipN = bm.wdata.hero.equipment.length;
	bm.DiscardWorseEquipment();
	var equipN = bm.wdata.hero.equipment.length;
	var numberOfNullEquipment = oldEquipN - equipN;
	if(numberOfNullEquipment != 0) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 0 (aa)"));
		process.stdout.write("\n");
	}
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Life"] = 3;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	oldEquipN = bm.wdata.hero.equipment.length;
	bm.DiscardWorseEquipment();
	equipN = bm.wdata.hero.equipment.length;
	numberOfNullEquipment = oldEquipN - equipN;
	if(numberOfNullEquipment != 2) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 2 (a)"));
		process.stdout.write("\n");
		process.stdout.write(Std.string("" + oldEquipN + " " + equipN));
		process.stdout.write("\n");
	}
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Life"] = 2;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Defense"] = 1;
	bm1.push({ seen : 0, type : 0, requiredAttributes : null, attributes : _g});
	var oldEquipN = bm.wdata.hero.equipment.length;
	bm.DiscardWorseEquipment();
	var equipN = bm.wdata.hero.equipment.length;
	numberOfNullEquipment = oldEquipN - equipN;
	if(numberOfNullEquipment != 0) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 0 (b)"));
		process.stdout.write("\n");
		process.stdout.write(Std.string("" + oldEquipN + " " + equipN));
		process.stdout.write("\n");
	}
	process.stdout.write("Prestige unlock test");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	var a = bm.wdata.playerActions.h["prestige"];
	if(a.enabled == true) {
		process.stdout.write("Error: prestige wrong 1");
		process.stdout.write("\n");
	}
	bm.wdata.hero.level = 15;
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	if(a.enabled == false) {
		process.stdout.write("Error: prestige wrong 2");
		process.stdout.write("\n");
	}
	bm.PrestigeExecute();
	bm.update(0.9);
	bm.update(0.9);
	if(a.enabled == true) {
		process.stdout.write("Error: prestige wrong 3");
		process.stdout.write("\n");
		var v = "Level Requirement for prestige " + bm.GetLevelRequirementForPrestige();
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
	}
	bm.wdata.hero.level = 15;
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	if(a.enabled == true) {
		process.stdout.write("Error: prestige wrong 4");
		process.stdout.write("\n");
	}
	bm.wdata.hero.level = 25;
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	if(a.enabled == false) {
		process.stdout.write("Error: prestige wrong 5");
		process.stdout.write("\n");
	}
	process.stdout.write("Prestige permanent stat test");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	bm.wdata.hero.level = 200;
	bm.RecalculateAttributes(bm.wdata.hero);
	process.stdout.write("Accessing Speed 0");
	process.stdout.write("\n");
	if(bm.wdata.hero.attributesCalculated.h["Speed"] != 20) {
		process.stdout.write("Error: wrong speed 0");
		process.stdout.write("\n");
	}
	bm.changeRegion(0);
	bm.changeRegion(1);
	bm.ChangeBattleArea(1);
	var _g = 1;
	while(_g < 600) {
		var i = _g++;
		bm.update(0.9);
	}
	process.stdout.write("Accessing Speed 1");
	process.stdout.write("\n");
	if(bm.wdata.hero.attributesCalculated.h["Speed"] != 22) {
		process.stdout.write("Error: wrong speed 1");
		process.stdout.write("\n");
	}
	bm.PrestigeExecute();
	process.stdout.write("Accessing Speed 2");
	process.stdout.write("\n");
	if(bm.wdata.hero.attributesCalculated.h["Speed"] != 22) {
		process.stdout.write("Error: wrong speed 2");
		process.stdout.write("\n");
		var v = "speed is: " + bm.wdata.hero.attributesCalculated.h["Speed"];
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
	}
	bm.wdata.hero.level = 200;
	bm.RecalculateAttributes(bm.wdata.hero);
	bm.changeRegion(1);
	bm.ChangeBattleArea(1);
	var _g = 1;
	while(_g < 600) {
		var i = _g++;
		bm.update(0.9);
	}
	process.stdout.write("Accessing Speed 3");
	process.stdout.write("\n");
	if(bm.wdata.hero.attributesCalculated.h["Speed"] != 24) {
		process.stdout.write("Error: wrong speed 3");
		process.stdout.write("\n");
		var v = "speed is: " + bm.wdata.hero.attributesCalculated.h["Speed"];
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
		var v = "max area in region 1 is: " + bm.wdata.regionProgress[1].maxArea;
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
		var v = bm.wdata.hero;
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
		return;
	}
	bm.ChangeBattleArea(2);
	var _g = 1;
	while(_g < 600) {
		var i = _g++;
		bm.update(0.9);
	}
	process.stdout.write("Accessing Speed 4");
	process.stdout.write("\n");
	if(bm.wdata.hero.attributesCalculated.h["Speed"] != 26) {
		process.stdout.write("Error: wrong speed 4");
		process.stdout.write("\n");
		var v = "speed is: " + bm.wdata.hero.attributesCalculated.h["Speed"];
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
	}
	process.stdout.write("Save legacy test");
	process.stdout.write("\n");
	var _g = 0;
	var _g1 = js_node_Fs.readdirSync("saves/");
	while(_g < _g1.length) {
		var file = _g1[_g];
		++_g;
		console.log("test/MainTest.hx:230:",file);
		var path = haxe_io_Path.join(["saves/",file]);
		var json = js_node_Fs.readFileSync(path,{ encoding : "utf8"});
		var bm = MainTest.GetBattleManager();
		bm.SendJsonPersistentData(SaveAssistant.GetPersistenceMaster(json).jsonGameplay);
		var _g2 = 1;
		while(_g2 < 400) {
			var i = _g2++;
			bm.update(0.9);
		}
	}
	process.stdout.write("Test region progress");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	var _g = 0;
	var _g1 = bm.wdata.regionProgress.length;
	while(_g < _g1) {
		var i = _g++;
		bm.wdata.regionProgress[i].maxArea = 20;
	}
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	process.stdout.write("Hard area death test");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	bm.ChangeBattleArea(100);
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	if(bm.getPlayerTimesKilled() < 5) {
		var v = "ERROR: Did not die! " + bm.getPlayerTimesKilled();
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
	}
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.ForceLevelUp();
	}
	var _g = 1;
	while(_g < 400) {
		var i = _g++;
		bm.update(0.9);
	}
	var json = bm.GetJsonPersistentData();
	var fileName = "saves/basic" + bm.wdata.worldVersion + ".json";
	var pm = { worldVersion : bm.wdata.worldVersion, jsonGameplay : json, jsonStory : null};
	js_node_Fs.writeFileSync(fileName,JSON.stringify(pm));
	process.stdout.write("Pierce test");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	bm.ChangeBattleArea(8);
	bm.update(0.9);
	var oldLife = bm.wdata.enemy.attributesCalculated.h["Life"];
	bm.wdata.enemy.attributesCalculated.h["Defense"] = 6;
	bm.wdata.hero.attributesCalculated.h["Attack"] = 5;
	bm.AttackExecute(bm.wdata.hero,bm.wdata.enemy,100,0,100);
	bm.AttackExecute(bm.wdata.hero,bm.wdata.enemy,100,0,100);
	if(oldLife != bm.wdata.enemy.attributesCalculated.h["Life"]) {
		process.stdout.write("ERROR: Pierce 1");
		process.stdout.write("\n");
	}
	bm.wdata.hero.attributesCalculated.h["Piercing"] = 50;
	bm.AttackExecute(bm.wdata.hero,bm.wdata.enemy,100,0,100);
	if(oldLife - bm.wdata.enemy.attributesCalculated.h["Life"] != 2) {
		process.stdout.write("ERROR: Pierce 2");
		process.stdout.write("\n");
	}
	var oldLife = bm.wdata.enemy.attributesCalculated.h["Life"];
	bm.wdata.hero.attributesCalculated.h["Piercing"] = 0;
	bm.UseSkill({ id : "Sharpen", level : 1},bm.wdata.hero);
	bm.AttackExecute(bm.wdata.hero,bm.wdata.enemy,100,0,100);
	if(oldLife - bm.wdata.enemy.attributesCalculated.h["Life"] != 2) {
		process.stdout.write("ERROR: Pierce 3");
		process.stdout.write("\n");
	}
	process.stdout.write("Easy area no death");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	bm.ChangeBattleArea(1);
	bm.update(0.9);
	bm.update(0.9);
	bm.update(0.9);
	if(bm.getPlayerTimesKilled() > 0) {
		process.stdout.write("ERROR: Died");
		process.stdout.write("\n");
	}
	process.stdout.write("Level up Stat Test");
	process.stdout.write("\n");
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 5;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	var stats = _g;
	var hero_level = 1;
	var hero_attributesBase = stats;
	var hero_equipmentSlots = null;
	var hero_equipment = null;
	var hero_xp = ResourceLogic.getExponentialResource(1.5,1,5);
	var hero_attributesCalculated = haxe_ds_StringMap.createCopy(stats.h);
	var hero_reference = new ActorReference(0,0);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,1,hero_attributesCalculated);
	if(hero_attributesCalculated.h["Attack"] != 6) {
		process.stdout.write("ERROR: Calculated Attack Value Wrong");
		process.stdout.write("\n");
	}
	if(hero_attributesBase.h["Attack"] != 5) {
		process.stdout.write("ERROR: Base Attack Value Modified");
		process.stdout.write("\n");
	}
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,1,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,2,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,3,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,4,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,5,hero_attributesCalculated);
	if(hero_attributesCalculated.h["Attack"] != 10) {
		process.stdout.write("ERROR: Calculated Attack Value Wrong");
		process.stdout.write("\n");
	}
	if(hero_attributesBase.h["Attack"] != 5) {
		process.stdout.write("ERROR: Base Attack Value Modified");
		process.stdout.write("\n");
	}
	process.stdout.write("Json parsing save data tests");
	process.stdout.write("\n");
	var bm = MainTest.GetBattleManager();
	var json0 = bm.GetJsonPersistentData();
	bm.ChangeBattleArea(1);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.ChangeBattleArea(20);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	bm.update(5);
	var battleArea = bm.wdata.battleArea;
	var json = bm.GetJsonPersistentData();
	bm.SendJsonPersistentData(json);
	if(bm.wdata.battleArea != battleArea) {
		process.stdout.write("ERROR: Battle Area corrupted when loading");
		process.stdout.write("\n");
		process.stdout.write(Std.string("ERROR: Battle Area before " + battleArea));
		process.stdout.write("\n");
		var v = "ERROR: Battle Area after " + bm.wdata.battleArea;
		process.stdout.write(Std.string(v));
		process.stdout.write("\n");
	}
	var json2 = bm.GetJsonPersistentData();
	if(json0 == json2) {
		process.stdout.write("ERROR: Data not changed on game progress");
		process.stdout.write("\n");
	}
	if(json != json2) {
		process.stdout.write("ERROR: Data corrupted when loading");
		process.stdout.write("\n");
		console.log("test/MainTest.hx:390:","  _____ ");
		console.log("test/MainTest.hx:391:","  _____ ");
		console.log("test/MainTest.hx:392:","  _____ ");
		console.log("test/MainTest.hx:393:",json);
		console.log("test/MainTest.hx:394:","  _____ ");
		console.log("test/MainTest.hx:395:","  _____ ");
		console.log("test/MainTest.hx:396:","  _____ ");
		console.log("test/MainTest.hx:397:",json2);
		js_node_Fs.writeFileSync("error/json.json",json);
		js_node_Fs.writeFileSync("error/json2.json",json2);
	}
};
Math.__name__ = true;
var PrototypeItemMaker = function() {
	this.mods = [];
	this.items = [];
};
PrototypeItemMaker.__name__ = true;
PrototypeItemMaker.prototype = {
	R: function(min,max) {
		return { min : min, max : max};
	}
	,MakeItems: function() {
		var _g = new haxe_ds_StringMap();
		_g.h["LifeMax"] = 5;
		this.AddItem("Shirt",PrototypeItemMaker.itemType_Armor,_g);
		var _g = new haxe_ds_StringMap();
		_g.h["LifeMax"] = 3;
		_g.h["Defense"] = 0.6;
		this.AddItem("Vest",PrototypeItemMaker.itemType_Armor,_g);
		var _g = new haxe_ds_StringMap();
		_g.h["Defense"] = 1;
		this.AddItem("Plate",PrototypeItemMaker.itemType_Armor,_g);
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		this.AddItem("Broad Sword",PrototypeItemMaker.itemType_Weapon,_g);
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		var _g1 = new haxe_ds_StringMap();
		var value = this.R(115,115);
		_g1.h["Attack"] = value;
		var value = this.R(80,80);
		_g1.h["Speed"] = value;
		var value = this.R(20,20);
		_g1.h["Piercing"] = value;
		this.AddItem("Heavy Sword",PrototypeItemMaker.itemType_Weapon,_g,_g1);
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		var _g1 = new haxe_ds_StringMap();
		var value = this.R(150,150);
		_g1.h["Attack"] = value;
		var value = this.R(50,50);
		_g1.h["Speed"] = value;
		var value = this.R(50,50);
		_g1.h["Piercing"] = value;
		this.AddItem("Bastard Sword",PrototypeItemMaker.itemType_Weapon,_g,_g1);
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		var _g1 = new haxe_ds_StringMap();
		var value = this.R(70,70);
		_g1.h["Attack"] = value;
		var value = this.R(175,175);
		_g1.h["Speed"] = value;
		this.AddItem("Dagger",PrototypeItemMaker.itemType_Weapon,_g,_g1);
		var _g = new haxe_ds_StringMap();
		var value = this.R(105,110);
		_g.h["Attack"] = value;
		this.AddMod("of the Brute","Barbarian's",_g);
		var _g = new haxe_ds_StringMap();
		var value = this.R(120,150);
		_g.h["Defense"] = value;
		this.AddMod("of the Guardian","Golem's",_g);
		var _g = new haxe_ds_StringMap();
		var value = this.R(115,130);
		_g.h["Speed"] = value;
		this.AddMod("of the Thief","Zidane's",_g);
		var _g = new haxe_ds_StringMap();
		var value = this.R(130,150);
		_g.h["LifeMax"] = value;
		this.AddMod("of Nature","Aerith's",_g);
		var _g = new haxe_ds_StringMap();
		var value = this.R(115,125);
		_g.h["Attack"] = value;
		var value = this.R(70,90);
		_g.h["Defense"] = value;
		this.AddMod("of Rage","Beserker's",_g);
		var _g = new haxe_ds_StringMap();
		var value = this.R(1,5);
		_g.h["Blood"] = value;
		this.AddMod("of Blood","Sanguine",null,_g);
	}
	,AddMod: function(suffix,prefix,statMultipliers,statAdds) {
		this.mods.push({ prefix : prefix, suffix : suffix, statMultipliers : statMultipliers, statAdds : statAdds});
	}
	,AddItem: function(name,type,scalingStats,statMultipliers) {
		this.items.push({ name : name, type : type, scalingStats : scalingStats, statMultipliers : statMultipliers});
	}
};
var RandomExtender = function() { };
RandomExtender.__name__ = true;
RandomExtender.Range = function(random,range) {
	return random.randomInt(range.min,range.max);
};
var PrototypeSkillMaker = function() {
	this.skills = [];
};
PrototypeSkillMaker.__name__ = true;
PrototypeSkillMaker.prototype = {
	AddSkill: function(id,mpCost) {
	}
	,init: function() {
		this.skills.push({ id : "Regen", profession : "Priest", word : "Nature", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var strength = level * 3;
			var _g = new haxe_ds_StringMap();
			_g.h["Regen"] = strength;
			bm.AddBuff({ uniqueId : "regen", addStats : _g, mulStats : null, strength : strength, duration : 8},array[0]);
		}}], mpCost : 20});
		this.skills.push({ id : "Light Slash", profession : "Warrior", word : "Red", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			var strength = level * 5;
			bm.AttackExecute(actor,array[0],50,5 + level,100);
		}}], turnRecharge : 1, mpCost : 5});
		this.skills.push({ id : "Slash", profession : "Warrior", word : "Red", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			var strength = level * 10;
			bm.AttackExecute(actor,array[0],90 + strength,strength,100);
		}}], turnRecharge : 1, mpCost : 15});
		this.skills.push({ id : "Heavy Slash", profession : "Warrior", word : "Red", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			bm.AttackExecute(actor,array[0],100 + level * 30,level * 15,100);
		}}], turnRecharge : 1, mpCost : 40});
		this.skills.push({ id : "DeSpell", profession : "Unbuffer", word : "Witchhunt", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			var strength = level * 30;
			bm.RemoveBuffs(array[0]);
		}}], mpCost : 10});
		this.skills.push({ id : "Cure", profession : "Mage", word : "White", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var bonus = 5 + level * 10;
			var strength = level * bonus;
			bm.Heal(array[0],10,bonus);
		}}], mpCost : 15});
		this.skills.push({ id : "Haste", profession : "Wizard", word : "Time", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var bonus = 20;
			var multiplier = 90 + level * 10;
			var _g = new haxe_ds_StringMap();
			_g.h["Speed"] = bonus;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Speed"] = multiplier;
			bm.AddBuff({ uniqueId : "haste", addStats : _g, mulStats : _g1, strength : level, duration : 8},array[0]);
		}}], mpCost : 45});
		this.skills.push({ id : "Bloodlust", profession : "Sanguiner", word : "Blood", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var multiplier = 90 + level * 10;
			var _g = new haxe_ds_StringMap();
			_g.h["Blood"] = 3;
			_g.h["Bloodthirst"] = multiplier;
			bm.AddBuff({ uniqueId : "bloodlust", addStats : _g, mulStats : null, strength : level, duration : 3},array[0]);
		}}], mpCost : 5});
		this.skills.push({ id : "Noblesse", profession : "Highborn", word : "Honour", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var _g = new haxe_ds_StringMap();
			_g.h["Defense"] = 3 + level * 2;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Attack"] = 150 + level * 25;
			bm.AddBuff({ uniqueId : "noblesse", addStats : _g, mulStats : _g1, strength : level, duration : 99, noble : true},array[0]);
		}}], mpCost : 5});
		this.skills.push({ id : "Protect", profession : "Defender", word : "Defense", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var bonus = level * 5;
			var multiplier = 110;
			var _g = new haxe_ds_StringMap();
			_g.h["Defense"] = bonus;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Defense"] = multiplier;
			bm.AddBuff({ uniqueId : "protect", addStats : _g, mulStats : _g1, strength : level, duration : 8},array[0]);
		}}], mpCost : 25});
		this.skills.push({ id : "Sharpen", profession : "Smith", word : "Sharpness", effects : [{ target : Target.SELF, effectExecution : function(bm,level,actor,array) {
			var bonus = 100;
			var multiplier = 100 + 5 * level;
			var _g = new haxe_ds_StringMap();
			_g.h["Piercing"] = bonus;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Attack"] = multiplier;
			bm.AddBuff({ uniqueId : "pierce", addStats : _g, mulStats : _g1, strength : level, duration : 9},array[0]);
		}}], mpCost : 20});
		this.skills.push({ id : "Armor Break", profession : "Breaker", word : "Destruction", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			var _g = new haxe_ds_StringMap();
			_g.h["Defense"] = -level * 10;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Defense"] = 50;
			bm.AddBuff({ uniqueId : "Armor Break", addStats : _g, mulStats : _g1, strength : level, duration : 5, debuff : true},array[0]);
		}}], mpCost : 10});
		this.skills.push({ id : "Attack Break", profession : "Breaker", word : "Destruction", effects : [{ target : Target.ENEMY, effectExecution : function(bm,level,actor,array) {
			var _g = new haxe_ds_StringMap();
			_g.h["Attack"] = -level * 10;
			var _g1 = new haxe_ds_StringMap();
			_g1.h["Attack"] = 50;
			bm.AddBuff({ uniqueId : "Attack Break", addStats : _g, mulStats : _g1, strength : level, duration : 5, debuff : true},array[0]);
		}}], mpCost : 10});
	}
};
var ResourceLogic = function() { };
ResourceLogic.__name__ = true;
ResourceLogic.recalculateScalingResource = function(base,res) {
	if(res.lastUsedBaseAttribute != base) {
		var data1 = res.scaling.data1;
		var baseValue = res.scaling.initial;
		if(res.scaling.initialMultiplication) {
			baseValue *= base;
		}
		var expBonus = 0;
		if(res.scaling.exponential) {
			expBonus = Math.pow(data1,base);
		}
		var calculated = expBonus + baseValue | 0;
		calculated -= calculated % res.scaling.minimumIncrement;
		res.calculatedMax = calculated;
		res.lastUsedBaseAttribute = base;
	}
};
ResourceLogic.getExponentialResource = function(expBase,minimumIncrement,initial) {
	var res = { scaling : { data1 : expBase, initial : initial, minimumIncrement : minimumIncrement, initialMultiplication : true, exponential : true}, value : 0, lastUsedBaseAttribute : 0, calculatedMax : 0};
	ResourceLogic.recalculateScalingResource(1,res);
	return res;
};
var AttributeLogic = function() { };
AttributeLogic.__name__ = true;
AttributeLogic.AddOld = function(attributes,attributeAddition,quantityOfAddition) {
	var h = attributes.h;
	var _g_h = h;
	var _g_keys = Object.keys(h);
	var _g_length = _g_keys.length;
	var _g_current = 0;
	while(_g_current < _g_length) {
		var key = _g_keys[_g_current++];
		var _g1_key = key;
		var _g1_value = _g_h[key];
		var key1 = _g1_key;
		var value = _g1_value;
		var _g = key1;
		var _g1 = attributes;
		var v = _g1.h[_g] + (attributeAddition.h[key1] * quantityOfAddition | 0);
		_g1.h[_g] = v;
	}
};
AttributeLogic.Add = function(attributes,attributeAddition,quantityOfAddition,result) {
	var h = attributes.h;
	var _g_h = h;
	var _g_keys = Object.keys(h);
	var _g_length = _g_keys.length;
	var _g_current = 0;
	while(_g_current < _g_length) {
		var key = _g_keys[_g_current++];
		var _g1_key = key;
		var _g1_value = _g_h[key];
		var key1 = _g1_key;
		var value = _g1_value;
		var addedValue = attributeAddition.h[key1];
		if(addedValue >= 0 == false && addedValue < 0 == false) {
			addedValue = 0;
		}
		var v = value + (addedValue * quantityOfAddition | 0);
		result.h[key1] = v;
	}
	var h = attributeAddition.h;
	var _g_h = h;
	var _g_keys = Object.keys(h);
	var _g_length = _g_keys.length;
	var _g_current = 0;
	while(_g_current < _g_length) {
		var key = _g_keys[_g_current++];
		var _g1_key = key;
		var _g1_value = _g_h[key];
		var key1 = _g1_key;
		var value = _g1_value;
		if(Object.prototype.hasOwnProperty.call(attributes.h,key1) == false) {
			result.h[key1] = value;
		}
	}
};
var EventTypes = $hxEnums["EventTypes"] = { __ename__:true,__constructs__:null
	,GameStart: {_hx_name:"GameStart",_hx_index:0,__enum__:"EventTypes",toString:$estr}
	,ActorDead: {_hx_name:"ActorDead",_hx_index:1,__enum__:"EventTypes",toString:$estr}
	,EquipDrop: {_hx_name:"EquipDrop",_hx_index:2,__enum__:"EventTypes",toString:$estr}
	,ActorAppear: {_hx_name:"ActorAppear",_hx_index:3,__enum__:"EventTypes",toString:$estr}
	,ActorAttack: {_hx_name:"ActorAttack",_hx_index:4,__enum__:"EventTypes",toString:$estr}
	,ActorLevelUp: {_hx_name:"ActorLevelUp",_hx_index:5,__enum__:"EventTypes",toString:$estr}
	,AreaUnlock: {_hx_name:"AreaUnlock",_hx_index:6,__enum__:"EventTypes",toString:$estr}
	,RegionUnlock: {_hx_name:"RegionUnlock",_hx_index:7,__enum__:"EventTypes",toString:$estr}
	,AreaComplete: {_hx_name:"AreaComplete",_hx_index:8,__enum__:"EventTypes",toString:$estr}
	,AreaEnterFirstTime: {_hx_name:"AreaEnterFirstTime",_hx_index:9,__enum__:"EventTypes",toString:$estr}
	,GetXP: {_hx_name:"GetXP",_hx_index:10,__enum__:"EventTypes",toString:$estr}
	,PermanentStatUpgrade: {_hx_name:"PermanentStatUpgrade",_hx_index:11,__enum__:"EventTypes",toString:$estr}
	,statUpgrade: {_hx_name:"statUpgrade",_hx_index:12,__enum__:"EventTypes",toString:$estr}
	,SkillUse: {_hx_name:"SkillUse",_hx_index:13,__enum__:"EventTypes",toString:$estr}
	,MPRunOut: {_hx_name:"MPRunOut",_hx_index:14,__enum__:"EventTypes",toString:$estr}
	,BuffRemoval: {_hx_name:"BuffRemoval",_hx_index:15,__enum__:"EventTypes",toString:$estr}
	,DebuffBlock: {_hx_name:"DebuffBlock",_hx_index:16,__enum__:"EventTypes",toString:$estr}
};
EventTypes.__constructs__ = [EventTypes.GameStart,EventTypes.ActorDead,EventTypes.EquipDrop,EventTypes.ActorAppear,EventTypes.ActorAttack,EventTypes.ActorLevelUp,EventTypes.AreaUnlock,EventTypes.RegionUnlock,EventTypes.AreaComplete,EventTypes.AreaEnterFirstTime,EventTypes.GetXP,EventTypes.PermanentStatUpgrade,EventTypes.statUpgrade,EventTypes.SkillUse,EventTypes.MPRunOut,EventTypes.BuffRemoval,EventTypes.DebuffBlock];
var ActorReference = function(type,pos) {
	this.type = type;
	this.pos = pos;
};
ActorReference.__name__ = true;
var GameEvent = function(eType) {
	this.dataString = null;
	this.type = eType;
};
GameEvent.__name__ = true;
var Target = $hxEnums["Target"] = { __ename__:true,__constructs__:null
	,SELF: {_hx_name:"SELF",_hx_index:0,__enum__:"Target",toString:$estr}
	,ENEMY: {_hx_name:"ENEMY",_hx_index:1,__enum__:"Target",toString:$estr}
	,ALL: {_hx_name:"ALL",_hx_index:2,__enum__:"Target",toString:$estr}
};
Target.__constructs__ = [Target.SELF,Target.ENEMY,Target.ALL];
var SaveAssistant = function() { };
SaveAssistant.__name__ = true;
SaveAssistant.GetPersistenceMaster = function(jsonData) {
	if(jsonData != null && jsonData != "") {
		var parsed = JSON.parse(jsonData);
		var persistenceMaster = parsed;
		if(persistenceMaster.worldVersion >= 602 == false) {
			persistenceMaster.jsonGameplay = jsonData;
		}
		return persistenceMaster;
	} else {
		return { worldVersion : -1, jsonStory : null, jsonGameplay : null};
	}
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std.random = function(x) {
	if(x <= 0) {
		return 0;
	} else {
		return Math.floor(Math.random() * x);
	}
};
var haxe_io_Output = function() { };
haxe_io_Output.__name__ = true;
var _$Sys_FileOutput = function(fd) {
	this.fd = fd;
};
_$Sys_FileOutput.__name__ = true;
_$Sys_FileOutput.__super__ = haxe_io_Output;
_$Sys_FileOutput.prototype = $extend(haxe_io_Output.prototype,{
	writeByte: function(c) {
		js_node_Fs.writeSync(this.fd,String.fromCodePoint(c));
	}
	,writeBytes: function(s,pos,len) {
		var data = s.b;
		return js_node_Fs.writeSync(this.fd,js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length),pos,len);
	}
	,writeString: function(s,encoding) {
		js_node_Fs.writeSync(this.fd,s);
	}
	,flush: function() {
		js_node_Fs.fsyncSync(this.fd);
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
});
var haxe_io_Input = function() { };
haxe_io_Input.__name__ = true;
var _$Sys_FileInput = function(fd) {
	this.fd = fd;
};
_$Sys_FileInput.__name__ = true;
_$Sys_FileInput.__super__ = haxe_io_Input;
_$Sys_FileInput.prototype = $extend(haxe_io_Input.prototype,{
	readByte: function() {
		var buf = js_node_buffer_Buffer.alloc(1);
		try {
			js_node_Fs.readSync(this.fd,buf,0,1,null);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
		return buf[0];
	}
	,readBytes: function(s,pos,len) {
		var data = s.b;
		var buf = js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length);
		try {
			return js_node_Fs.readSync(this.fd,buf,pos,len,null);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
});
var UInt = {};
UInt.toFloat = function(this1) {
	var int = this1;
	if(int < 0) {
		return 4294967296.0 + int;
	} else {
		return int + 0.0;
	}
};
var haxe_Exception = function(message,previous,native) {
	Error.call(this,message);
	this.message = message;
	this.__previousException = previous;
	this.__nativeException = native != null ? native : this;
};
haxe_Exception.__name__ = true;
haxe_Exception.caught = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value;
	} else if(((value) instanceof Error)) {
		return new haxe_Exception(value.message,null,value);
	} else {
		return new haxe_ValueException(value,null,value);
	}
};
haxe_Exception.thrown = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value.get_native();
	} else if(((value) instanceof Error)) {
		return value;
	} else {
		var e = new haxe_ValueException(value);
		return e;
	}
};
haxe_Exception.__super__ = Error;
haxe_Exception.prototype = $extend(Error.prototype,{
	unwrap: function() {
		return this.__nativeException;
	}
	,get_native: function() {
		return this.__nativeException;
	}
});
var haxe_Int32 = {};
haxe_Int32.ucompare = function(a,b) {
	if(a < 0) {
		if(b < 0) {
			return ~b - ~a | 0;
		} else {
			return 1;
		}
	}
	if(b < 0) {
		return -1;
	} else {
		return a - b | 0;
	}
};
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
haxe__$Int64__$_$_$Int64.__name__ = true;
var haxe_Resource = function() { };
haxe_Resource.__name__ = true;
haxe_Resource.getString = function(name) {
	var _g = 0;
	var _g1 = haxe_Resource.content;
	while(_g < _g1.length) {
		var x = _g1[_g];
		++_g;
		if(x.name == name) {
			if(x.str != null) {
				return x.str;
			}
			var b = haxe_crypto_Base64.decode(x.data);
			return b.toString();
		}
	}
	return null;
};
var haxe_ValueException = function(value,previous,native) {
	haxe_Exception.call(this,String(value),previous,native);
	this.value = value;
};
haxe_ValueException.__name__ = true;
haxe_ValueException.__super__ = haxe_Exception;
haxe_ValueException.prototype = $extend(haxe_Exception.prototype,{
	unwrap: function() {
		return this.value;
	}
});
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe_io_Bytes.__name__ = true;
haxe_io_Bytes.ofString = function(s,encoding) {
	if(encoding == haxe_io_Encoding.RawNative) {
		var buf = new Uint8Array(s.length << 1);
		var _g = 0;
		var _g1 = s.length;
		while(_g < _g1) {
			var i = _g++;
			var c = s.charCodeAt(i);
			buf[i << 1] = c & 255;
			buf[i << 1 | 1] = c >> 8;
		}
		return new haxe_io_Bytes(buf.buffer);
	}
	var a = [];
	var i = 0;
	while(i < s.length) {
		var c = s.charCodeAt(i++);
		if(55296 <= c && c <= 56319) {
			c = c - 55232 << 10 | s.charCodeAt(i++) & 1023;
		}
		if(c <= 127) {
			a.push(c);
		} else if(c <= 2047) {
			a.push(192 | c >> 6);
			a.push(128 | c & 63);
		} else if(c <= 65535) {
			a.push(224 | c >> 12);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		} else {
			a.push(240 | c >> 18);
			a.push(128 | c >> 12 & 63);
			a.push(128 | c >> 6 & 63);
			a.push(128 | c & 63);
		}
	}
	return new haxe_io_Bytes(new Uint8Array(a).buffer);
};
haxe_io_Bytes.prototype = {
	getInt32: function(pos) {
		if(this.data == null) {
			this.data = new DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
		}
		return this.data.getInt32(pos,true);
	}
	,setInt32: function(pos,v) {
		if(this.data == null) {
			this.data = new DataView(this.b.buffer,this.b.byteOffset,this.b.byteLength);
		}
		this.data.setInt32(pos,v,true);
	}
	,getInt64: function(pos) {
		var this1 = new haxe__$Int64__$_$_$Int64(this.getInt32(pos + 4),this.getInt32(pos));
		return this1;
	}
	,setInt64: function(pos,v) {
		this.setInt32(pos,v.low);
		this.setInt32(pos + 4,v.high);
	}
	,getString: function(pos,len,encoding) {
		if(pos < 0 || len < 0 || pos + len > this.length) {
			throw haxe_Exception.thrown(haxe_io_Error.OutsideBounds);
		}
		if(encoding == null) {
			encoding = haxe_io_Encoding.UTF8;
		}
		var s = "";
		var b = this.b;
		var i = pos;
		var max = pos + len;
		switch(encoding._hx_index) {
		case 0:
			var debug = pos > 0;
			while(i < max) {
				var c = b[i++];
				if(c < 128) {
					if(c == 0) {
						break;
					}
					s += String.fromCodePoint(c);
				} else if(c < 224) {
					var code = (c & 63) << 6 | b[i++] & 127;
					s += String.fromCodePoint(code);
				} else if(c < 240) {
					var c2 = b[i++];
					var code1 = (c & 31) << 12 | (c2 & 127) << 6 | b[i++] & 127;
					s += String.fromCodePoint(code1);
				} else {
					var c21 = b[i++];
					var c3 = b[i++];
					var u = (c & 15) << 18 | (c21 & 127) << 12 | (c3 & 127) << 6 | b[i++] & 127;
					s += String.fromCodePoint(u);
				}
			}
			break;
		case 1:
			while(i < max) {
				var c = b[i++] | b[i++] << 8;
				s += String.fromCodePoint(c);
			}
			break;
		}
		return s;
	}
	,toString: function() {
		return this.getString(0,this.length);
	}
};
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__:true,__constructs__:null
	,UTF8: {_hx_name:"UTF8",_hx_index:0,__enum__:"haxe.io.Encoding",toString:$estr}
	,RawNative: {_hx_name:"RawNative",_hx_index:1,__enum__:"haxe.io.Encoding",toString:$estr}
};
haxe_io_Encoding.__constructs__ = [haxe_io_Encoding.UTF8,haxe_io_Encoding.RawNative];
var haxe_crypto_Base64 = function() { };
haxe_crypto_Base64.__name__ = true;
haxe_crypto_Base64.decode = function(str,complement) {
	if(complement == null) {
		complement = true;
	}
	if(complement) {
		while(HxOverrides.cca(str,str.length - 1) == 61) str = HxOverrides.substr(str,0,-1);
	}
	return new haxe_crypto_BaseCode(haxe_crypto_Base64.BYTES).decodeBytes(haxe_io_Bytes.ofString(str));
};
var haxe_crypto_BaseCode = function(base) {
	var len = base.length;
	var nbits = 1;
	while(len > 1 << nbits) ++nbits;
	if(nbits > 8 || len != 1 << nbits) {
		throw haxe_Exception.thrown("BaseCode : base length must be a power of two.");
	}
	this.base = base;
	this.nbits = nbits;
};
haxe_crypto_BaseCode.__name__ = true;
haxe_crypto_BaseCode.prototype = {
	initTable: function() {
		var tbl = [];
		var _g = 0;
		while(_g < 256) {
			var i = _g++;
			tbl[i] = -1;
		}
		var _g = 0;
		var _g1 = this.base.length;
		while(_g < _g1) {
			var i = _g++;
			tbl[this.base.b[i]] = i;
		}
		this.tbl = tbl;
	}
	,decodeBytes: function(b) {
		var nbits = this.nbits;
		var base = this.base;
		if(this.tbl == null) {
			this.initTable();
		}
		var tbl = this.tbl;
		var size = b.length * nbits >> 3;
		var out = new haxe_io_Bytes(new ArrayBuffer(size));
		var buf = 0;
		var curbits = 0;
		var pin = 0;
		var pout = 0;
		while(pout < size) {
			while(curbits < 8) {
				curbits += nbits;
				buf <<= nbits;
				var i = tbl[b.b[pin++]];
				if(i == -1) {
					throw haxe_Exception.thrown("BaseCode : invalid encoded char");
				}
				buf |= i;
			}
			curbits -= 8;
			out.b[pout++] = buf >> curbits & 255;
		}
		return out;
	}
};
var haxe_crypto_Sha1 = function() {
};
haxe_crypto_Sha1.__name__ = true;
haxe_crypto_Sha1.make = function(b) {
	var h = new haxe_crypto_Sha1().doEncode(haxe_crypto_Sha1.bytes2blks(b));
	var out = new haxe_io_Bytes(new ArrayBuffer(20));
	var p = 0;
	out.b[p++] = h[0] >>> 24;
	out.b[p++] = h[0] >> 16 & 255;
	out.b[p++] = h[0] >> 8 & 255;
	out.b[p++] = h[0] & 255;
	out.b[p++] = h[1] >>> 24;
	out.b[p++] = h[1] >> 16 & 255;
	out.b[p++] = h[1] >> 8 & 255;
	out.b[p++] = h[1] & 255;
	out.b[p++] = h[2] >>> 24;
	out.b[p++] = h[2] >> 16 & 255;
	out.b[p++] = h[2] >> 8 & 255;
	out.b[p++] = h[2] & 255;
	out.b[p++] = h[3] >>> 24;
	out.b[p++] = h[3] >> 16 & 255;
	out.b[p++] = h[3] >> 8 & 255;
	out.b[p++] = h[3] & 255;
	out.b[p++] = h[4] >>> 24;
	out.b[p++] = h[4] >> 16 & 255;
	out.b[p++] = h[4] >> 8 & 255;
	out.b[p++] = h[4] & 255;
	return out;
};
haxe_crypto_Sha1.bytes2blks = function(b) {
	var nblk = (b.length + 8 >> 6) + 1;
	var blks = [];
	var _g = 0;
	var _g1 = nblk * 16;
	while(_g < _g1) {
		var i = _g++;
		blks[i] = 0;
	}
	var _g = 0;
	var _g1 = b.length;
	while(_g < _g1) {
		var i = _g++;
		var p = i >> 2;
		blks[p] |= b.b[i] << 24 - ((i & 3) << 3);
	}
	var i = b.length;
	var p = i >> 2;
	blks[p] |= 128 << 24 - ((i & 3) << 3);
	blks[nblk * 16 - 1] = b.length * 8;
	return blks;
};
haxe_crypto_Sha1.prototype = {
	doEncode: function(x) {
		var w = [];
		var a = 1732584193;
		var b = -271733879;
		var c = -1732584194;
		var d = 271733878;
		var e = -1009589776;
		var i = 0;
		while(i < x.length) {
			var olda = a;
			var oldb = b;
			var oldc = c;
			var oldd = d;
			var olde = e;
			var j = 0;
			while(j < 80) {
				if(j < 16) {
					w[j] = x[i + j];
				} else {
					var num = w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16];
					w[j] = num << 1 | num >>> 31;
				}
				var t = (a << 5 | a >>> 27) + this.ft(j,b,c,d) + e + w[j] + this.kt(j);
				e = d;
				d = c;
				c = b << 30 | b >>> 2;
				b = a;
				a = t;
				++j;
			}
			a += olda;
			b += oldb;
			c += oldc;
			d += oldd;
			e += olde;
			i += 16;
		}
		return [a,b,c,d,e];
	}
	,ft: function(t,b,c,d) {
		if(t < 20) {
			return b & c | ~b & d;
		}
		if(t < 40) {
			return b ^ c ^ d;
		}
		if(t < 60) {
			return b & c | b & d | c & d;
		}
		return b ^ c ^ d;
	}
	,kt: function(t) {
		if(t < 20) {
			return 1518500249;
		}
		if(t < 40) {
			return 1859775393;
		}
		if(t < 60) {
			return -1894007588;
		}
		return -899497514;
	}
};
var haxe_ds_StringMap = function() {
	this.h = Object.create(null);
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.createCopy = function(h) {
	var copy = new haxe_ds_StringMap();
	for (var key in h) copy.h[key] = h[key];
	return copy;
};
var haxe_io_Eof = function() {
};
haxe_io_Eof.__name__ = true;
haxe_io_Eof.prototype = {
	toString: function() {
		return "Eof";
	}
};
var haxe_io_Error = $hxEnums["haxe.io.Error"] = { __ename__:true,__constructs__:null
	,Blocked: {_hx_name:"Blocked",_hx_index:0,__enum__:"haxe.io.Error",toString:$estr}
	,Overflow: {_hx_name:"Overflow",_hx_index:1,__enum__:"haxe.io.Error",toString:$estr}
	,OutsideBounds: {_hx_name:"OutsideBounds",_hx_index:2,__enum__:"haxe.io.Error",toString:$estr}
	,Custom: ($_=function(e) { return {_hx_index:3,e:e,__enum__:"haxe.io.Error",toString:$estr}; },$_._hx_name="Custom",$_.__params__ = ["e"],$_)
};
haxe_io_Error.__constructs__ = [haxe_io_Error.Blocked,haxe_io_Error.Overflow,haxe_io_Error.OutsideBounds,haxe_io_Error.Custom];
var haxe_io_Path = function() { };
haxe_io_Path.__name__ = true;
haxe_io_Path.join = function(paths) {
	var _g = [];
	var _g1 = 0;
	var _g2 = paths;
	while(_g1 < _g2.length) {
		var v = _g2[_g1];
		++_g1;
		if(v != null && v != "") {
			_g.push(v);
		}
	}
	var paths = _g;
	if(paths.length == 0) {
		return "";
	}
	var path = paths[0];
	var _g = 1;
	var _g1 = paths.length;
	while(_g < _g1) {
		var i = _g++;
		path = haxe_io_Path.addTrailingSlash(path);
		path += paths[i];
	}
	return haxe_io_Path.normalize(path);
};
haxe_io_Path.normalize = function(path) {
	var slash = "/";
	path = path.split("\\").join(slash);
	if(path == slash) {
		return slash;
	}
	var target = [];
	var _g = 0;
	var _g1 = path.split(slash);
	while(_g < _g1.length) {
		var token = _g1[_g];
		++_g;
		if(token == ".." && target.length > 0 && target[target.length - 1] != "..") {
			target.pop();
		} else if(token == "") {
			if(target.length > 0 || HxOverrides.cca(path,0) == 47) {
				target.push(token);
			}
		} else if(token != ".") {
			target.push(token);
		}
	}
	var tmp = target.join(slash);
	var acc_b = "";
	var colon = false;
	var slashes = false;
	var _g2_offset = 0;
	var _g2_s = tmp;
	while(_g2_offset < _g2_s.length) {
		var s = _g2_s;
		var index = _g2_offset++;
		var c = s.charCodeAt(index);
		if(c >= 55296 && c <= 56319) {
			c = c - 55232 << 10 | s.charCodeAt(index + 1) & 1023;
		}
		var c1 = c;
		if(c1 >= 65536) {
			++_g2_offset;
		}
		var c2 = c1;
		switch(c2) {
		case 47:
			if(!colon) {
				slashes = true;
			} else {
				var i = c2;
				colon = false;
				if(slashes) {
					acc_b += "/";
					slashes = false;
				}
				acc_b += String.fromCodePoint(i);
			}
			break;
		case 58:
			acc_b += ":";
			colon = true;
			break;
		default:
			var i1 = c2;
			colon = false;
			if(slashes) {
				acc_b += "/";
				slashes = false;
			}
			acc_b += String.fromCodePoint(i1);
		}
	}
	return acc_b;
};
haxe_io_Path.addTrailingSlash = function(path) {
	if(path.length == 0) {
		return "/";
	}
	var c1 = path.lastIndexOf("/");
	var c2 = path.lastIndexOf("\\");
	if(c1 < c2) {
		if(c2 != path.length - 1) {
			return path + "\\";
		} else {
			return path;
		}
	} else if(c1 != path.length - 1) {
		return path + "/";
	} else {
		return path;
	}
};
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.__name__ = true;
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o.__enum__) {
			var e = $hxEnums[o.__enum__];
			var con = e.__constructs__[o._hx_index];
			var n = con._hx_name;
			if(con.__params__) {
				s = s + "\t";
				return n + "(" + ((function($this) {
					var $r;
					var _g = [];
					{
						var _g1 = 0;
						var _g2 = con.__params__;
						while(true) {
							if(!(_g1 < _g2.length)) {
								break;
							}
							var p = _g2[_g1];
							_g1 = _g1 + 1;
							_g.push(js_Boot.__string_rec(o[p],s));
						}
					}
					$r = _g;
					return $r;
				}(this))).join(",") + ")";
			} else {
				return n;
			}
		}
		if(((o) instanceof Array)) {
			var str = "[";
			s += "\t";
			var _g = 0;
			var _g1 = o.length;
			while(_g < _g1) {
				var i = _g++;
				str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( _g ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		var k = null;
		for( k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) {
			str += ", \n";
		}
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var js_node_Fs = require("fs");
var js_node_KeyValue = {};
js_node_KeyValue.get_key = function(this1) {
	return this1[0];
};
js_node_KeyValue.get_value = function(this1) {
	return this1[1];
};
var js_node_buffer_Buffer = require("buffer").Buffer;
var js_node_stream_WritableNewOptionsAdapter = {};
js_node_stream_WritableNewOptionsAdapter.from = function(options) {
	if(!Object.prototype.hasOwnProperty.call(options,"final")) {
		Object.defineProperty(options,"final",{ get : function() {
			return options.final_;
		}});
	}
	return options;
};
var js_node_url_URLSearchParamsEntry = {};
js_node_url_URLSearchParamsEntry._new = function(name,value) {
	var this1 = [name,value];
	return this1;
};
js_node_url_URLSearchParamsEntry.get_name = function(this1) {
	return this1[0];
};
js_node_url_URLSearchParamsEntry.get_value = function(this1) {
	return this1[1];
};
var seedyrng_Random = function(seed,generator) {
	if(seed == null) {
		var this1 = new haxe__$Int64__$_$_$Int64(seedyrng_Random.randomSystemInt(),seedyrng_Random.randomSystemInt());
		seed = this1;
	}
	if(generator == null) {
		generator = new seedyrng_Xorshift128Plus();
	}
	this.generator = generator;
	this.set_seed(seed);
};
seedyrng_Random.__name__ = true;
seedyrng_Random.randomSystemInt = function() {
	var value = Std.random(255) << 24 | Std.random(255) << 16 | Std.random(255) << 8 | Std.random(255);
	return value;
};
seedyrng_Random.prototype = {
	get_seed: function() {
		return this.generator.get_seed();
	}
	,set_seed: function(value) {
		return this.generator.set_seed(value);
	}
	,get_state: function() {
		return this.generator.get_state();
	}
	,set_state: function(value) {
		return this.generator.set_state(value);
	}
	,get_usesAllBits: function() {
		return this.generator.get_usesAllBits();
	}
	,nextInt: function() {
		return this.generator.nextInt();
	}
	,nextFullInt: function() {
		if(this.generator.get_usesAllBits()) {
			return this.generator.nextInt();
		} else {
			var num1 = this.generator.nextInt();
			var num2 = this.generator.nextInt();
			num2 = num2 >>> 16 | num2 << 16;
			return num1 ^ num2;
		}
	}
	,setStringSeed: function(seed) {
		this.setBytesSeed(haxe_io_Bytes.ofString(seed));
	}
	,setBytesSeed: function(seed) {
		var hash = haxe_crypto_Sha1.make(seed);
		this.set_seed(hash.getInt64(0));
	}
	,random: function() {
		var upper = this.nextFullInt() & 2097151;
		var lower = this.nextFullInt();
		var lhs = upper * Math.pow(2,32);
		var floatNum = UInt.toFloat(lower) + lhs;
		var result = floatNum * Math.pow(2,-53);
		return result;
	}
	,randomInt: function(lower,upper) {
		return Math.floor(this.random() * (upper - lower + 1)) + lower;
	}
	,uniform: function(lower,upper) {
		return this.random() * (upper - lower) + lower;
	}
	,choice: function(array) {
		return array[this.randomInt(0,array.length - 1)];
	}
	,shuffle: function(array) {
		var _g = 0;
		var _g1 = array.length - 1;
		while(_g < _g1) {
			var index = _g++;
			var randIndex = this.randomInt(index,array.length - 1);
			var tempA = array[index];
			var tempB = array[randIndex];
			array[index] = tempB;
			array[randIndex] = tempA;
		}
	}
};
var seedyrng_Xorshift128Plus = function() {
	this._currentAvailable = false;
	var this1 = new haxe__$Int64__$_$_$Int64(0,1);
	this.set_seed(this1);
};
seedyrng_Xorshift128Plus.__name__ = true;
seedyrng_Xorshift128Plus.prototype = {
	get_usesAllBits: function() {
		return false;
	}
	,get_seed: function() {
		return this._seed;
	}
	,set_seed: function(value) {
		var b_high = 0;
		var b_low = 0;
		if(!(value.high != b_high || value.low != b_low)) {
			var this1 = new haxe__$Int64__$_$_$Int64(0,1);
			value = this1;
		}
		this._seed = value;
		this._state0 = value;
		this._state1 = seedyrng_Xorshift128Plus.SEED_1;
		this._currentAvailable = false;
		return value;
	}
	,get_state: function() {
		var bytes = new haxe_io_Bytes(new ArrayBuffer(33));
		bytes.setInt64(0,this._seed);
		bytes.setInt64(8,this._state0);
		bytes.setInt64(16,this._state1);
		bytes.b[24] = this._currentAvailable ? 1 : 0;
		if(this._currentAvailable) {
			bytes.setInt64(25,this._current);
		}
		return bytes;
	}
	,set_state: function(value) {
		if(value.length != 33) {
			throw haxe_Exception.thrown("Wrong state size " + value.length);
		}
		this._seed = value.getInt64(0);
		this._state0 = value.getInt64(8);
		this._state1 = value.getInt64(16);
		this._currentAvailable = value.b[24] == 1;
		if(this._currentAvailable) {
			this._current = value.getInt64(25);
		}
		return value;
	}
	,stepNext: function() {
		var x = this._state0;
		var y = this._state1;
		this._state0 = y;
		var b = 23;
		b &= 63;
		var b1;
		if(b == 0) {
			var this1 = new haxe__$Int64__$_$_$Int64(x.high,x.low);
			b1 = this1;
		} else if(b < 32) {
			var this1 = new haxe__$Int64__$_$_$Int64(x.high << b | x.low >>> 32 - b,x.low << b);
			b1 = this1;
		} else {
			var this1 = new haxe__$Int64__$_$_$Int64(x.low << b - 32,0);
			b1 = this1;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(x.high ^ b1.high,x.low ^ b1.low);
		x = this1;
		var a_high = x.high ^ y.high;
		var a_low = x.low ^ y.low;
		var b = 17;
		b &= 63;
		var b1;
		if(b == 0) {
			var this1 = new haxe__$Int64__$_$_$Int64(x.high,x.low);
			b1 = this1;
		} else if(b < 32) {
			var this1 = new haxe__$Int64__$_$_$Int64(x.high >> b,x.high << 32 - b | x.low >>> b);
			b1 = this1;
		} else {
			var this1 = new haxe__$Int64__$_$_$Int64(x.high >> 31,x.high >> b - 32);
			b1 = this1;
		}
		var a_high1 = a_high ^ b1.high;
		var a_low1 = a_low ^ b1.low;
		var b = 26;
		b &= 63;
		var b1;
		if(b == 0) {
			var this1 = new haxe__$Int64__$_$_$Int64(y.high,y.low);
			b1 = this1;
		} else if(b < 32) {
			var this1 = new haxe__$Int64__$_$_$Int64(y.high >> b,y.high << 32 - b | y.low >>> b);
			b1 = this1;
		} else {
			var this1 = new haxe__$Int64__$_$_$Int64(y.high >> 31,y.high >> b - 32);
			b1 = this1;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(a_high1 ^ b1.high,a_low1 ^ b1.low);
		this._state1 = this1;
		var a = this._state1;
		var high = a.high + y.high | 0;
		var low = a.low + y.low | 0;
		if(haxe_Int32.ucompare(low,a.low) < 0) {
			var ret = high++;
			high = high | 0;
		}
		var this1 = new haxe__$Int64__$_$_$Int64(high,low);
		this._current = this1;
	}
	,nextInt: function() {
		if(this._currentAvailable) {
			this._currentAvailable = false;
			return this._current.low;
		} else {
			this.stepNext();
			this._currentAvailable = true;
			return this._current.high;
		}
	}
};
var sys_io_FileInput = function(fd) {
	this.fd = fd;
	this.pos = 0;
};
sys_io_FileInput.__name__ = true;
sys_io_FileInput.__super__ = haxe_io_Input;
sys_io_FileInput.prototype = $extend(haxe_io_Input.prototype,{
	readByte: function() {
		var buf = js_node_buffer_Buffer.alloc(1);
		var bytesRead;
		try {
			bytesRead = js_node_Fs.readSync(this.fd,buf,0,1,this.pos);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
		if(bytesRead == 0) {
			throw haxe_Exception.thrown(new haxe_io_Eof());
		}
		this.pos++;
		return buf[0];
	}
	,readBytes: function(s,pos,len) {
		var data = s.b;
		var buf = js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length);
		var bytesRead;
		try {
			bytesRead = js_node_Fs.readSync(this.fd,buf,pos,len,this.pos);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
		if(bytesRead == 0) {
			throw haxe_Exception.thrown(new haxe_io_Eof());
		}
		this.pos += bytesRead;
		return bytesRead;
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
	,seek: function(p,pos) {
		switch(pos._hx_index) {
		case 0:
			this.pos = p;
			break;
		case 1:
			this.pos += p;
			break;
		case 2:
			this.pos = js_node_Fs.fstatSync(this.fd).size + p;
			break;
		}
	}
	,tell: function() {
		return this.pos;
	}
	,eof: function() {
		return this.pos >= js_node_Fs.fstatSync(this.fd).size;
	}
});
var sys_io_FileOutput = function(fd) {
	this.fd = fd;
	this.pos = 0;
};
sys_io_FileOutput.__name__ = true;
sys_io_FileOutput.__super__ = haxe_io_Output;
sys_io_FileOutput.prototype = $extend(haxe_io_Output.prototype,{
	writeByte: function(b) {
		var buf = js_node_buffer_Buffer.alloc(1);
		buf[0] = b;
		js_node_Fs.writeSync(this.fd,buf,0,1,this.pos);
		this.pos++;
	}
	,writeBytes: function(s,pos,len) {
		var data = s.b;
		var buf = js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length);
		var wrote = js_node_Fs.writeSync(this.fd,buf,pos,len,this.pos);
		this.pos += wrote;
		return wrote;
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
	,seek: function(p,pos) {
		switch(pos._hx_index) {
		case 0:
			this.pos = p;
			break;
		case 1:
			this.pos += p;
			break;
		case 2:
			this.pos = js_node_Fs.fstatSync(this.fd).size + p;
			break;
		}
	}
	,tell: function() {
		return this.pos;
	}
});
var sys_io_FileSeek = $hxEnums["sys.io.FileSeek"] = { __ename__:true,__constructs__:null
	,SeekBegin: {_hx_name:"SeekBegin",_hx_index:0,__enum__:"sys.io.FileSeek",toString:$estr}
	,SeekCur: {_hx_name:"SeekCur",_hx_index:1,__enum__:"sys.io.FileSeek",toString:$estr}
	,SeekEnd: {_hx_name:"SeekEnd",_hx_index:2,__enum__:"sys.io.FileSeek",toString:$estr}
};
sys_io_FileSeek.__constructs__ = [sys_io_FileSeek.SeekBegin,sys_io_FileSeek.SeekCur,sys_io_FileSeek.SeekEnd];
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.__name__ = true;
Array.__name__ = true;
haxe_Resource.content = [{ name : "storyjson", data : "W3sibWVzc2FnZXMiOlt7ImJvZHkiOiIgV2hlcmUgYXJlIHlvdSBnb2luZz8iLCJzcGVha2VyIjoiTW9tIiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgS2lsbCBzb21lIG1vbnN0ZXJzLCBtb20iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgVGhpcyBraWQuLi4iLCJzcGVha2VyIjoiTW9tIiwic2NyaXB0IjpudWxsfV0sInRpdGxlIjoiVGhpcyBraWQuLi4iLCJ2aXNpYmlsaXR5U2NyaXB0IjpudWxsLCJhY3Rpb25MYWJlbCI6Ildha2UgdXAifSx7Im1lc3NhZ2VzIjpbeyJib2R5IjoiIEknbSBiYWNrIiwic3BlYWtlciI6IllvdSIsInNjcmlwdCI6bnVsbH0seyJib2R5IjoiIEdvb2QsIGl0J3MgdGltZSBmb3IgZGlubmVyLiIsInNwZWFrZXIiOiJNb20iLCJzY3JpcHQiOm51bGx9LHsiYm9keSI6IiBIZXkgbW9tLi4uIiwic3BlYWtlciI6IllvdSIsInNjcmlwdCI6bnVsbH0seyJib2R5IjoiIFdoYXQgaXMgd3JvbmcsIGRlYXI/Iiwic3BlYWtlciI6Ik1vbSIsInNjcmlwdCI6bnVsbH0seyJib2R5IjoiIEknbSBsZWF2aW5nIHRvd24iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgSGFoYWhhaGFhLCBvaCBZb3UuLi4iLCJzcGVha2VyIjoiTW9tIiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgQW5kIEknbSBNYm9pLCBHb2Qgb2YgV2F0ZXJ3YXlzISIsInNwZWFrZXIiOiJNb20iLCJzY3JpcHQiOm51bGx9LHsiYm9keSI6IiAuLi4iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgQydtb24sIGVhdCB1cC4iLCJzcGVha2VyIjoiTW9tIiwic2NyaXB0IjpudWxsfV0sInRpdGxlIjoiVGltZSBmb3IgZGlubmVyIiwidmlzaWJpbGl0eVNjcmlwdCI6IiByZXR1cm4gZ2xvYmFsW1wibWF4YXJlYVwiXSA+IDI7ICIsImFjdGlvbkxhYmVsIjoiSSdtIGh1bmdyeS4uLiJ9LHsibWVzc2FnZXMiOlt7ImJvZHkiOiIgSSBmZWVsIGxpa2UgaXQgYmVjb21lcyBoYXJkZXIgYW5kIGhhcmRlciB0byBiZWNvbWUgc3Ryb25nZXIuLi4iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiJBIHJlZC1oYWlyZWQgbWFuIGFwcHJvYWNoZXMgeW91LiIsInNwZWFrZXIiOm51bGwsInNjcmlwdCI6bnVsbH0seyJib2R5IjoiIEhleSBraWQuIiwic3BlYWtlciI6Ik1hbiIsInNjcmlwdCI6bnVsbH0seyJib2R5IjoiIFdobyBhcmUgeW91PyIsInNwZWFrZXIiOiJZb3UiLCJzY3JpcHQiOm51bGx9LHsiYm9keSI6IiBOYW1lJ3MgQ2lkLiAiLCJzcGVha2VyIjoiTWFuIiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgSSBmZWVsIGxpa2UgSSd2ZSBzZWVuIHRoYXQgbmFtZSBiZWZvcmUuLi4iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgWW91IHdhbm5hIGJlY29tZSBzdHJvbmdlcj8gSGVoLiBTb21ldGltZXMgeW91IGdvdHRhIGxvc2UgaXQgYWxsIHRvIHJlYWNoIGEgbmV3IGhlaWdodC4iLCJzcGVha2VyIjoiQ2lkIiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgQW55d2F5cywgdGFrZSB0aGlzLiBJdCB0ZWFjaGVzIHlvdSBob3cgdG8gU291bCBDcnVzaC4iLCJzcGVha2VyIjoiQ2lkIiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiJIZSBoYW5kcyB5b3UgYW4gb2xkIHNjcm9sbC4iLCJzcGVha2VyIjpudWxsLCJzY3JpcHQiOm51bGx9LHsiYm9keSI6IiBJIHNob3VsZG4ndCByZWFsbHkgdGFrZSB0aGluZ3MgZnJvbSBzdHJhbmdlcnMuLi4iLCJzcGVha2VyIjoiWW91Iiwic2NyaXB0IjpudWxsfSx7ImJvZHkiOiIgQnV0IG9oIHdlbGwuIEknbGwgdGFrZSBhIHNob3QuIEhvcGUgaXQgZG9lc24ndCBnZXQgbWUga2lsbGVkLiIsInNwZWFrZXIiOiJZb3UiLCJzY3JpcHQiOm51bGx9LHsiYm9keSI6IiBZb3UgbWF5IG5vdCBiZSBhYmxlIHRvIGRvIGl0IG5vdywgYnV0IHNvbWVkYXkuLi4gR29vZCBsdWNrLCBraWQuIiwic3BlYWtlciI6IkNpZCIsInNjcmlwdCI6bnVsbH1dLCJ0aXRsZSI6IkJlY29tZSBzdHJvbmdlciIsInZpc2liaWxpdHlTY3JpcHQiOiIgcmV0dXJuIGdsb2JhbFtcImhlcm9sZXZlbFwiXSA+IDg7ICIsImFjdGlvbkxhYmVsIjoiSG93IGRvIEkgZ2V0IHN0cm9uZ2VyLi4uIn1d"}];
js_Boot.__toStr = ({ }).toString;
PrototypeItemMaker.itemType_Weapon = 0;
PrototypeItemMaker.itemType_Armor = 1;
haxe_crypto_Base64.CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
haxe_crypto_Base64.BYTES = haxe_io_Bytes.ofString(haxe_crypto_Base64.CHARS);
seedyrng_Xorshift128Plus.PARAMETER_A = 23;
seedyrng_Xorshift128Plus.PARAMETER_B = 17;
seedyrng_Xorshift128Plus.PARAMETER_C = 26;
seedyrng_Xorshift128Plus.SEED_1 = (function($this) {
	var $r;
	var this1 = new haxe__$Int64__$_$_$Int64(842650776,685298713);
	$r = this1;
	return $r;
}(this));
MainTest.main();
})({});
