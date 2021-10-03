import haxe.Json;
import js.Browser;
import js.html.Storage;
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

		var key = "save data2";

		var ls = Browser.getLocalStorage();
		var jsonData = ls.getItem(key);
		if(jsonData != null){
			bm.SendJsonPersistentData(jsonData);
			
		}

		var update = null;
		update = function(timeStamp:Float):Bool {
			
			var delta = timeStamp - time;

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
			var localStorage = js.Browser.getLocalStorage();
			var json = bm.GetJsonPersistentData();
			//var json = Json.stringify(bm);
			localStorage.setItem(key, json);
			if (text != null) {
				label.text = text;
			}

			js.Browser.window.requestAnimationFrame(update);
			return true;
		}
		update(0);

	}
}

