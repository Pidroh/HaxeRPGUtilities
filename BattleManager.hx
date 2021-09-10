import js.html.Window;
import Main;

class BattleManager {
	var hero:Actor;
	var enemy:Actor;
    var turn:Bool;
    var timeCount:Float;
    var timePeriod:Float = 1;

    public function new (){
		
		var stats = ["Attack"=> 5, "Life" => 20, "LifeMax" => 20];
        hero = {level:1, attributesBase:stats, equipmentSlots: null, equipment: null, 
			xp:ResourceLogic.getExponentialResource(1.15, 5, 5), attributesCalculated: stats};
		var stats2 = ["Attack"=> 2, "Life" => 6];
		enemy = {level:1, attributesBase:stats2, equipmentSlots: null, equipment: null, xp:null, attributesCalculated: stats2};
        timeCount = 0;
    }

	public function advance() {
        var output : String = "";
		if (hero.attributesCalculated["Life"] <= 0) {
            output += "You died\n\n\n";
			hero.attributesCalculated["Life"] = hero.attributesCalculated["LifeMax"];
			enemy.attributesCalculated["Life"] = 6;
			// c = Sys.getChar(true);
		}
		var herolife = hero.attributesCalculated["Life"];
		if (enemy.attributesCalculated["Life"] <= 0) {
			hero.xp.value += 2;
			if(hero.xp.value > hero.xp.calculatedMax){
				hero.xp.value = 0;
				hero.level++;
				AttributeLogic.Add(hero.attributesBase, ["Attack"=> 1, "LifeMax" => 1, "Life"=>1], hero.level, hero.attributesCalculated);
				ResourceLogic.recalculateScalingResource(hero.level, hero.xp);
			}
            output += "New enemy";
            output += "\n\n\n";
			enemy.attributesCalculated["Life"] = 6;
			// c = Sys.getChar(true);
		}
		var enemylife = enemy.attributesCalculated["Life"];
		var xp = hero.xp.value;
		var xpmax = hero.xp.calculatedMax;
        output += 'Player life: $herolife xp: $xp xpmax:$xpmax';
        output += "\n";
        output += 'Enemy life: $enemylife';
        output += "\n";
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
}
