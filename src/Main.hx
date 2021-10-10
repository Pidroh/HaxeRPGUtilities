import js.html.webgl.extension.WEBGLCompressedTexturePvrtc;
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



		view.AddButton("retreat","Retreat", function(e) {
			bm.RetreatArea();
		});

		view.AddButton("advance","Advance", function(e) {
			bm.AdvanceArea();
		});

		

		view.AddButton("levelup","Level Up", function(e) {
			bm.LevelUp();
		});

		view.AddButton("reset","Reset", function(e) {
			bm = new BattleManager();
		}, "You will lose all your progress");


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
		var eventShown = 0;
		var ActorToView = function(actor: Actor, actorView:ActorView){
			if(actor != null){
				view.UpdateValues(
					actorView.life,
					bm.GetAttribute(actor, "Life"), 
					bm.GetAttribute(actor, "LifeMax"));
				view.UpdateValues(
						actorView.attack,
						bm.GetAttribute(actor, "Attack"), 
						-1);
			}
			view.UpdateVisibility(actorView, actor != null);
			
		};
		var buttonToAction = function(actionId:String, buttonId:String){
			var action = bm.wdata.playerActions[actionId];
			view.ButtonVisibility(buttonId, action.visible);
			view.ButtonEnabled(buttonId, action.enabled);
		}
		update = function(timeStamp:Float):Bool {
			
			ActorToView(bm.wdata.hero, view.heroView);
			ActorToView(bm.wdata.enemy, view.enemyView);
			view.UpdateValues(view.level, bm.wdata.hero.level, -1);
			view.UpdateValues(view.xpBar, bm.wdata.hero.xp.value, bm.wdata.hero.xp.calculatedMax);
			view.UpdateValues(view.areaLabel, bm.wdata.battleArea+1, -1);
			view.UpdateValues(view.enemyToAdvance, bm.wdata.killedInArea[bm.wdata.battleArea], bm.wdata.necessaryToKillInArea );

			var levelUpSystem = bm.wdata.hero.level > 1;
			view.UpdateVisibilityOfValueView(view.level, levelUpSystem);
			view.UpdateVisibilityOfValueView(view.xpBar, levelUpSystem);


			while(bm.events.length > eventShown)
			{
				var e = bm.events[eventShown];
				var data = e.data;
				var originText = "XX";
				if(e.origin != null){
					if(e.origin.type == 1){
						originText = "Enemy";
					} else{
						originText = "You";
					}
				}
				var targetText = "YY";
				if(e.target != null){
					if(e.target.type == 0){
						targetText = "Hero";
					} else{
						targetText = "Enemy";
					}
				}

				var ev = "";
				if(e.type == ActorAttack){
					ev = '$targetText took $data damage';
				}

				if(e.type == GetXP){
					ev = '<span style="color:#005555; font-weight: normal;";>You received $data XP</span>';
				}
				if(e.type == ActorDead){
					ev = '$originText died';
				}
				if(e.type == ActorLevelUp){
					ev = '<b>You leveled up!</b>';
				}
				if(e.type == AreaUnlock){
					ev = '<spawn style="color:#005555; font-weight: normal;";>You found a new area!</span>>';
				}


				view.AddEventText(ev);
				eventShown++;
			}

			var delta = timeStamp - time;

			time = timeStamp;
			buttonToAction("advance", "advance");
			buttonToAction("retreat", "retreat");
			buttonToAction("levelup", "levelup");
			
			
			

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
				//label.text = text;
			}

			js.Browser.window.requestAnimationFrame(update);
			return true;
		}
		update(0);

	}
}

