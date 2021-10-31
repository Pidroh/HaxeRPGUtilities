import hscript.Interp;
import StoryModel.StoryRuntimeData;
import js.html.FileReader;
import js.html.InputElement;
import haxe.ui.containers.Box;
import haxe.ui.core.Component;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import haxe.ui.macros.helpers.FunctionBuilder;
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
import ConfirmationView;
import Library;
import GameAnalyticsIntegration;
import FileReader;
import StoryControl;

class Main {
	static var hero:Actor;
	static var enemy:Actor;
	static var maxDelta:Float = 0.5;
	static var privacyView:Component = null;

	static function main() {
		Toolkit.init();
		trace("sss");
		var key = "privacymemory";

		var privacyAcceptance:String = Browser.getLocalStorage().getItem(key);
		if (privacyAcceptance == null) {
			privacyView = PrivacyConfirmationView.CreateView(function() {
				privacyAcceptance = "accepted";
				Browser.getLocalStorage().setItem(key, privacyAcceptance);
				// Browser.getLocalStorage().
				gamemain();
			});
			privacyView.horizontalAlign = "center";
			privacyView.percentWidth = 100;
			Screen.instance.addComponent(privacyView);
		} else {
			gamemain();
		}

		// Screen.instance.messageBox("We collect gameplay data to improve the game. <a href='https://store.steampowered.com/app/1638970/Brave_Ball/'  target='_blank'>Brave Ball</a>.",
		// "By playing this game, you agree with the terms of use and privacy policy.",
		// MessageBoxType.TYPE_INFO, true, function(button) {

		// trace(button);
		// if (button.toString().indexOf("yes") >= 0) {
		//	onClick(null);
		// }
		// trace("call back!");
		// });
	}

