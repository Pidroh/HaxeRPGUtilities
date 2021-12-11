import js.html.BatteryManager;
import js.lib.Function;
import js.html.KeyboardEvent;
import js.html.Document;
import SaveAssistant.PersistenceMaster;
import StoryModel.StoryPersistence;
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
import PrototypeItemMaker;
import PrototypeSkillMaker;

class Main {
	static var hero:Actor;
	static var enemy:Actor;
	static var maxDelta:Float = 0.5;
	static var privacyView:Component = null;

	static function main() {
		Toolkit.init();
		trace("sssX");
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
		runTest();

		var bm:BattleManager = new BattleManager();
		{
			var proto = new PrototypeItemMaker();
			proto.MakeItems();
			bm.itemBases = proto.items;
			bm.modBases = proto.mods;
		}
		{
			var proto = new PrototypeSkillMaker();
			proto.init();
			bm.skillBases = proto.skills;
		}

		var view:View = new View();

		var enemyRegionNames = [
			"Lagrima Continent",
			"Wolf Fields",
			"Tonberry's Lair",
			"Altar Cave",
			"Bikanel Island",
			"Tartarus",
			"Witchhunter Base",
			"Highsalem",
			"Witchhunter Guild"

		];
		var enemyNames = ["Enemy", "Wolf", "Tonberry", "Land Turtle", "Cactuar", "Reaper"];

		if (enemyRegionNames.length < bm.regionRequirements.length) {
			trace("PLEASE: Go to Discord and tell the developer to 'Add more region names!', there is a bug! "
				+ enemyRegionNames.length
				+ " "
				+ bm.regionRequirements.length);
		}

		var eventShown = 0;

		var main = new Box();
		main.percentWidth = 100;
		main.percentHeight = 100;
		main.addComponent(view.mainComponent);

		var keyOld = "save data2";
		var key = "save data master";
		// var keyStory = "save data masterStory";
		var keyBackup = "save backup";

		var keyMappings = new Map<String, Void->Void>();
		Browser.document.addEventListener("keydown", e -> {
			var ke = cast(e, KeyboardEvent);
			if (keyMappings.exists(ke.key)) {
				keyMappings[ke.key]();
			}
		});

		var CreateButtonFromAction = function(actionId:String, buttonLabel:String, warning:String = null, key:String = null) {
			// var action = bm.wdata.playerActions[actionId];
			var action = bm.playerActions[actionId];
			var actionData = bm.wdata.playerActions[actionId];
			if (key != null) {
				keyMappings[key] = () -> {
					if (actionData.enabled) {
						action.actualAction(actionData);
						view.AnimateButtonPress(buttonLabel);
					}
				}
			}
			view.AddButton(actionId, buttonLabel, function(e) {
				action.actualAction(actionData);
			}, warning);
		}

		view.AddButton("advance", "Next Area", function(e) {
			bm.AdvanceArea();
		});

		view.AddButton("retreat", "Previous Area", function(e) {
			bm.RetreatArea();
		});

		view.AddButton("levelup", "Level Up", function(e) {
			bm.LevelUp();
		});

		CreateButtonFromAction("sleep", "Sleep");
		CreateButtonFromAction("repeat", "Restart Area");
		for (i in 0...7) {
			CreateButtonFromAction("battleaction_" + i, "Action " + i, null, "" + (1 + i));
		}
		// CreateButtonFromAction("repeat", "Restart");
		var prestigeWarn = "Your experience awards will increase by "
			+ Std.int(bm.GetXPBonusOnPrestige() * 100)
			+ "%. Your max level will increase by "
			+ bm.GetMaxLevelBonusOnPrestige()
			+
			". You will keep all permanent stats bonuses. \n\nYou will go back to Level 1. Your progress in all regions will be reset. All that is not equipped will be lost. All that is equipped will lose strength.";
		CreateButtonFromAction("prestige", "Soul Crush", prestigeWarn);

		view.equipmentMainAction = function(pos, action) {
			if (action == 0) {
				bm.ToggleEquipped(pos);
			}
			if (action == 1)
				bm.SellEquipment(pos);
			if (action == 2) {
				bm.UpgradeOrLimitBreakEquipment(pos);
			}
			if (action == View.equipmentAction_DiscardBad)
				bm.DiscardWorseEquipment();
		};
		view.regionChangeAction = i -> {
			bm.changeRegion(i);
		}

		var ls = Browser.getLocalStorage();

		main.percentWidth = 100;
		// main.horizontalAlign = "center";

		Screen.instance.addComponent(main);

		var time:Float = 0;

		var saveCount:Float = 0.3;

		bm.ForceSkillSetDrop(-1, null, {
			skills: [{id: "Slash", level: 1}, {id: "Cure", level: 1}, {id: "Protect", level: 3}]
		}, false);
		bm.wdata.hero.equipmentSlots[2] = 0;

		var storyPersistence:StoryPersistence = {progressionData: [], worldVersion: bm.wdata.worldVersion, currentStoryId: null};
		var jsonData = ls.getItem(key);

		var persistenceMaster:PersistenceMaster = SaveAssistant.GetPersistenceMaster(jsonData);

		var jsonData2 = persistenceMaster.jsonStory;
		if (jsonData2 != null && jsonData2 != "") {
			storyPersistence = StoryControlLogic.ReadJsonPersistentData(jsonData2);
		} else {
			storyPersistence = {
				currentStoryId: null,
				progressionData: [],
				worldVersion: bm.wdata.worldVersion
			};
		}

		if (persistenceMaster.jsonGameplay != null) {
			bm.SendJsonPersistentData(persistenceMaster.jsonGameplay);
		}

		var storyRuntime:StoryRuntimeData = {
			currentStoryProgression: null,
			currentCutsceneIndex: -1,
			cutscene: null,
			cutsceneStartable: null,
			cutscenes: null,
			visibilityConditionScripts: [],
			messageRuntimeInfo: [],
			persistence: storyPersistence,
			speakerToImage: [
				"mom" => "graphics/mom.png",
				"you" => "graphics/main.png",
				"cid" => "graphics/cid.png",
				"man" => "graphics/cid.png"
			]
		}

		view.AddButton("reset", "Reset", function(e) {
			view.logText.text = "";
			view.logText.htmlText = "";
			bm = new BattleManager();

			var localStorage = js.Browser.getLocalStorage();
			localStorage.setItem(key, "");

			Browser.location.reload();

			eventShown = 0;
			storyRuntime = null;
		}, "You will lose all your progress", -1, true);

		StoryControlLogic.Init(haxe.Resource.getString("storyjson"), view, storyRuntime);
		var scriptExecuter = new Interp();
		var global = new Map<String, Float>();
		scriptExecuter.variables.set("global", global);

		var update = null;

		var buffToIcon:Map<String, String> = [
			"regen" => "&#127807;",
			"enchant-fire" => "&#128293;",
			"protect" => "&#9960;",
			"haste" => "&#128094;"
		];

		var ignoreStats = ["Attack", "Defense", "Speed", "Life", "LifeMax", "MP", "SpeedCount", "MagicAttack", "MPRechargeCount", "MPRecharge"];

		var ActorToFullView = function(actor:Actor, actorView:ActorViewComplete) {
			// var valueView:ValueView = view.GetValueView(actorView, 0);

			view.UpdateValues(view.GetValueView(actorView, 0, true), bm.GetAttribute(actor, "Life"), bm.GetAttribute(actor, "LifeMax"), "Life:");
			view.UpdateValues(view.GetValueView(actorView, 1, false), bm.GetAttribute(actor, "Attack"), -1, "Attack:");
			view.UpdateValues(view.GetValueView(actorView, 2, false), bm.GetAttribute(actor, "Speed"), -1, "Speed:");
			view.UpdateValues(view.GetValueView(actorView, 3, false), bm.GetAttribute(actor, "Defense"), -1, "Defense:");

			// continue from the last one
			var valueIndex = 4;

			for (key => value in actor.attributesCalculated) {
				if(!ignoreStats.contains(key) && value != 0){
					view.UpdateValues(view.GetValueView(actorView, valueIndex, false), value, -1, '$key:');
					valueIndex++;
				}				
			}
			for (i in valueIndex...actorView.valueViews.length) {
					actorView.valueViews[i].parent.hidden = true;
			}

			
			// view.UpdateValues(view.speedView, bm.wdata.hero.attributesCalculated["Speed"], -1);
			// view.UpdateValues(view.attackView, bm.wdata.hero.attributesCalculated["Attack"], -1);

			// view.UpdateValues(view.defView, bm.wdata.hero.attributesCalculated["Defense"], -1);
			// view.UpdateValues(view.mDefView, bm.wdata.hero.attributesCalculated["Magic Defense"], -1);
		}

		var ActorToView = function(actor:Actor, actorView:ActorView) {
			if (actor != null) {
				var name = actorView.defaultName;
				if (name != actorView.name.text) {
					actorView.name.text = name;
				}
				var buffText = "";
				for (b in actor.buffs) {
					if (b != null && b.uniqueId != null) {
						if (buffToIcon.exists(b.uniqueId))
							buffText += " " + buffToIcon[b.uniqueId];
						else {
							if (b.debuff == true)
								buffText += " &#129095;";
							else
								buffText += " &#129093;";
						}
					}
				}
				if (bm.wdata.sleeping) {
					buffText += " zZz";
				}
				if (bm.wdata.recovering) {
					buffText += " &#x2620;";
				}
				actorView.buffText.text = buffText;

				view.UpdateValues(actorView.life, bm.GetAttribute(actor, "Life"), bm.GetAttribute(actor, "LifeMax"));

				var mp = bm.GetAttribute(actor, "MP");
				var mpmax = bm.GetAttribute(actor, "MPMax");
				if (bm.wdata.hero.level > 1) {
					var rc = bm.GetAttribute(actor, "MPRechargeCount");
					if (rc < 10000) {
						mp = rc;
						mpmax = 10000;
						actorView.mp.labelText.text = "Charge";
					} else {
						actorView.mp.labelText.text = "MP";
					}

					view.UpdateValues(actorView.mp, mp, mpmax);
				} else {
					view.UpdateValues(actorView.mp, mp, mpmax, "??", false, "???");
				}

				// view.UpdateValues(actorView.attack, bm.GetAttribute(actor, "Attack"), -1);
				actorView.attack.parent.hidden = true;
			}
			view.UpdateVisibility(actorView, actor != null);
		};
		var buttonToAction = function(actionId:String, buttonId:String) {
			var action = bm.wdata.playerActions[actionId];
			view.ButtonVisibility(buttonId, action.visible);
			view.ButtonEnabled(buttonId, action.enabled);
		}

		var equipmentWindowTypeAlert = [false, false]; // have same amount
		view.FeedEquipmentTypes(["Weapons", "Armor", "Skill Set"]);

		var saveFileImporterSetup = false;

		var originMessage = "Hard Area Cleared!\nYour stats permanently increased!\n\n";
		var bossMessage = originMessage;

		update = function(timeStamp:Float):Bool {
			global["maxarea"] = bm.wdata.maxArea;
			global["herolevel"] = bm.wdata.hero.level;

			GameAnalyticsIntegration.InitializeCheck();
			ActorToView(bm.wdata.hero, view.heroView);
			ActorToView(bm.wdata.enemy, view.enemyView);
			ActorToFullView(bm.wdata.hero, view.equipHeroStats);
			var actor = bm.wdata.hero;
			view.UpdateValues(view.level, bm.wdata.hero.level, -1);
			view.UpdateValues(view.xpBar, bm.wdata.hero.xp.value, bm.wdata.hero.xp.calculatedMax);

			view.UpdateValues(view.currencyViews[0], bm.wdata.currency.currencies["Lagrima"].value, -1);
			view.UpdateValues(view.currencyViews[1], bm.wdata.currency.currencies["Lagrima Stone"].value, -1);

			// view.UpdateValues(view.lifeView, bm.wdata.hero.attributesCalculated["LifeMax"], -1);

			view.UpdateValues(view.areaLabel, bm.wdata.battleArea + 1, -1);
			view.UpdateValues(view.enemyToAdvance, bm.wdata.killedInArea[bm.wdata.battleArea], bm.wdata.necessaryToKillInArea);
			StoryControlLogic.Update(timeStamp, storyRuntime, view, scriptExecuter);

			var showLocked = 0;
			if (bm.wdata.battleAreaRegionMax < enemyRegionNames.length) {
				showLocked = 1;
			}
			view.FeedDropDownRegion(enemyRegionNames, bm.wdata.battleAreaRegionMax, bm.wdata.battleAreaRegion, showLocked, "Unreached");

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
			var typeToShow = view.GetEquipmentType();
			view.buttonDiscardBad.hidden = typeToShow == 2;
			view.EquipmentAmountToShow(bm.wdata.hero.equipment.length);
			var equipmentViewPos = 0;
			var anyNewEquip = false;

			for (i in 0...equipmentWindowTypeAlert.length) {
				equipmentWindowTypeAlert[i] = false;
			}
			for (i in 0...bm.wdata.hero.equipment.length) {
				var e = bm.wdata.hero.equipment[i];
				var hide = true;
				if (e != null) {
					if (e.type == typeToShow) {
						if (e.seen >= 0 == false) {
							e.seen = 2;
						}
						if (e.seen == 0) { // seen == 0 is unseen
							if (view.IsTabSelected(view.equipTab.component)) {
								e.seen = 1; // this is fresh, first time seeing it
							}
						}

						var equipName = GetEquipName(e, bm);
						hide = false;
						var rarity = 0;
						if (e.generationPrefixMod >= 0 || e.generationSuffixMod >= 0)
							rarity = 1;
						var upgradeLabel = "Upgrade";
						var upgradeCurrency = "Lagrima";
						var canUpgrade = false;
						var upgradeCost = 0;
						var upgradable = BattleManager.IsUpgradable(e, bm.wdata);

						if (upgradable) {
							canUpgrade = BattleManager.CanUpgrade(e, bm.wdata);
							upgradeCost = BattleManager.GetCost(e, bm.wdata);
						} else {
							var limitable = BattleManager.IsLimitBreakable(e, bm.wdata);
							if (limitable) {
								upgradable = limitable;
								canUpgrade = BattleManager.CanLimitBreak(e, bm.wdata);
								upgradeCost = BattleManager.GetLimitBreakCost(e, bm.wdata);
								upgradeLabel = "Limit Break";
								upgradeCurrency = "Lagrima Stone";
							}
						}
						view.FeedEquipmentBase(equipmentViewPos, equipName, bm.IsEquipped(i), rarity, -1, e.type == 2, e.seen == 1, upgradable, canUpgrade,
							upgradeCost, BattleManager.GetSellPrize(e, bm.wdata), upgradeLabel, upgradeCurrency);
						var vid = 0;
						if (e.outsideSystems != null) {
							if (e.outsideSystems.exists("skillset")) {
								var ss = e.outsideSystems["skillset"];
								var ssd = bm.wdata.skillSets[ss];
								for (s in 0...ssd.skills.length) {
									var actionId = "battleaction_" + s;
									var action = bm.wdata.playerActions[actionId];
									if (action.mode == 0) {
										var skillName = ssd.skills[s].id;
										if (ssd.skills[s].level > 1) {
											skillName += " " + String.fromCharCode('P'.code + ssd.skills[s].level);
										}
										view.FeedEquipmentValue(equipmentViewPos, vid, "Skill", -1, false, skillName);
									}
									if (action.mode == 1) {
										view.FeedEquipmentValue(equipmentViewPos, vid, "Skill", -1, false, "???");
										// view.ButtonLabel(actionId, "Unlock at Level " + bm.skillSlotUnlocklevel[i]);
									}

									vid++;
								}
								view.FeedEquipmentSeparation(equipmentViewPos, vid - 1);
							}
						}

						for (v in e.attributes.keyValueIterator()) {
							view.FeedEquipmentValue(equipmentViewPos, vid, v.key, v.value, false, null);
							vid++;
						}
						if (e.attributeMultiplier != null)
							for (v in e.attributeMultiplier.keyValueIterator()) {
								view.FeedEquipmentValue(equipmentViewPos, vid, v.key, v.value, true);
								vid++;
							}

						view.FinishFeedingEquipmentValue(equipmentViewPos, vid);
					} else {
						if (e.seen == 1) { // player saw it and it became fresh but cannot see it anymore
							e.seen = 2; // seen
						}
					}
					if (e.seen == 0) {
						equipmentWindowTypeAlert[e.type] = true;
						anyNewEquip = true;
					}
				}
				if (hide) {
					view.HideEquipmentView(equipmentViewPos);
				}
				equipmentViewPos++;
			}
			View.TabBarAlert(view.equipmentTypeSelectionTabbar, equipmentWindowTypeAlert, view.equipmentTypeNames);
			view.SetTabNotification(anyNewEquip, view.equipTab);

			var levelUpSystem = bm.wdata.hero.level > 1;
			view.UpdateVisibilityOfValueView(view.level, levelUpSystem);
			view.UpdateVisibilityOfValueView(view.xpBar, bm.wdata.hero.level < bm.CalculateHeroMaxLevel());

			while (bm.events.length > eventShown) {
				var e = bm.events[eventShown];
				var data = e.data;
				var dataString = e.dataString;
				var battle = true;
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
							GameAnalyticsIntegration.SendProgressFailEvent("world0", "stage" + bm.wdata.battleAreaRegion, "area" + bm.wdata.battleArea);
					}
				}
				if (e.type == BuffRemoval) {
					ev = '$originText lost  all positive status!';
				}
				if (e.type == DebuffBlock) {
					ev = '$originText blocked the negative status!';
				}
				if (e.type == MPRunOut) {
					ev = '$originText ran out of MP';
				}
				if (e.type == SkillUse) {
					ev = '$originText used $dataString';
				}
				if (e.type == ActorLevelUp) {
					battle = false;
					ev = '<b>You leveled up!</b>';
					GameAnalyticsIntegration.SendProgressCompleteEvent("LevelUp " + bm.wdata.hero.level, "", "");
				}
				if (e.type == PermanentStatUpgrade) {
					battle = false;
					ev = '<b>Your stats permanently increased!</b>';
					GameAnalyticsIntegration.SendProgressCompleteEvent("Permanentupg", "", "");
					// bossMessage += ev;
					view.ShowMessage("Area Clear", bossMessage);
					bossMessage = originMessage;
				}
				if (e.type == EquipMaxed) {
					view.ShowMessage("Equipment reached Limit Level", 'Your equipment reached Limit Level. The energy materializes into $dataString x$data');
				}
				if (e.type == statUpgrade) {
					battle = false;
					var dataS = e.dataString;
					var data = e.data;
					ev = '<b>$dataS +$data</b>';
					bossMessage += '$dataS +$data' + "\n";
				}
				if (e.type == AreaUnlock) {
					battle = false;
					ev = '<spawn style="color:#005555; font-weight: normal;";>You found a new area!</span>';
					GameAnalyticsIntegration.SendDesignEvent("AreaUnlock", e.data);
					GameAnalyticsIntegration.SendProgressStartEvent("world0", "stage" + bm.wdata.battleAreaRegion, "area" + e.data);
				}
				if (e.type == RegionUnlock) {
					battle = false;
					var regionName = enemyRegionNames[e.data];
					ev = '<b>Found new location: $regionName</b>';
					GameAnalyticsIntegration.SendDesignEvent("RegionUnlock", e.data);
					GameAnalyticsIntegration.SendProgressStartEvent("world0", "stage" + e.data);
				}
				if (e.type == AreaComplete) {
					ev = 'There are no enemies left';
					GameAnalyticsIntegration.SendProgressCompleteEvent("world0", "stage0", "area" + e.data);
					// GameAnalyticsIntegration.SendDesignEvent("AreaUnlock", e.data);
				}
				if (e.type == EquipDrop) {
					var equipName = GetEquipName(bm.wdata.hero.equipment[e.data], bm);
					ev = '<b>Enemy dropped $equipName</b>';
				}

				if (battle)
					view.AddEventTextWithLabel(ev, view.logTextBattle);
				else
					view.AddEventText(ev);
				eventShown++;
			}
			// view.UpdateDropDownRegionSelection(bm.wdata.battleAreaRegion);

