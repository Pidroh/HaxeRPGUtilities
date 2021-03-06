// package logic;

class ResourceLogic {
	public static function recalculateScalingResource(base:Int, res:ScalingResource) {
		if (res.lastUsedBaseAttribute != base) {
			var data1 = res.scaling.data1;
			var baseValue = res.scaling.initial;
			if (res.scaling.initialMultiplication) {
				baseValue *= base;
			}
			var expBonus:Float = 0;
			if (res.scaling.exponential) {
				expBonus = Math.pow(data1, base);
			}

			var calculated = Std.int(expBonus + baseValue);

			// uses only the minimum increment
			calculated = calculated - calculated % res.scaling.minimumIncrement;
			res.calculatedMax = calculated;
			res.lastUsedBaseAttribute = base;
			// trace(res);
		}
	}

	public static function getExponentialResource(expBase:Float, minimumIncrement:Int, initial:Int):ScalingResource {
		var res:ScalingResource = {
			scaling: {
				data1: expBase,
				initial: initial,
				minimumIncrement: minimumIncrement,
				initialMultiplication: true,
				exponential: true
			},
			value: 0,
			lastUsedBaseAttribute: 0,
			calculatedMax: 0
		};
		recalculateScalingResource(1, res);
		// trace(res);
		return res;
	}
}

class AttributeLogic {
	public static function AddOld(attributes:Map<String, Int>, attributeAddition:Map<String, Float>, quantityOfAddition:Int) {
		for (key => value in attributes) {
			attributes[key] += Std.int(attributeAddition[key] * quantityOfAddition);
		}
	}

	public static function Add(attributes:Map<String, Int>, attributeAddition:Map<String, Int>, quantityOfAddition:Int, result:Map<String, Int>) {
		for (key => value in attributes) {
			var addedValue = attributeAddition[key];
			// this will always be false, unless it is null / undefined
			if (addedValue >= 0 == false && addedValue < 0 == false) {
				addedValue = 0;
			}
			result[key] = value + Std.int(addedValue * quantityOfAddition);
		}

		// only do attributes not in original map
		for (key => value in attributeAddition) {
			if (attributes.exists(key) == false) {
				result[key] = value;
			}
		}
	}
}

typedef ActorSheet = {
	var speciesMultiplier:LevelGrowth;
	var speciesAdd:Map<String, Int>;
	var speciesLevelStats:LevelGrowth;
	var ?initialBuff:Buff;
}

typedef EquipmentSet = {
	var equipmentSlots:Array<Int>;
}

typedef Actor = {
	var level:Int;
	var xp:ScalingResource;
	var attributesBase:Map<String, Int>;
	var attributesCalculated:Map<String, Int>;
	var equipment:Array<Equipment>;
	var ?equipmentSets  : Array<EquipmentSet>;
	var ?chosenEquipSet : Int;
	//var equipmentSlots:Array<Int>;
	var ?turnRecharge:Array<Int>;
	var reference:ActorReference;
	var ?buffs:Array<Buff>;
	var ?usableSkills:Array<SkillUsable>;
}

typedef LevelGrowth = {
	var attributesBase:Map<String, Float>;
}

typedef ScalingResource = {
	var value:Int;
	var scaling:Scaling;

	// this is buffered data to avoid recalculation
	var calculatedMax:Int;
	var lastUsedBaseAttribute:Int;
}

typedef Scaling = {
	var initial:Int;
	var data1:Float;
	var minimumIncrement:Int;
	var exponential:Bool;
	var initialMultiplication:Bool;
}

typedef EquipmentLevel = {
	var level:Int;
	var limitbreak:Int;
	var ascension:Int;
}