	static function gamemain() {
		if (privacyView != null) {
			Screen.instance.removeComponent(privacyView);
		}

		var bm:BattleManager = new BattleManager();
		var enemyLife = 20;
		var view:View = new View();

		var storyRuntime:StoryRuntimeData = {
			currentStoryProgression: null,
			toShow: null,
			currentCutsceneIndex: -1,
			cutscene: null,
			cutsceneStartable: null,
			cutscenes: null,
			visibilityConditionScripts: [],
			persistence: {
				currentStoryId: null,
				progressionData: []
			}
		}
		StoryControlLogic.Init(haxe.Resource.getString("storyjson"), view, storyRuntime);
		var scriptExecuter = new Interp();
		var global = new Map<String, Float>();
		scriptExecuter.variables.set("global", global);


		// goblin
		bm.enemySheets.push({speciesMultiplier: null, speciesLevelStats: null, speciesAdd: null});
		// wolf
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 0.6, "Speed" => 2, "LifeMax" => 0.5]
			},
			speciesAdd: null,
			speciesLevelStats: null
		});
		// Tonberry
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 4, "Speed" => 0.1, "LifeMax" => 1.5]
			},
			speciesAdd: null,
			speciesLevelStats: null
		});
		// Turtle
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.3, "Speed" => 0.15, "LifeMax" => 2.5]
			},
			speciesAdd: ["Defense" => 4],
			speciesLevelStats: {attributesBase: ["Defense" => 1]}
		});
		// Cactuar
		bm.enemySheets.push({
			speciesMultiplier: {
				attributesBase: ["Attack" => 1.2, "Speed" => 1.1, "LifeMax" => 1.7]
			},
			speciesAdd: ["Piercing" => 1],
			speciesLevelStats: {attributesBase: ["Defense" => 1]}
		});

		var eventShown = 0;

		var main = new Box();
		main.percentWidth = 100;
		main.percentHeight = 100;
		main.addComponent(view.mainComponent);
		var key = "save data2";
		var keyBackup = "save backup";

		var CreateButtonFromAction = function(actionId:String, buttonLabel:String) {
			// var action = bm.wdata.playerActions[actionId];
			var action = bm.playerActions[actionId];
			var actionData = bm.wdata.playerActions[actionId];
			view.AddButton(actionId, buttonLabel, function(e) {
				action.actualAction(actionData);
			});
		}

		view.AddButton("advance", "Advance", function(e) {
			bm.AdvanceArea();
		});

		view.AddButton("retreat", "Retreat", function(e) {
			bm.RetreatArea();
		});

		view.AddButton("levelup", "Level Up", function(e) {
			bm.LevelUp();
		});

		view.AddButton("reset", "Reset", function(e) {
			view.logText.text = "";
			view.logText.htmlText = "";
			bm = new BattleManager();

			var localStorage = js.Browser.getLocalStorage();
			localStorage.setItem(key, "");

			Browser.location.reload();

			eventShown = 0;
		}, "You will lose all your progress");

		CreateButtonFromAction("sleep", "Sleep");
		CreateButtonFromAction("repeat", "Restart");

		view.equipmentMainAction = function(pos, action) {
			if (action == 0) {
				bm.ToggleEquipped(pos);
			}
			if (action == 1)
				bm.DiscardEquipment(pos);
			if (action == View.equipmentAction_DiscardBad)
				bm.DiscardWorseEquipment();
		};

		var ls = Browser.getLocalStorage();

		main.percentWidth = 100;
		// main.horizontalAlign = "center";

		Screen.instance.addComponent(main);

		var time:Float = 0;

		var saveCount:Float = 0.3;

		var jsonData = ls.getItem(key);
		if (jsonData != null) {
			bm.SendJsonPersistentData(jsonData);
		}

		var update = null;

		var ActorToView = function(actor:Actor, actorView:ActorView) {
			if (actor != null) {
				view.UpdateValues(actorView.life, bm.GetAttribute(actor, "Life"), bm.GetAttribute(actor, "LifeMax"));
				view.UpdateValues(actorView.attack, bm.GetAttribute(actor, "Attack"), -1);
			}
			view.UpdateVisibility(actorView, actor != null);
		};
		var buttonToAction = function(actionId:String, buttonId:String) {
			var action = bm.wdata.playerActions[actionId];
			view.ButtonVisibility(buttonId, action.visible);
			view.ButtonEnabled(buttonId, action.enabled);
		}

		var saveFileImporterSetup = false;

		update = function(timeStamp:Float):Bool {

			global["maxarea"] = bm.wdata.maxArea;

			GameAnalyticsIntegration.InitializeCheck();
			ActorToView(bm.wdata.hero, view.heroView);
			ActorToView(bm.wdata.enemy, view.enemyView);
			view.UpdateValues(view.level, bm.wdata.hero.level, -1);
			view.UpdateValues(view.xpBar, bm.wdata.hero.xp.value, bm.wdata.hero.xp.calculatedMax);
			view.UpdateValues(view.speedView, bm.wdata.hero.attributesCalculated["Speed"], -1);
			view.UpdateValues(view.defView, bm.wdata.hero.attributesCalculated["Defense"], -1);
			view.UpdateValues(view.mDefView, bm.wdata.hero.attributesCalculated["Magic Defense"], -1);
			view.UpdateValues(view.areaLabel, bm.wdata.battleArea + 1, -1);
			view.UpdateValues(view.enemyToAdvance, bm.wdata.killedInArea[bm.wdata.battleArea], bm.wdata.necessaryToKillInArea);
			StoryControlLogic.Update(timeStamp, storyRuntime, view, scriptExecuter);

			var imp = Browser.document.getElementById("import__");
			if (imp != null && saveFileImporterSetup == false) {
				if (imp != null) {
					var input:InputElement = cast imp;

					input.onchange = (event) -> {
						FileReader.FileUtilities.ReadFile(input.files[0], (json) -> {
							ls.setItem(keyBackup, bm.GetJsonPersistentData());
							ls.setItem(key, json);
							Browser.location.reload();
							bm = null;
							// trace(json);
						});
					};
					saveFileImporterSetup = true;
				}
			}
  
			/*
				var amountEquipmentShow = 0;
				for (i in 0...bm.wdata.hero.equipment.length) {
					if(bm.wdata.hero.equipment[i] != null)
						amountEquipmentShow++;
				}
			 */

			view.EquipmentAmountToShow(bm.wdata.hero.equipment.length);
			var equipmentViewPos = 0;
			for (i in 0...bm.wdata.hero.equipment.length) {
				var e = bm.wdata.hero.equipment[i];
				if (e != null) {
					var equipName = GetEquipName(e);
					view.FeedEquipmentBase(equipmentViewPos, equipName, bm.IsEquipped(i));
					var vid = 0;
					for (v in e.attributes.keyValueIterator()) {
						view.FeedEquipmentValue(equipmentViewPos, vid, v.key, v.value);
						vid++;
					}
				} else {
					view.HideEquipmentView(equipmentViewPos);
				}
				equipmentViewPos++;
			}

			var levelUpSystem = bm.wdata.hero.level > 1;
			view.UpdateVisibilityOfValueView(view.level, levelUpSystem);
			view.UpdateVisibilityOfValueView(view.xpBar, true);

			while (bm.events.length > eventShown) {
				var e = bm.events[eventShown];
				var data = e.data;
				var originText = "XX";
				if (e.origin != null) {
					if (e.origin.type == 1) {
						originText = "Enemy";
					} else {
						originText = "You";
					}
				}
				var targetText = "YY";
				if (e.target != null) {
					if (e.target.type == 0) {
						targetText = "Hero";
					} else {
						targetText = "Enemy";
					}
				}

				var ev = "";
				if (e.type == ActorAttack) {
					ev = '$targetText took $data damage';
				}

				if (e.type == GetXP) {
					ev = '<span style="color:#005555; font-weight: normal;";>You received $data XP</span>';
				}
				if (e.type == ActorDead) {
					ev = '$originText died';
					if (e.target != null) {
						if (e.target.type == 0) // hero died
							GameAnalyticsIntegration.SendProgressFailEvent("world0", "stage0", "area" + bm.wdata.battleArea);
					}
				}
				if (e.type == ActorLevelUp) {
					ev = '<b>You leveled up!</b>';
					GameAnalyticsIntegration.SendProgressCompleteEvent("LevelUp " + bm.wdata.hero.level, "", "");
				}
				if (e.type == AreaUnlock) {
					ev = '<spawn style="color:#005555; font-weight: normal;";>You found a new area!</span>';
					GameAnalyticsIntegration.SendDesignEvent("AreaUnlock", e.data);
					GameAnalyticsIntegration.SendProgressStartEvent("world0", "stage0", "area" + e.data);
				}
				if (e.type == AreaComplete) {
					ev = 'There are no enemies left';
					GameAnalyticsIntegration.SendProgressCompleteEvent("world0", "stage0", "area" + e.data);
					// GameAnalyticsIntegration.SendDesignEvent("AreaUnlock", e.data);
				}
				if (e.type == EquipDrop) {
					var equipName = GetEquipName(bm.wdata.hero.equipment[e.data]);
					ev = '<b>Enemy dropped $equipName</b>';
				}

				view.AddEventText(ev);
				eventShown++;
			}

			var delta = timeStamp - time;

			time = timeStamp;
			buttonToAction("advance", "advance");
			buttonToAction("retreat", "retreat");
			buttonToAction("levelup", "levelup");
			buttonToAction("sleep", "sleep");
			buttonToAction("repeat", "repeat");

			{
				var action = bm.wdata.playerActions["tabequipment"];
				view.TabVisible(view.equipTab, action.visible);
			}
			{
				var action = bm.wdata.playerActions["tabmemr"];
				view.TabVisible(view.equipTab, action.visible);
			}

			var sleepAct = bm.wdata.playerActions["sleep"];
			if (sleepAct.mode == 0) {
				view.ButtonLabel("sleep", "Nap");
			} else {
				view.ButtonLabel("sleep", "Wake up");
			}

			delta = delta * 0.001;
			// updates battle manager to account for very high deltas
			// high deltas happen when the tab or browser isn't active
			while (delta > maxDelta) {
				delta -= maxDelta;
				bm.update(maxDelta);
			}
			var text:String = bm.update(delta);
			var localStorage = js.Browser.getLocalStorage();
			var json = bm.GetJsonPersistentData();

			localStorage.setItem(key, json);
			if (text != null) {
				// label.text = text;
			}

			saveCount -= delta;
			if (saveCount < 0) {
				view.FeedSave(json);
				saveCount = 5;
			}

			js.Browser.window.requestAnimationFrame(update);
			return true;
		}
		update(0);
	}

	static function GetEquipName(e:Equipment):String {
		var equipName = "Sword";
		if (e.type == 1)
			equipName = "Armor";
		return equipName;
	}
}
