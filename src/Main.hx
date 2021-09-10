import haxe.io.Float64Array.Float64ArrayData;
import haxe.ui.components.Label;
import haxe.ui.Toolkit;
import haxe.Log;
import haxe.iterators.DynamicAccessIterator;
import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

class Main {
	static var hero:Actor;
	static var enemy:Actor;

	static function main() {
		var bm:BattleManager = new BattleManager();
		Toolkit.init();

		var button:Button = new Button();
		button.text = "Click Me!";

		var label:Label = new Label();
		label.text = "Some label";
		button.onClick = function(e) {
			trace("Success!");
			var adv = bm.advance();
			label.text = adv;
			trace(adv);
		};

		Screen.instance.addComponent(button);

		var main = new VBox();

		var button1 = new Button();
		button1.text = "Button 1";
		button1.onClick = function(e) {
			trace("Success!");
			var adv = bm.advance();
			label.text = adv;
			trace(adv);
		};
		main.addComponent(button1);

		var button2 = new Button();
		button2.text = "Button 2";
		main.addComponent(button2);

		main.addComponent(label);

		Screen.instance.addComponent(main);

		var time:Float = 0;

		trace("\nJavascript!");

		var c = 1;
		var turn = false;

		var update = null;
		update = function(timeStamp:Float):Bool {
			var delta = timeStamp - time;
			time = timeStamp;
			var text:String = bm.update(delta * 0.001);
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

