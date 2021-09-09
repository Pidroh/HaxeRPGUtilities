import js.html.Window;
import Main;

class BattleManager {
	var hero:Actor;
	var enemy:Actor;
    var turn:Bool;
    var timeCount:Float;
    var timePeriod:Float = 1;

    public function new (){
        hero = {level:1, attributesBase:["Attack"=> 5, "Life" => 20], equipmentSlots: null, equipment: null};
		enemy = {level:1, attributesBase:["Attack"=> 2, "Life" => 6], equipmentSlots: null, equipment: null};
        timeCount = 0;
    }

	public function advance() {
        var output : String = "";
		if (hero.attributesBase["Life"] <= 0) {
            output += "You died\n\n\n";
			hero.attributesBase["Life"] = 20;
			enemy.attributesBase["Life"] = 6;
			// c = Sys.getChar(true);
		}
		var herolife = hero.attributesBase["Life"];
		if (enemy.attributesBase["Life"] <= 0) {
            output += "New enemy";
            output += "\n\n\n";
			enemy.attributesBase["Life"] = 6;
			// c = Sys.getChar(true);
		}
		var enemylife = enemy.attributesBase["Life"];
        output += 'Player life: $herolife';
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
		defender.attributesBase["Life"] -= attacker.attributesBase["Attack"];
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
