//package logic;
import RPGData;

class BattleManager {
	var hero: Actor;
	var enemy:Actor;
    var turn:Bool;
    var timeCount:Float;
    var timePeriod:Float = 1;
	var battleArea: Int;
	var playerTimesKilled : Int;
	var dirty:Bool;
	var killedInArea : Array<Int>;
	var necessaryInArea : Int;

	public function ChangeBattleArea(area:Int){
		battleArea = area;
		necessaryInArea = 5+area;
		var enemyLife = 6 + area*3;
		var stats2 = ["Attack"=> 2+area*3, "Life" => enemyLife, "LifeMax" => enemyLife];
		enemy = {level:1+area, attributesBase:stats2, equipmentSlots: null, equipment: null, xp:null, attributesCalculated: stats2};
		dirty = true;
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
			
			killedInArea[battleArea]++;
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
		var output = BaseInformationFormattedString();
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

	function BaseInformationFormattedString():String{
		var level = hero.level;
		var xp = hero.xp.value;
		var xpmax = hero.xp.calculatedMax;
		var baseInfo = CharacterBaseInfoFormattedString(hero);
        var output = 
'\n\nPlayer 
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
		return  
'	 Life: $life / $lifeM
	Attack: $attack';
	}

	public function update(delta:Float):String {
		this.timeCount += delta;

        if(timeCount >= timePeriod){
            timeCount = 0;
            return advance();
        }
		if(dirty){
			dirty = false;
			return BaseInformationFormattedString();
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

