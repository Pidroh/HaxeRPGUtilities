import haxe.ui.components.Progress;
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
import View;


class Main {
	static var hero:Actor;
	static var enemy:Actor;
	static var maxDelta:Float = 0.5;

	static function main() {
		var bm:BattleManager = new BattleManager();
		var view:View = new View();
		Toolkit.init();
		
		
		var main = new VBox();
		main.addComponent(view.mainComponent);
		

		var buttonAdvance : Button = new Button();
		buttonAdvance.text = "Advance area";
		main.addComponent(buttonAdvance);
		var buttonRetreat : Button = new Button();
		buttonRetreat.text = "Retreat Area";
		main.addComponent(buttonRetreat);
		var buttonLevelUp : Button = new Button();
		buttonLevelUp.text = "Level up";
		main.addComponent(buttonLevelUp);
		var label:Label = new Label();
		label.text = "";		
		main.addComponent(label);
		{
			
			var progress = new Progress();
			progress.pos = 80;
			progress.width = 120;
			progress.height = 25;
			//progress.styleString = "";
			main.addComponent(progress);
			var l = new Label();
			l.text = "sss";
			//progress.addComponent(l);
		}
		{
			var progress = new Progress();
			progress.pos = 30;
			progress.value = 30;
			progress.max = 100;
			progress.min = 0;
			progress.precision =20;
			progress.width = 120;
			progress.height = 20;
			progress.getComponentAt(0).backgroundColor = "#999999";
			progress.getComponentAt(0).value = 30;
			progress.getComponentAt(0).width = 40;
			progress.getComponentAt(0).height = progress.height - 4;
			trace(progress.childComponents.length);
			
			main.addComponent(progress);
			var l = new Label();
			l.text = "32/32";
			l.textAlign = "center";
			l.styleString = "font-size:14px; text-align: center;
			vertical-align: middle; width:100%;";
			l.verticalAlign = "middle";
			progress.addComponent(l);
		}
		

		buttonLevelUp.onClick = function(e){
			bm.LevelUp();
		}
		buttonRetreat.onClick = function(e) {
			bm.RetreatArea();
		};

		buttonAdvance.onClick = function(e) {
			bm.AdvanceArea();
		};
		main.percentWidth = 100;
		//main.horizontalAlign = "center";
		
		Screen.instance.addComponent(main);

		var time:Float = 0;

		var key = "save data2";

		var ls = Browser.getLocalStorage();
		var jsonData = ls.getItem(key);
		if(jsonData != null){
			bm.SendJsonPersistentData(jsonData);
			
		}

		var update = null;
		var ActorToView = function(actor: Actor, actorView:ActorView){
			
			view.UpdateValues(
				actorView.life,
				bm.GetAttribute(actor, "Life"), 
				bm.GetAttribute(actor, "LifeMax"));
		};
		update = function(timeStamp:Float):Bool {
			
			ActorToView(bm.wdata.hero, view.heroView);
			ActorToView(bm.wdata.enemy, view.enemyView);
			view.UpdateValues(view.level, bm.wdata.hero.level, -1);
			view.UpdateValues(view.xpBar, bm.wdata.hero.xp.value, bm.wdata.hero.xp.calculatedMax);
			view.AddButton("Reset", function(e) {
				bm = new BattleManager();
			});

			var delta = timeStamp - time;

			time = timeStamp;
			buttonAdvance.disabled = !bm.canAdvance;
			buttonRetreat.disabled = !bm.canRetreat;
			buttonLevelUp.hidden = !bm.canLevelUp;
			

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

