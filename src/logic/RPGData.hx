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
		for (key => value in attributeAddition) {
			result[key] = attributes[key] + Std.int(value * quantityOfAddition);
		}
	}
}

typedef ActorSheet = {
	var speciesMultiplier:LevelGrowth;
	var speciesAdd:Map<String, Int>;
	var speciesLevelStats:LevelGrowth;
}

typedef Actor = {
	var level:Int;
	var xp:ScalingResource;
	var attributesBase:Map<String, Int>;
	var attributesCalculated:Map<String, Int>;
	var equipment:Array<Equipment>;
	var equipmentSlots:Array<Int>;
	var reference:ActorReference;
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

typedef Equipment = {
	var type:Int;
	var requiredAttributes:Map<String, Int>;
	var attributes:Map<String, Int>;
	var ?attributeMultiplier:Map<String, Int>;
	var ?generationVariations:Map<String, Int>;
	var ?generationVariationsMultiplier:Map<String, Int>;
	var ?generationLevel:Int;
	var ?generationBaseItem:Int;
	var seen:Bool;
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
	var maxAreaOnPrestigeRecord: Array<Int>;
	var amountEnemyKilledInArea:Int;
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
