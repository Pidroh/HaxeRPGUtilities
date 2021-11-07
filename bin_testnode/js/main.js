(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var BattleManager = function() {
	this.regionPrizes = [{ statBonus : null, xpPrize : true}];
	this.regionRequirements = [0];
	this.playerActions = new haxe_ds_StringMap();
	this.events = [];
	this.random = new seedyrng_Random();
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
	_g.h["Attack"] = 0.45;
	_g.h["Speed"] = 3.2;
	_g.h["LifeMax"] = 1.5;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, speciesLevelStats : null});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Speed"] = 2;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 4;
	_g.h["Speed"] = 0.09;
	_g.h["LifeMax"] = 3;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : null, speciesLevelStats : null});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	_g.h["LifeMax"] = 5;
	bm1.push({ xpPrize : false, statBonus : _g});
	var bm1 = bm.enemySheets;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1.4;
	_g.h["Speed"] = 0.15;
	_g.h["LifeMax"] = 2.5;
	var _g1 = new haxe_ds_StringMap();
	_g1.h["Defense"] = 4;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 2;
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
	_g1.h["Piercing"] = 1;
	var _g2 = new haxe_ds_StringMap();
	_g2.h["Defense"] = 1;
	bm1.push({ speciesMultiplier : { attributesBase : _g}, speciesAdd : _g1, speciesLevelStats : { attributesBase : _g2}});
	var bm1 = bm.regionPrizes;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Speed"] = 1;
	_g.h["LifeMax"] = 3;
	bm1.push({ xpPrize : false, statBonus : _g});
	bm.regionRequirements = [0,5,10,15,20];
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	_g.h["Speed"] = 20;
	_g.h["SpeedCount"] = 0;
	var stats = _g;
	var w = { worldVersion : 602, hero : { level : 1, attributesBase : null, equipmentSlots : null, equipment : null, xp : null, attributesCalculated : stats, reference : new ActorReference(0,0)}, enemy : null, maxArea : 1, necessaryToKillInArea : 0, killedInArea : [0,0], timeCount : 0, playerTimesKilled : 0, battleArea : 0, battleAreaRegion : 0, battleAreaRegionMax : 1, playerActions : new haxe_ds_StringMap(), recovering : false, sleeping : false, regionProgress : []};
	this.wdata = w;
	this.ReinitGameValues();
	this.ChangeBattleArea(0);
	var v = this.wdata.hero.attributesCalculated.h["LifeMax"];
	this.wdata.hero.attributesCalculated.h["Life"] = v;
};
BattleManager.__name__ = true;
BattleManager.prototype = {
	GetAttribute: function(actor,label) {
		var i = actor.attributesCalculated.h[label];
		if(i < 0) {
			i = 0;
		}
		return i;
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
			this.wdata.necessaryToKillInArea = initialEnemyToKill * area;
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
	,AwardXP: function(xpPlus) {
		this.wdata.hero.xp.value += xpPlus;
		var e = this.AddEvent(EventTypes.GetXP);
		e.data = xpPlus;
	}
	,CreateAreaEnemy: function() {
		var region = this.wdata.battleAreaRegion;
		var enemyLevel = this.wdata.battleArea;
		var sheet = this.enemySheets[region];
		if(region > 0) {
			enemyLevel = (enemyLevel + 1) * 10 - 1;
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
		_g.h["Magic Defense"] = 0;
		var stats2 = _g;
		this.wdata.enemy = { level : 1 + enemyLevel, attributesBase : stats2, equipmentSlots : null, equipment : [], xp : null, attributesCalculated : stats2, reference : new ActorReference(1,0)};
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
		}
		var v = this.wdata.enemy.attributesCalculated.h["LifeMax"];
		this.wdata.enemy.attributesCalculated.h["Life"] = v;
	}
	,ReinitGameValues: function() {
		var _gthis = this;
		if(this.wdata.regionProgress == null) {
			this.wdata.regionProgress = [];
		}
		if(this.wdata.battleAreaRegionMax >= 1 == false) {
			this.wdata.battleAreaRegionMax = 1;
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
		var _g = new haxe_ds_StringMap();
		_g.h["Life"] = 20;
		_g.h["LifeMax"] = 20;
		_g.h["Speed"] = 20;
		_g.h["SpeedCount"] = 0;
		_g.h["Attack"] = 1;
		_g.h["Defense"] = 0;
		_g.h["Magic Attack"] = 0;
		_g.h["Magic Defense"] = 0;
		this.wdata.hero.attributesBase = _g;
		var valueXP = 0;
		if(this.wdata.hero.xp != null) {
			valueXP = this.wdata.hero.xp.value;
		}
		var timeLevelUpGrind = this.balancing.timeForFirstLevelUpGrind;
		var initialEnemyXP = 2;
		var initialXPToLevelUp = this.balancing.timeForFirstLevelUpGrind * initialEnemyXP / this.balancing.timeToKillFirstEnemy | 0;
		this.wdata.hero.xp = ResourceLogic.getExponentialResource(1.5,1,initialXPToLevelUp);
		this.wdata.hero.xp.value = valueXP;
		ResourceLogic.recalculateScalingResource(this.wdata.hero.level,this.wdata.hero.xp);
		this.areaBonus = ResourceLogic.getExponentialResource(1.5,1,initialXPToLevelUp * this.balancing.areaBonusXPPercentOfFirstLevelUp / 100 | 0);
		if(this.wdata.hero.equipment == null) {
			this.wdata.hero.equipment = [];
		}
		if(this.wdata.hero.equipmentSlots == null) {
			this.wdata.hero.equipmentSlots = [-1,-1,-1];
		}
		this.RecalculateAttributes(this.wdata.hero);
	}
	,changeRegion: function(region) {
		this.wdata.battleAreaRegion = region;
		if(this.wdata.regionProgress[region] == null) {
			this.wdata.regionProgress[region] = { area : 0, maxArea : 1, amountEnemyKilledInArea : 0};
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
				var v = enemy.attributesCalculated.h["LifeMax"];
				enemy.attributesCalculated.h["Life"] = v;
				enemy.attributesCalculated.h["SpeedCount"] = 0;
			}
		}
		if(this.PlayerFightMode() == false || enemy == null) {
			attackHappen = false;
			var life = this.wdata.hero.attributesCalculated.h["Life"];
			var lifeMax = this.wdata.hero.attributesCalculated.h["LifeMax"];
			life += 2;
			if(this.wdata.sleeping) {
				life += 10;
			}
			if(life > lifeMax) {
				life = lifeMax;
			}
			this.wdata.hero.attributesCalculated.h["Life"] = life;
		}
		if(attackHappen) {
			var gEvent = this.AddEvent(EventTypes.ActorAttack);
			var attacker = hero;
			var defender = enemy;
			var decided = false;
			var _g = 0;
			while(_g < 100) {
				var i = _g++;
				var bActor = hero;
				var _g1 = bActor.attributesCalculated;
				var v = _g1.h["SpeedCount"] + bActor.attributesCalculated.h["Speed"];
				_g1.h["SpeedCount"] = v;
				var sc = bActor.attributesCalculated.h["SpeedCount"];
				if(decided == false) {
					if(bActor.attributesCalculated.h["SpeedCount"] > 100) {
						var v1 = bActor.attributesCalculated.h["SpeedCount"] - 100;
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
					if(bActor1.attributesCalculated.h["SpeedCount"] > 100) {
						var v3 = bActor1.attributesCalculated.h["SpeedCount"] - 100;
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
			var damage = attacker.attributesCalculated.h["Attack"] - defender.attributesCalculated.h["Defense"];
			if(damage < 0) {
				damage = 0;
			}
			var _g = defender.attributesCalculated;
			var v = _g.h["Life"] - damage;
			_g.h["Life"] = v;
			if(defender.attributesCalculated.h["Life"] < 0) {
				defender.attributesCalculated.h["Life"] = 0;
			}
			gEvent.origin = attacker.reference;
			gEvent.target = defender.reference;
			gEvent.data = damage;
			if(enemy.attributesCalculated.h["Life"] <= 0) {
				if(killedInArea[battleArea] == null) {
					killedInArea[battleArea] = 0;
				}
				killedInArea[battleArea]++;
				if(this.random.randomInt(0,100) < this.equipDropChance) {
					var equipType = this.random.randomInt(0,1);
					var e = null;
					var dropQuality = enemy.level;
					if(this.wdata.battleAreaRegion > 0) {
						dropQuality = 1.2 * dropQuality | 0;
					}
					if(equipType == 0) {
						var attackBonus = this.random.randomInt(1,dropQuality / 2 + 2 | 0);
						var _g = new haxe_ds_StringMap();
						_g.h["Attack"] = attackBonus;
						e = { type : 0, requiredAttributes : null, attributes : _g};
						if(this.random.randomInt(0,100) < 15) {
							var lifeBonus = this.random.randomInt(1,dropQuality + 2 | 0);
							e.attributes.h["LifeMax"] = lifeBonus;
						}
						if(this.random.randomInt(0,100) < 15) {
							var bonus = this.random.randomInt(1,dropQuality / 8 + 2 | 0);
							e.attributes.h["Speed"] = bonus;
						}
						if(this.random.randomInt(0,100) < 15) {
							var bonus = this.random.randomInt(1,dropQuality / 8 + 2 | 0);
							e.attributes.h["Defense"] = bonus;
						}
					}
					if(equipType == 1) {
						var armorType = this.random.randomInt(0,1);
						var mainBonus = this.random.randomInt(1,dropQuality / 2 + 2 | 0);
						var mainBonusType = "LifeMax";
						if(armorType == 0) {
							mainBonus *= 3;
						}
						if(armorType == 1) {
							mainBonusType = "Defense";
						}
						var _g = new haxe_ds_StringMap();
						_g.h[mainBonusType] = mainBonus;
						e = { type : 1, requiredAttributes : null, attributes : _g};
						if(this.random.randomInt(0,100) < 20) {
							var bonus = this.random.randomInt(1,dropQuality / 4 + 2 | 0);
							e.attributes.h["Attack"] = bonus;
						}
						if(this.random.randomInt(0,100) < 20) {
							var bonus = this.random.randomInt(1,enemy.attributesCalculated.h["Attack"] / 8 + 2 | 0);
							e.attributes.h["Speed"] = bonus;
						}
					}
					this.wdata.hero.equipment.push(e);
					var e = this.AddEvent(EventTypes.EquipDrop);
					e.data = this.wdata.hero.equipment.length - 1;
					e.origin = enemy.reference;
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
							this.AddEvent(EventTypes.PermanentStatUpgrade);
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
		return "";
	}
	,DiscardEquipment: function(pos) {
		this.wdata.hero.equipment[pos] = null;
		this.RecalculateAttributes(this.wdata.hero);
	}
	,ToggleEquipped: function(pos) {
		var slot = this.wdata.hero.equipment[pos].type;
		if(this.wdata.hero.equipmentSlots[slot] == pos) {
			this.wdata.hero.equipmentSlots[slot] = -1;
		} else {
			this.wdata.hero.equipmentSlots[slot] = pos;
		}
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
		if(this.wdata.regionProgress == null) {
			this.wdata.regionProgress = [];
		}
		while(this.wdata.regionProgress.length <= this.wdata.battleAreaRegion) this.wdata.regionProgress.push({ area : -1, maxArea : -1, amountEnemyKilledInArea : -1});
		this.wdata.regionProgress[this.wdata.battleAreaRegion].area = this.wdata.battleArea;
		this.wdata.regionProgress[this.wdata.battleAreaRegion].maxArea = this.wdata.maxArea;
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
		var hasEquipment = this.wdata.hero.equipment.length > 0;
		var lu = this.wdata.playerActions.h["tabequipment"];
		lu.enabled = hasEquipment;
		lu.visible = lu.enabled || lu.visible;
		var lu = this.wdata.playerActions.h["levelup"];
		lu.enabled = this.canLevelUp;
		lu.visible = this.canLevelUp || lu.visible;
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
	}
	,RecalculateAttributes: function(actor) {
		var oldLife = actor.attributesCalculated.h["Life"];
		var oldSpeedCount = actor.attributesCalculated.h["SpeedCount"];
		if(oldSpeedCount < 0) {
			oldSpeedCount = 0;
		}
		if(oldSpeedCount == null) {
			oldSpeedCount = 0;
		}
		var actor1 = actor.attributesBase;
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		_g.h["LifeMax"] = 5;
		_g.h["Life"] = 5;
		_g.h["Speed"] = 0;
		_g.h["Defense"] = 0;
		_g.h["Magic Defense"] = 0;
		_g.h["SpeedCount"] = 0;
		AttributeLogic.Add(actor1,_g,actor.level,actor.attributesCalculated);
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
		actor.attributesCalculated.h["Life"] = oldLife;
		actor.attributesCalculated.h["SpeedCount"] = oldSpeedCount;
		if(actor == this.wdata.hero) {
			var _g = 0;
			var _g1 = this.wdata.regionProgress.length;
			while(_g < _g1) {
				var i = _g++;
				var pro = this.wdata.regionProgress[i];
				var prize = this.regionPrizes[i];
				if(pro.area >= 1 && prize.statBonus != null) {
					AttributeLogic.Add(actor.attributesCalculated,prize.statBonus,pro.area,actor.attributesCalculated);
				}
			}
		}
	}
	,AdvanceArea: function() {
		this.ChangeBattleArea(this.wdata.battleArea + 1);
	}
	,DiscardWorseEquipment: function() {
		var _g = 0;
		var _g1 = this.wdata.hero.equipment.length;
		while(_g < _g1) {
			var i = _g++;
			var e = this.wdata.hero.equipment[i];
			if(e == null) {
				continue;
			}
			var _g2 = i + 1;
			var _g3 = this.wdata.hero.equipment.length;
			while(_g2 < _g3) {
				var j = _g2++;
				var e2 = this.wdata.hero.equipment[j];
				if(e2 == null) {
					continue;
				}
				if(e.type != e2.type) {
					continue;
				}
				var r = this.CompareEquipmentStrength(e,e2);
				if(r == 1 || r == 0) {
					this.wdata.hero.equipment[j] = null;
					continue;
				}
				if(r == 2) {
					this.wdata.hero.equipment[i] = null;
					break;
				}
			}
		}
	}
	,CompareEquipmentStrength: function(e1,e2) {
		var e1Superior = 0;
		var e2Superior = 0;
		var h = e1.attributes.h;
		var attrKey_h = h;
		var attrKey_keys = Object.keys(h);
		var attrKey_length = attrKey_keys.length;
		var attrKey_current = 0;
		while(attrKey_current < attrKey_length) {
			var attrKey = attrKey_keys[attrKey_current++];
			if(Object.prototype.hasOwnProperty.call(e2.attributes.h,attrKey)) {
				if(e1.attributes.h[attrKey] > e2.attributes.h[attrKey]) {
					e1Superior = 1;
				}
				if(e1.attributes.h[attrKey] < e2.attributes.h[attrKey]) {
					e2Superior = 1;
				}
			} else {
				e1Superior = 1;
			}
			if(e1Superior == 1 && e2Superior == 1) {
				return -1;
			}
		}
		var h = e2.attributes.h;
		var attrKey_h = h;
		var attrKey_keys = Object.keys(h);
		var attrKey_length = attrKey_keys.length;
		var attrKey_current = 0;
		while(attrKey_current < attrKey_length) {
			var attrKey = attrKey_keys[attrKey_current++];
			if(Object.prototype.hasOwnProperty.call(e1.attributes.h,attrKey)) {
				if(e1.attributes.h[attrKey] > e2.attributes.h[attrKey]) {
					e1Superior = 1;
				}
				if(e1.attributes.h[attrKey] < e2.attributes.h[attrKey]) {
					e2Superior = 1;
				}
			} else {
				e2Superior = 1;
			}
			if(e1Superior == 1 && e2Superior == 1) {
				return -1;
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
			loadedWdata.regionProgress.push({ area : loadedWdata.battleArea, maxArea : loadedWdata.maxArea, amountEnemyKilledInArea : loadedWdata.killedInArea[loadedWdata.battleArea]});
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
MainTest.main = function() {
	process.stdout.write("resource load text");
	process.stdout.write("\n");
	var sj = haxe_Resource.getString("storyjson");
	process.stdout.write(Std.string(sj));
	process.stdout.write("\n");
	JSON.parse(sj);
	process.stdout.write("Discard worse equip tests");
	process.stdout.write("\n");
	var bm = new BattleManager();
	bm.DefaultConfiguration();
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	bm.DiscardWorseEquipment();
	var numberOfNullEquipment = 0;
	var _g = 0;
	var _g1 = bm.wdata.hero.equipment;
	while(_g < _g1.length) {
		var e = _g1[_g];
		++_g;
		if(e == null) {
			++numberOfNullEquipment;
		}
	}
	if(numberOfNullEquipment != 0) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 0"));
		process.stdout.write("\n");
	}
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Life"] = 3;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	bm.DiscardWorseEquipment();
	numberOfNullEquipment = 0;
	var _g = 0;
	var _g1 = bm.wdata.hero.equipment;
	while(_g < _g1.length) {
		var e = _g1[_g];
		++_g;
		if(e == null) {
			++numberOfNullEquipment;
		}
	}
	if(numberOfNullEquipment != 2) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 2"));
		process.stdout.write("\n");
	}
	if(bm.wdata.hero.equipment[0] == null) {
		process.stdout.write("ERROR: discard worse equipment problem 0");
		process.stdout.write("\n");
	}
	if(bm.wdata.hero.equipment[1] != null) {
		process.stdout.write("ERROR: discard worse equipment problem 1");
		process.stdout.write("\n");
	}
	if(bm.wdata.hero.equipment[2] != null) {
		process.stdout.write("ERROR: discard worse equipment problem 2");
		process.stdout.write("\n");
	}
	if(bm.wdata.hero.equipment[3] == null) {
		process.stdout.write("ERROR: discard worse equipment problem 3");
		process.stdout.write("\n");
	}
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Life"] = 2;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	var bm1 = bm.wdata.hero.equipment;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Defense"] = 1;
	bm1.push({ type : 0, requiredAttributes : null, attributes : _g});
	bm.DiscardWorseEquipment();
	numberOfNullEquipment = 0;
	var _g = 0;
	var _g1 = bm.wdata.hero.equipment;
	while(_g < _g1.length) {
		var e = _g1[_g];
		++_g;
		if(e == null) {
			++numberOfNullEquipment;
		}
	}
	if(numberOfNullEquipment != 2) {
		process.stdout.write(Std.string("ERROR: discard worse equipment problem: " + numberOfNullEquipment + " VS 2 (b)"));
		process.stdout.write("\n");
	}
	process.stdout.write("Save legacy test");
	process.stdout.write("\n");
	var _g = 0;
	var _g1 = js_node_Fs.readdirSync("saves/");
	while(_g < _g1.length) {
		var file = _g1[_g];
		++_g;
		console.log("test/MainTest.hx:80:",file);
		var path = haxe_io_Path.join(["saves/",file]);
		var json = js_node_Fs.readFileSync(path,{ encoding : "utf8"});
		var bm = new BattleManager();
		bm.SendJsonPersistentData(SaveAssistant.GetPersistenceMaster(json).jsonGameplay);
		var _g2 = 1;
		while(_g2 < 400) {
			var i = _g2++;
			bm.update(0.9);
		}
	}
	process.stdout.write("Test region progress");
	process.stdout.write("\n");
	var bm = new BattleManager();
	bm.DefaultConfiguration();
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
	var bm = new BattleManager();
	bm.DefaultConfiguration();
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
	process.stdout.write("Easy area no death");
	process.stdout.write("\n");
	var bm = new BattleManager();
	bm.DefaultConfiguration();
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
	var bm = new BattleManager();
	bm.DefaultConfiguration();
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
		console.log("test/MainTest.hx:205:","  _____ ");
		console.log("test/MainTest.hx:206:","  _____ ");
		console.log("test/MainTest.hx:207:","  _____ ");
		console.log("test/MainTest.hx:208:",json);
		console.log("test/MainTest.hx:209:","  _____ ");
		console.log("test/MainTest.hx:210:","  _____ ");
		console.log("test/MainTest.hx:211:","  _____ ");
		console.log("test/MainTest.hx:212:",json2);
		js_node_Fs.writeFileSync("error/json.json",json);
		js_node_Fs.writeFileSync("error/json2.json",json2);
	}
};
Math.__name__ = true;
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
		var v = attributes.h[key1] + (value * quantityOfAddition | 0);
		result.h[key1] = v;
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
};
EventTypes.__constructs__ = [EventTypes.GameStart,EventTypes.ActorDead,EventTypes.EquipDrop,EventTypes.ActorAppear,EventTypes.ActorAttack,EventTypes.ActorLevelUp,EventTypes.AreaUnlock,EventTypes.RegionUnlock,EventTypes.AreaComplete,EventTypes.AreaEnterFirstTime,EventTypes.GetXP,EventTypes.PermanentStatUpgrade,EventTypes.statUpgrade];
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
haxe_Resource.content = [{ name : "storyjson", data : "W3sibWVzc2FnZXMiOlt7ImJvZHkiOiIgV2hlcmUgYXJlIHlvdSBnb2luZz8iLCJzcGVha2VyIjoiTW9tIn0seyJib2R5IjoiIEtpbGwgc29tZSBtb25zdGVycywgbW9tIiwic3BlYWtlciI6IllvdSJ9LHsiYm9keSI6IiBUaGlzIGtpZC4uLiIsInNwZWFrZXIiOiJNb20ifV0sInRpdGxlIjoiVGhpcyBraWQuLi4iLCJ2aXNpYmlsaXR5U2NyaXB0IjpudWxsLCJhY3Rpb25MYWJlbCI6Ildha2UgdXAifSx7Im1lc3NhZ2VzIjpbeyJib2R5IjoiIEknbSBiYWNrIiwic3BlYWtlciI6IllvdSJ9LHsiYm9keSI6IiBHb29kLCBpdCdzIHRpbWUgZm9yIGRpbm5lci4iLCJzcGVha2VyIjoiTW9tIn0seyJib2R5IjoiIEhleSBtb20uLi4iLCJzcGVha2VyIjoiWW91In0seyJib2R5IjoiIFdoYXQgaXMgd3JvbmcsIGRlYXI/Iiwic3BlYWtlciI6Ik1vbSJ9LHsiYm9keSI6IiBJJ20gbGVhdmluZyB0b3duIiwic3BlYWtlciI6IllvdSJ9LHsiYm9keSI6IiBIYWhhaGFoYWEsIG9oIFlvdS4uLiIsInNwZWFrZXIiOiJNb20ifSx7ImJvZHkiOiIgQW5kIEknbSBNYm9pLCBHb2Qgb2YgV2F0ZXJ3YXlzISIsInNwZWFrZXIiOiJNb20ifSx7ImJvZHkiOiIgLi4uIiwic3BlYWtlciI6IllvdSJ9LHsiYm9keSI6IiBDJ21vbiwgZWF0IHVwLiIsInNwZWFrZXIiOiJNb20ifV0sInRpdGxlIjoiVGltZSBmb3IgZGlubmVyIiwidmlzaWJpbGl0eVNjcmlwdCI6IiByZXR1cm4gZ2xvYmFsW1wibWF4YXJlYVwiXSA+IDI7ICIsImFjdGlvbkxhYmVsIjoiR28gaG9tZSJ9XQ"}];
js_Boot.__toStr = ({ }).toString;
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