typedef Equipment = {
	var type:Int;
	var requiredAttributes:Map<String, Int>;
	var attributes:Map<String, Int>;
	var ?outsideSystems:Map<String, Int>;
	var ?attributeMultiplier:Map<String, Int>;
	var ?generationVariations:Map<String, Int>;
	var ?generationVariationsMultiplier:Map<String, Int>;
	var ?generationLevel:Int;
	var ?generationBaseItem:Int;
	var ?generationPrefixMod:Int;
	var ?generationSuffixMod:Int;
	var ?generationPrefixModSeed:Int;
	var ?generationSuffixModSeed:Int;
	var seen:Int; // 0: unseen 1: fresh 2: seen
}

typedef PlayerAction = {
	public var visible:Bool;
	public var enabled:Bool;
	public var timesUsed:Int;
	public var mode:Int;
}

typedef Balancing = {
	public var timeToKillFirstEnemy:Float;
	public var timeForFirstLevelUpGrind:Float;
	public var timeForFirstAreaProgress:Float;
	public var areaBonusXPPercentOfFirstLevelUp:Int;
}

typedef AreaPersistence = {
	var area:Int;
	var maxArea:Int;
	var maxAreaRecord:Int;
	var maxAreaOnPrestigeRecord:Array<Int>;
	var amountEnemyKilledInArea:Int;
}

typedef CurrencyHolderRuntime = {
	var maxValues:Map<String, Int>;
}

typedef CurrencyPersistent = {
	var value:Int;
	var visible:Bool;
}

typedef CurrencyHolderPersistent = {
	public var currencies:Map<String, CurrencyPersistent>;
}

typedef WorldData = {
	var worldVersion:Int;
	var hero:Actor;
	var enemy:Actor;
	var timeCount:Float;
	var regionProgress:Array<AreaPersistence>;
	var battleAreaRegion:Int;
	var battleAreaRegionMax:Int;
	var playerTimesKilled:Int;
	var killedInArea:Array<Int>;
	var necessaryToKillInArea:Int;
	var playerActions:Map<String, PlayerAction>;
	var recovering:Bool;
	var sleeping:Bool;
	var prestigeTimes:Int;

	var ?currency:CurrencyHolderPersistent;
	var ?skillSets:Array<SkillSet>;
	var ?equipLevels:Array<EquipmentLevel>;
	// Easier access for the data in region progress. Has to copy the data back in update.
	var battleArea:Int;
	var maxArea:Int;
}

enum EventTypes {
	GameStart;
	ActorDead;
	EquipDrop;
	ActorAppear;
	ActorAttack;
	ActorLevelUp;
	AreaUnlock;
	RegionUnlock;
	AreaComplete;
	AreaEnterFirstTime;
	GetXP;
	PermanentStatUpgrade;
	statUpgrade;
	SkillUse;
	MPRunOut;
	BuffRemoval;
	DebuffBlock;
	EquipMaxed;
}

class ActorReference {
	public var type:Int;
	public var pos:Int;

	public function new(type, pos) {
		this.type = type;
		this.pos = pos;
	}
}

class GameEvent {
	public var type:EventTypes;
	public var origin:ActorReference;
	public var target:ActorReference;
	public var data:Int;
	public var dataString:String = null;

	public function new(eType) {
		type = eType;
	}
}

enum Target {
	SELF;
	ENEMY;
	ALL;
}

typedef Buff = {
	var uniqueId:String;
	var strength:Int; // this is used for overwriting with stronger buffs
	var duration:Int;
	var addStats:Map<String, Int>;
	var mulStats:Map<String, Int>;
	var ?noble:Bool;
	var ?debuff:Bool;
}

typedef Effect = {
	var target:Target;
	var effectExecution:(BattleManager, Int, Actor, Array<Actor>) -> Void;
}

typedef SkillUsable = {
	var id:String;
	var level:Int;
}

typedef Skill = {
	var id:String;
	var word:String;
	var profession:String;
	var effects:Array<Effect>;
	var ?activeEffect:Array<Effect>;
	var ?turnRecharge:Int;
	var mpCost:Int;
}

typedef SkillSet = {
	var skills:Array<SkillUsable>;
}
