import haxe.Log;
import haxe.iterators.DynamicAccessIterator;

class Main {

	static var hero:Actor;
	static var enemy:Actor;

    static function main() {
        hero = {level:1, attributesBase:["Attack"=> 5, "Life" => 20], equipmentSlots: null, equipment: null};
		enemy = {level:1, attributesBase:["Attack"=> 2, "Life" => 6], equipmentSlots: null, equipment: null};


		var c = 1;
		var turn = false;
		while(c != 'c'.code){
			trace("");
			if(hero.attributesBase["Life"] <= 0){
					trace("You died");
					trace("¥n¥n¥n");
					hero.attributesBase["Life"]  = 20;
					enemy.attributesBase["Life"]  = 6;
					c = Sys.getChar(true);
				}
			var herolife = hero.attributesBase["Life"];
			if(enemy.attributesBase["Life"] <= 0){
				trace("New enemy");
				trace("¥n¥n¥n");
				enemy.attributesBase["Life"]  = 6;
				c = Sys.getChar(true);
			}
			var enemylife = enemy.attributesBase["Life"];
			trace('Player life: $herolife');
			trace('Enemy life: $enemylife');
			trace('Press button to advance');
			c = Sys.getChar(true);
			var attacker = hero;
			var defender = enemy;
			if(turn)
			{
				attacker = enemy;
				defender = hero;

			}
			defender.attributesBase["Life"] -= attacker.attributesBase["Attack"];
			turn = !turn;

			

		}

    }
  }



typedef Actor = {
	var level:Int;
	var attributesBase:Map<String, Int>;
	var equipment:Array<Equipment>;
	var equipmentSlots:Array<Int>;
}
typedef LevelGrowth = {
    var attributesBase:Map<String, Int>;
}

typedef Equipment = {
	var type:Int;
	var requiredAttributes:Map<String, Int>;
	var attributes:Map<String, Int>;
}



