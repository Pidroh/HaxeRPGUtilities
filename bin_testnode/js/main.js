(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var BattleManager = function() {
	this.events = [];
	this.timePeriod = 0.6;
	this.canLevelUp = false;
	this.canAdvance = false;
	this.canRetreat = false;
	this.dirty = false;
	this.balancing = { timeToKillFirstEnemy : 5, timeForFirstAreaProgress : 20, timeForFirstLevelUpGrind : 90, areaBonusXPPercentOfFirstLevelUp : 60};
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	var stats = _g;
	var stats2_h = Object.create(null);
	stats2_h["Attack"] = 2;
	stats2_h["Life"] = 6;
	stats2_h["LifeMax"] = 6;
	var w = { hero : { level : 1, attributesBase : stats, equipmentSlots : null, equipment : null, xp : null, attributesCalculated : haxe_ds_StringMap.createCopy(stats.h), reference : new ActorReference(0,0)}, enemy : null, maxArea : 1, necessaryToKillInArea : 0, killedInArea : [0,0], timeCount : 0, playerTimesKilled : 0, battleArea : 0, turn : false, playerActions : new haxe_ds_StringMap(), recovering : false};
	w.playerActions.h["advance"] = { visible : true, enabled : false};
	w.playerActions.h["retreat"] = { visible : false, enabled : false};
	w.playerActions.h["levelup"] = { visible : false, enabled : false};
	this.wdata = w;
	this.ReinitGameValues();
	this.ChangeBattleArea(0);
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
			if(this.wdata.recovering == false) {
				this.CreateAreaEnemy();
			}
		} else {
			this.wdata.enemy = null;
		}
		ResourceLogic.recalculateScalingResource(this.wdata.battleArea,this.areaBonus);
		this.dirty = true;
	}
	,AwardXP: function(xpPlus) {
		this.wdata.hero.xp.value += xpPlus;
		var e = this.AddEvent(EventTypes.GetXP);
		e.data = xpPlus;
	}
	,CreateAreaEnemy: function() {
		var area = this.wdata.battleArea;
		var timeToKillEnemy = this.balancing.timeToKillFirstEnemy;
		var initialAttackHero = 1;
		var heroAttackTime = this.timePeriod * 2;
		var heroDPS = initialAttackHero / heroAttackTime;
		var initialLifeEnemy = heroDPS * timeToKillEnemy | 0;
		var enemyLife = initialLifeEnemy + (area - 1) * initialLifeEnemy;
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1 + (area - 1);
		_g.h["Life"] = enemyLife;
		_g.h["LifeMax"] = enemyLife;
		var stats2 = _g;
		this.wdata.enemy = { level : 1 + area, attributesBase : stats2, equipmentSlots : null, equipment : [], xp : null, attributesCalculated : stats2, reference : new ActorReference(1,0)};
	}
	,ReinitGameValues: function() {
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
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		var e = { type : 0, requiredAttributes : null, attributes : _g};
		this.wdata.hero.equipment = [];
		this.wdata.hero.equipment[0] = e;
		if(this.wdata.hero.equipmentSlots == null) {
			this.wdata.hero.equipmentSlots = [];
		}
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
		if(this.wdata.battleArea > 0 && this.wdata.recovering == false && areaComplete == false) {
			if(enemy == null) {
				this.CreateAreaEnemy();
				enemy = this.wdata.enemy;
				attackHappen = false;
			}
			if(enemy.attributesCalculated.h["Life"] <= 0) {
				attackHappen = false;
				var v = enemy.attributesCalculated.h["LifeMax"];
				enemy.attributesCalculated.h["Life"] = v;
			}
		}
		if(this.wdata.recovering || enemy == null) {
			attackHappen = false;
			var life = this.wdata.hero.attributesCalculated.h["Life"];
			var lifeMax = this.wdata.hero.attributesCalculated.h["LifeMax"];
			life += 2;
			if(life > lifeMax) {
				life = lifeMax;
			}
			this.wdata.hero.attributesCalculated.h["Life"] = life;
		}
		if(attackHappen) {
			var gEvent = this.AddEvent(EventTypes.ActorAttack);
			var attacker = hero;
			var defender = enemy;
			var which = 0;
			if(this.wdata.turn) {
				attacker = enemy;
				defender = hero;
			}
			var damage = attacker.attributesCalculated.h["Attack"];
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
				var e = this.AddEvent(EventTypes.ActorDead);
				e.origin = enemy.reference;
				var xpGain = enemy.level;
				this.AwardXP(enemy.level);
				if(killedInArea[battleArea] >= this.wdata.necessaryToKillInArea) {
					if(this.wdata.maxArea == this.wdata.battleArea) {
						ResourceLogic.recalculateScalingResource(this.wdata.battleArea,this.areaBonus);
						var xpPlus = this.areaBonus.calculatedMax;
						this.AwardXP(xpPlus);
						this.wdata.maxArea++;
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
		this.wdata.turn = !this.wdata.turn;
		return "";
	}
	,ToggleEquipped: function(pos) {
		if(this.wdata.hero.equipmentSlots.indexOf(pos) != -1) {
			HxOverrides.remove(this.wdata.hero.equipmentSlots,pos);
		} else {
			this.wdata.hero.equipmentSlots.push(pos);
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
		this.canAdvance = this.wdata.battleArea < this.wdata.maxArea;
		this.canRetreat = this.wdata.battleArea > 0;
		this.canLevelUp = this.wdata.hero.xp.value >= this.wdata.hero.xp.calculatedMax;
		var lu = this.wdata.playerActions.h["levelup"];
		lu.visible = this.canLevelUp;
		lu.enabled = this.canLevelUp;
		var lu = this.wdata.playerActions.h["advance"];
		lu.visible = this.canAdvance || lu.visible;
		lu.enabled = this.canAdvance;
		var lu = this.wdata.playerActions.h["retreat"];
		lu.visible = this.canRetreat || lu.visible;
		lu.enabled = this.canRetreat;
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
		var hero = this.wdata.hero;
		if(this.canLevelUp) {
			hero.xp.value -= hero.xp.calculatedMax;
			hero.level++;
			this.AddEvent(EventTypes.ActorLevelUp);
			this.RecalculateAttributes(hero);
			ResourceLogic.recalculateScalingResource(hero.level,hero.xp);
		}
	}
	,RecalculateAttributes: function(actor) {
		var actor1 = actor.attributesBase;
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 1;
		_g.h["LifeMax"] = 5;
		_g.h["Life"] = 5;
		AttributeLogic.Add(actor1,_g,actor.level,actor.attributesCalculated);
		var _g = 0;
		var _g1 = actor.equipmentSlots;
		while(_g < _g1.length) {
			var es = _g1[_g];
			++_g;
			var e = actor.equipment[es];
			AttributeLogic.Add(actor.attributesCalculated,e.attributes,1,actor.attributesCalculated);
		}
	}
	,AdvanceArea: function() {
		this.ChangeBattleArea(this.wdata.battleArea + 1);
	}
	,GetJsonPersistentData: function() {
		return JSON.stringify(this.wdata);
	}
	,SendJsonPersistentData: function(jsonString) {
		this.wdata = JSON.parse(jsonString);
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
MainTest.main = function() {
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
		console.log("test/MainTest.hx:98:","  _____ ");
		console.log("test/MainTest.hx:99:","  _____ ");
		console.log("test/MainTest.hx:100:","  _____ ");
		console.log("test/MainTest.hx:101:",json);
		console.log("test/MainTest.hx:102:","  _____ ");
		console.log("test/MainTest.hx:103:","  _____ ");
		console.log("test/MainTest.hx:104:","  _____ ");
		console.log("test/MainTest.hx:105:",json2);
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
	,ActorAppear: {_hx_name:"ActorAppear",_hx_index:2,__enum__:"EventTypes",toString:$estr}
	,ActorAttack: {_hx_name:"ActorAttack",_hx_index:3,__enum__:"EventTypes",toString:$estr}
	,ActorLevelUp: {_hx_name:"ActorLevelUp",_hx_index:4,__enum__:"EventTypes",toString:$estr}
	,AreaUnlock: {_hx_name:"AreaUnlock",_hx_index:5,__enum__:"EventTypes",toString:$estr}
	,AreaEnterFirstTime: {_hx_name:"AreaEnterFirstTime",_hx_index:6,__enum__:"EventTypes",toString:$estr}
	,GetXP: {_hx_name:"GetXP",_hx_index:7,__enum__:"EventTypes",toString:$estr}
};
EventTypes.__constructs__ = [EventTypes.GameStart,EventTypes.ActorDead,EventTypes.ActorAppear,EventTypes.ActorAttack,EventTypes.ActorLevelUp,EventTypes.AreaUnlock,EventTypes.AreaEnterFirstTime,EventTypes.GetXP];
var ActorReference = function(type,pos) {
	this.type = type;
	this.pos = pos;
};
ActorReference.__name__ = true;
var GameEvent = function(eType) {
	this.type = eType;
};
GameEvent.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
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
var haxe_ds_StringMap = function() {
	this.h = Object.create(null);
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.createCopy = function(h) {
	var copy = new haxe_ds_StringMap();
	for (var key in h) copy.h[key] = h[key];
	return copy;
};
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe_io_Bytes.__name__ = true;
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__:true,__constructs__:null
	,UTF8: {_hx_name:"UTF8",_hx_index:0,__enum__:"haxe.io.Encoding",toString:$estr}
	,RawNative: {_hx_name:"RawNative",_hx_index:1,__enum__:"haxe.io.Encoding",toString:$estr}
};
haxe_io_Encoding.__constructs__ = [haxe_io_Encoding.UTF8,haxe_io_Encoding.RawNative];
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
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.__name__ = true;
Array.__name__ = true;
js_Boot.__toStr = ({ }).toString;
MainTest.main();
})({});