			var delta = timeStamp - time;

			var storyHappened = storyRuntime.persistence.progressionData[storyRuntime.cutscenes[0].title].timesCompleted > 0;
			var storyHappenedPure = storyHappened;
			if (bm.wdata.regionProgress != null && bm.wdata.regionProgress[0] != null)
				storyHappened = storyHappened || bm.wdata.regionProgress[0].maxArea > 1;

			view.battleView.parentComponent.hidden = !storyHappened;
			view.levelContainer.hidden = !storyHappened;
			view.battleView.hidden = !storyHappened;
			view.areaContainer.hidden = !storyHappened;

			time = timeStamp;
			buttonToAction("advance", "advance");
			view.ButtonVisibility("advance", storyHappened);
			buttonToAction("retreat", "retreat");
			buttonToAction("levelup", "levelup");
			buttonToAction("sleep", "sleep");
			buttonToAction("repeat", "repeat");
			buttonToAction("prestige", "prestige");
			view.ButtonVisibility("prestige", storyRuntime.persistence.progressionData[storyRuntime.cutscenes[2].title].timesCompleted > 0);

			for (i in 0...7) {
				var id = "battleaction_" + i;
				buttonToAction(id, id);
				var skills = bm.wdata.hero.usableSkills;
				if (skills[i] != null) {
					var action = bm.wdata.playerActions[id];
					if (action.mode == 0 || action.mode == 2) {
						var sb = bm.GetSkillBase(skills[i].id);
						var skillName = sb.id;
						if (skills[i].level > 1) {
							skillName += " " + String.fromCharCode('P'.code + skills[i].level);
						}
						view.ButtonLabel(id, skillName + " - " + sb.mpCost + "MP");
					}
					// if (action.enabled) {
					if (action.mode == 2 && action.enabled == false) {
						view.ButtonAttackColor(id);
					} else {
						if (action.enabled) {
							view.ButtonNormalColor(id);
						}
					}
					// }
					if (action.mode == 1) {
						view.ButtonLabel(id, "Unlock at Level " + bm.skillSlotUnlocklevel[i]);
					}
				}
			}

