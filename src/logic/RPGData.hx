//package logic;

class ResourceLogic {
	public static function recalculateScalingResource(base:Int, res:ScalingResource) {
		if (res.lastUsedBaseAttribute != base) {
			var data1 = res.scaling.data1;
			var calculated = Std.int(Math.pow(data1, base) + res.scaling.initial);

			// uses only the minimum increment
			calculated = calculated - calculated % res.scaling.minimumIncrement;
			res.calculatedMax = calculated;
			res.lastUsedBaseAttribute = base;
			//trace(res);
		}
	}

	public static function getExponentialResource(expBase:Float, minimumIncrement:Int, initial:Int):ScalingResource {
		var res : ScalingResource = {
			scaling: {data1: expBase, initial: initial, minimumIncrement: minimumIncrement, type: exponential},
			value: 0,
			lastUsedBaseAttribute: 0,
			calculatedMax: 0
		};
		recalculateScalingResource(1, res);
		//trace(res);
		return res;
	}
}

class AttributeLogic {
	public static function AddOld(attributes:Map<String, Int>, attributeAddition:Map<String, Float>, quantityOfAddition:Int) {
		for(key => value in attributes){
			attributes[key] += Std.int(attributeAddition[key]*quantityOfAddition);
		}
	}
	public static function Add(attributes:Map<String, Int>, attributeAddition:Map<String, Float>, quantityOfAddition:Int, result:Map<String, Int>) {
		for(key => value in attributeAddition){
			result[key] = attributes[key] + Std.int(value*quantityOfAddition);
		}
	}
}

typedef Actor = {
	var level:Int;
	var xp:ScalingResource;
	var attributesBase:Map<String, Int>;
	var attributesCalculated:Map<String, Int>;
	var equipment:Array<Equipment>;
	var equipmentSlots:Array<Int>;
	var reference : ActorReference;
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
	var type:ScalingType;
}

enum ScalingType {
	exponential;
}

typedef Equipment = {
	var type:Int;
	var requiredAttributes:Map<String, Int>;
	var attributes:Map<String, Int>;
}

typedef WorldData = {
	var hero:Actor;
	var enemy:Actor;
	var turn:Bool;
	var timeCount:Float;
	var timePeriod:Float;
	var battleArea:Int;
	var playerTimesKilled:Int;
	var killedInArea:Array<Int>;
	var necessaryToKillInArea:Int;
	var maxArea:Int;

}

enum EventTypes{
	GameStart;
	ActorDead; 
	ActorAppear;
	ActorAttack;
	LevelUp;
	AreaUnlock;
	AreaEnterFirstTime;
}

class ActorReference{
	public var type:Int;
	public var pos:Int;

	public function new (type, pos){
		this.type = type;
		this.pos = pos;
	}
}

class GameEvent {
	public var type:EventTypes;
	public var origin : ActorReference;
	public var target : ActorReference;
	public var data : Int;
	public function new (eType){
		type = eType;
	}
}

