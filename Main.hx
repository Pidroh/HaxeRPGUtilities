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

class ResourceLogic {
	public static function recalculateScalingResource(base:Int, res:ScalingResource) {
		if (res.lastUsedBaseAttribute != base) {
			var data1 = res.scaling.data1;
			var calculated = Std.int(Math.pow(data1, base) + res.scaling.initial);

			// uses only the minimum increment
			calculated = calculated - calculated % res.scaling.minimumIncrement;
			res.calculatedMax = calculated;
			res.lastUsedBaseAttribute = base;
			trace(res);
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
		trace(res);
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