			{
				var action = bm.wdata.playerActions["tabequipment"];
				view.TabVisible(view.equipTab, action.visible);
			}
			{
				var action = bm.wdata.playerActions["tabmemory"];
				// view.TabVisible(view.storyTab, action.visible);
				view.TabVisible(view.storyTab, storyHappenedPure);
			}
			{
				view.TabVisible(view.developTab, bm.wdata.prestigeTimes >= 1 || bm.wdata.hero.level > 10);
			}

			var sleepAct = bm.wdata.playerActions["sleep"];
			if (sleepAct.mode == 0) {
				view.ButtonLabel("sleep", "Nap");
			} else {
				view.ButtonLabel("sleep", "Wake up");
			}
			var pact = bm.wdata.playerActions["prestige"];
			if (pact.enabled == true) {
				view.ButtonLabel("prestige", "Soul Crush");
			} else {
				view.ButtonLabel("prestige", "Unlock at Level " + bm.GetLevelRequirementForPrestige());
			}
			view.Update();

			delta = delta * 0.001;
			// updates battle manager to account for very high deltas
			// high deltas happen when the tab or browser isn't active
			while (delta > maxDelta) {
				delta -= maxDelta;
				bm.update(maxDelta);
			}
			var text:String = bm.update(delta);
			var localStorage = js.Browser.getLocalStorage();

