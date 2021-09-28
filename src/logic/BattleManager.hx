class BattleManager {
	var hero:Actor;
	var enemy:Actor;
    var turn:Bool;
    var timeCount:Float;
    var timePeriod:Float = 1;
	var battleArea: Int;
	var playerTimesKilled : Int;


	public function ChangeBattleArea(area:Int){
		battleArea = area;
		var enemyLife = 6 + area;
		var stats2 = ["Attack"=> 2+area, "Life" => enemyLife, "LifeMax" => enemyLife];
		enemy = {level:1+area, attributesBase:stats2, equipmentSlots: null, equipment: null, xp:null, attributesCalculated: stats2};
	}

    public function new (){
		
		var stats = ["Attack"=> 5, "Life" => 20, "LifeMax" => 20];
        hero = {level:1, attributesBase:stats, equipmentSlots: null, equipment: null, 
			xp:ResourceLogic.getExponentialResource(1.5, 1, 5), attributesCalculated: stats};
		var stats2 = ["Attack"=> 2, "Life" => 6, "LifeMax"=> 6];
		enemy = {level:1, attributesBase:stats2, equipmentSlots: null, equipment: null, xp:null, attributesCalculated: stats2};
        timeCount = 0;
    }

	public function advance() {
        var event : String = "";
		if (hero.attributesCalculated["Life"] <= 0) {
			playerTimesKilled++;
            event += "You died\n\n\n";
			hero.attributesCalculated["Life"] = hero.attributesCalculated["LifeMax"];
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
			// c = Sys.getChar(true);
		}
		
		if (enemy.attributesCalculated["Life"] <= 0) {
			
			hero.xp.value += enemy.level;
			if(hero.xp.value > hero.xp.calculatedMax){
				//Hero level up
				hero.xp.value = 0;
				hero.level++;
				AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], hero.level, hero.attributesCalculated);
				ResourceLogic.recalculateScalingResource(hero.level, hero.xp);
			}
            event += "New enemy";
            event += "\n\n\n";
			enemy.attributesCalculated["Life"] = enemy.attributesCalculated["LifeMax"];
			// c = Sys.getChar(true);
		}
		var level = hero.level;
		var herolife = hero.attributesCalculated["Life"];
		var herolifeM = hero.attributesCalculated["LifeMax"];
		var enemylife = enemy.attributesCalculated["Life"];
		var xp = hero.xp.value;
		var xpmax = hero.xp.calculatedMax;
        var output = 
'Player 
	life: $herolife / $herolifeM
	level: $level
	xp: $xp / $xpmax';

        output += "\n";
        output += 'Enemy life: $enemylife';
        output += "\n\n";
		output += event;
		// c = Sys.getChar(true);
		var attacker = hero;
		var defender = enemy;
		if (turn) {
			attacker = enemy;
			defender = hero;
		}
		defender.attributesCalculated["Life"] -= attacker.attributesCalculated["Attack"];
		turn = !turn;
        return output;
	}



	public function update(delta:Float):String {
		this.timeCount += delta;

        if(timeCount >= timePeriod){
            timeCount = 0;
            return advance();
        }
        return null;
	}

	public function DefaultConfiguration() {}

	public function getPlayerTimesKilled():Int {
		return playerTimesKilled;
	}

	public function RetreatArea() {
		if(battleArea > 1)
			ChangeBattleArea(battleArea-1);
	}

	public function AdvanceArea() {
		ChangeBattleArea(battleArea+1);
	}
}

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
			result[key] = attributes[key] + Std.int(attributeAddition[key]*quantityOfAddition);
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
