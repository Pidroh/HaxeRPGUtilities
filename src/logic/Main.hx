import BattleManager;
import haxe.io.Float64Array.Float64ArrayData;
import haxe.ui.components.Label;
import haxe.ui.Toolkit;
import haxe.Log;
import haxe.iterators.DynamicAccessIterator;
import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;
import RPGData;

class Main {
	static var hero:Actor;
	static var enemy:Actor;
	static var maxDelta:Float = 0.5;

	static function main() {
		var bm:BattleManager = new BattleManager();
		Toolkit.init();
		
		
		var main = new VBox();

		var buttonAdvance : Button = new Button();
		
		
		buttonAdvance.text = "Advance area";
		main.addComponent(buttonAdvance);
		var buttonRetreat : Button = new Button();
		buttonRetreat.text = "Retreat Area";
		main.addComponent(buttonRetreat);
		var label:Label = new Label();
		label.text = "";		
		main.addComponent(label);

		buttonRetreat.onClick = function(e) {
			bm.RetreatArea();
		};

		buttonAdvance.onClick = function(e) {
			trace("CLICK ON ADVANCE");
			bm.AdvanceArea();
		};
		
		Screen.instance.addComponent(main);

		var time:Float = 0;

		//trace("\nJavascript!");

		var c = 1;
		var turn = false;

		var update = null;
		update = function(timeStamp:Float):Bool {
			
			var delta = timeStamp - time;
			//trace(delta);

			time = timeStamp;
			buttonAdvance.disabled = !bm.canAdvance;
			buttonRetreat.disabled = !bm.canRetreat;

			delta = delta * 0.001;
			//updates battle manager to account for very high deltas
			//high deltas happen when the tab or browser isn't active
			while(delta > maxDelta){
				delta -= maxDelta;
				bm.update(maxDelta);
			}
			var text:String = bm.update(delta);
			if (text != null) {
				label.text = text;
			}

			js.Browser.window.requestAnimationFrame(update);
			return true;
		}
		update(0);

		while (false) {
			trace("");
			if (hero.attributesBase["Life"] <= 0) {
				trace("You died");
				trace("¥n¥n¥n");
				hero.attributesBase["Life"] = 20;
				enemy.attributesBase["Life"] = 6;
				// c = Sys.getChar(true);
			}
			var herolife = hero.attributesBase["Life"];
			if (enemy.attributesBase["Life"] <= 0) {
				trace("New enemy");
				trace("¥n¥n¥n");
				enemy.attributesBase["Life"] = 6;
				// c = Sys.getChar(true);
			}
			var enemylife = enemy.attributesBase["Life"];
			trace('Player life: $herolife');
			trace('Enemy life: $enemylife');
			trace('Press button to advance');
			// c = Sys.getChar(true);
			var attacker = hero;
			var defender = enemy;
			if (turn) {
				attacker = enemy;
				defender = hero;
			}
			defender.attributesBase["Life"] -= attacker.attributesBase["Attack"];
			turn = !turn;
		}
	}
}