			// #SAVE
			var json = bm.GetJsonPersistentData();
			// localStorage.setItem(key, json);
			var json2 = StoryControlLogic.GetJsonPersistentData(storyRuntime);
			var masterPers:PersistenceMaster = {worldVersion: bm.wdata.worldVersion, jsonGameplay: json, jsonStory: json2};
			// localStorage.setItem(keyStory, json2);
			var jsonMaster = Json.stringify(masterPers);
			localStorage.setItem(key, jsonMaster);

			saveCount -= delta;
			if (saveCount < 0) {
				view.FeedSave(jsonMaster);
				saveCount = 5;
			}

			js.Browser.window.requestAnimationFrame(update);
			return true;
		}
		update(0);
	}

	static function runTest() {
		trace("Discard worse equip tests");
		var bm:BattleManager = new BattleManager();
		bm.DefaultConfiguration();

		bm.wdata.hero.equipment.push({
			seen: 0,
			type: 0,
			requiredAttributes: null,
			attributes: ["Attack" => 2]
		});

		var oldEquipN = bm.wdata.hero.equipment.length;
		bm.DiscardWorseEquipment();
		var equipN = bm.wdata.hero.equipment.length;

		var numberOfNullEquipment = oldEquipN - equipN;
		if (numberOfNullEquipment != 0) {
			trace('ERROR: discard worse equipment problem: $numberOfNullEquipment VS 0 (aa)');
		}

		bm.wdata.hero.equipment.push({
			seen: 0,
			type: 0,
			requiredAttributes: null,
			attributes: ["Attack" => 2]
		});
		bm.wdata.hero.equipment.push({
			seen: 0,
			type: 0,
			requiredAttributes: null,
			attributes: ["Attack" => 1]
		});
		bm.wdata.hero.equipment.push({
			seen: 0,
			type: 0,
			requiredAttributes: null,
			attributes: ["Life" => 3]
		});

		oldEquipN = bm.wdata.hero.equipment.length;
		bm.DiscardWorseEquipment();
		equipN = bm.wdata.hero.equipment.length;

		numberOfNullEquipment = oldEquipN - equipN;
		if (numberOfNullEquipment != 2) {
			trace('ERROR: discard worse equipment problem: $numberOfNullEquipment VS 2 (a)');
			trace('$oldEquipN $equipN');
		}
	}

	static function GetEquipName(e:Equipment, bm:BattleManager):String {
		var itemBases:Array<ItemBase> = bm.itemBases;
		var modBases:Array<ModBase> = bm.modBases;
		var skillSets:Array<SkillSet> = bm.wdata.skillSets;
		if (e.generationBaseItem >= 0) {
			var name = itemBases[e.generationBaseItem].name;
			if (e.generationPrefixMod >= 0) {
				name = modBases[e.generationPrefixMod].prefix + " " + name;
			}
			if (e.generationSuffixMod >= 0) {
				name = name + " " + modBases[e.generationSuffixMod].suffix;
			}
			var level = bm.wdata.equipLevels[e.outsideSystems["level"]].level;

			var levelP = Std.int((level - 1) / 3);
			var levelS = ((level - 1) % 3) + 1;

			name += " ";
			// 0 - 0
			var character = '+';
			/*
				if(levelP == 1){
					character = 'X';
				}
				if(levelP == 2){
					character = 'Y';
				}
				if(levelP == 3){
					character = 'Z';
				}
			 */
			for (i in 0...level) {
				name += character;
			}
			return name;
		}
		if (e.outsideSystems != null) {
			if (e.outsideSystems.exists("skillset")) {
				var skillSet = e.outsideSystems["skillset"];
				var ss = skillSets[skillSet];
				var main = ss.skills[0];
				var sbMain = bm.GetSkillBase(main.id);

				var profession = "Corrupter";
				if (sbMain != null)
					profession = bm.GetSkillBase(main.id).profession;
				var word1 = null;
				var word2 = null;
				if (ss.skills.length > 1) {
					var skillBase1 = bm.GetSkillBase(ss.skills[1].id);
					word1 = bm.GetSkillBase(ss.skills[0].id).word;
					if (skillBase1 != null)
						profession = bm.GetSkillBase(ss.skills[1].id).profession;
				}

				if (ss.skills.length > 2)
					word2 = bm.GetSkillBase(ss.skills[2].id).word;
				if (word2 != null)
					return '$word1 $profession of $word2';
				if (word1 != null)
					return '$word1 $profession';
				return profession;
			}
		}
		var equipName = "Sword";
		if (e.type == 1)
			equipName = "Armor";
		return equipName;
	}
}
