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
import BasicProcedural;
import AnimationHaxeUI;
import AnimationP;

class Main {
	static var hero:Actor;
	static var enemy:Actor;
	static var maxDelta:Float = 0.5;
	static var privacyView:Component = null;
	static var animations = new AnimationComponent();

	static var keyOld = "save data2";
	static var key = "save data master";
	static var keyBackup = "save backup";

	static var bm:BattleManager;
	static var titleLoad = false;

	static function main() {
		Toolkit.init();
		Toolkit.theme = "default";
		Toolkit.theme = "dark";
		var b:Button;
		// trace(Toolkit.styleSheet.addStyleSheet);
		// trace("sssX");
		var key = "privacymemory";

		var privacyAcceptance:String = Browser.getLocalStorage().getItem(key);
		if (privacyAcceptance == null) {
			privacyView = PrivacyConfirmationView.CreateView(function() {
				privacyAcceptance = "accepted";
				Browser.getLocalStorage().setItem(key, privacyAcceptance);
				// Browser.getLocalStorage().
				titleload();
			});
			privacyView.horizontalAlign = "center";
			privacyView.percentWidth = 100;
			Screen.instance.addComponent(privacyView);
		} else {
			titleload();
		}
	}

	static function titleload() {
		if (privacyView != null) {
			Screen.instance.removeComponent(privacyView);
		}
		runTest();
		var view:View = new View();
		var main = new Box();
		main.percentWidth = 100;
		main.percentHeight = 100;
		main.addComponent(view.mainComponent);

		Screen.instance.addComponent(main);
		Screen.instance.addComponent(view.overlay);

		var ls = Browser.getLocalStorage();
		var jsonData = ls.getItem(key);
		if (jsonData != null) {
			view.FeedSave(jsonData);
			view.title_NewGameButton.text = "Continue";
		} else {
			view.hideSaveDataDownload();
		}

		view.titleAction = i -> {
			if (i == View.Title_ActionGame) {
				gamemain(view);
			}
		}
		var flagSave = false;
		var update = null;
		titleLoad = false;
		update = (f) -> {
			flagSave = updateImportExport(flagSave, view);
			if (titleLoad == false)
				js.Browser.window.requestAnimationFrame(update);
		}
		update(0);
	}

	static function updateImportExport(saveFileImporterSetup, view) {
		var imp = Browser.document.getElementById("import__");
		if (imp != null && saveFileImporterSetup == false) {
			if (imp != null) {
				var input:InputElement = cast imp;

				input.onchange = (event) -> {
					FileReader.FileUtilities.ReadFile(input.files[0], (json) -> {
						var ls = Browser.getLocalStorage();
						if (bm != null)
							ls.setItem(keyBackup, bm.GetJsonPersistentData());
						else
							ls.setItem(keyBackup, ls.getItem(key));
						ls.setItem(key, json);
						if (titleLoad) {
							Browser.location.reload();
							bm = null;
						} else{
							gamemain(view);
						}
						
						// trace(json);
					});
				};
				saveFileImporterSetup = true;
			}
		}
		return saveFileImporterSetup;
	}

	static function gamemain(view:View) {
		view.title_NewGameButton.hidden = true;
		titleLoad = true;

		// view.
		view.tabMasterSetup();
		{
			var a = "attack-left";
			animations.animManager.feedAnimationInfo(a, 0, {
				centiseconds: 0,
				position: {
					x: 0,
					y: 0
				}
			});
			animations.animManager.feedAnimationInfo(a, 1, {
				centiseconds: 6,
				position: {
					x: 10,
					y: 0
				}
			});
			animations.animManager.feedAnimationInfo(a, 2, {
				centiseconds: 20,
				position: {
					x: 0,
					y: 0
				}
			});
		}
		{
			var a = "attack-right";
			animations.animManager.feedAnimationInfo(a, 0, {
				centiseconds: 0,
				position: {
					x: 0,
					y: 0
				}
			});
			animations.animManager.feedAnimationInfo(a, 1, {
				centiseconds: 6,
				position: {
					x: -10,
					y: 0
				}
			});
			animations.animManager.feedAnimationInfo(a, 2, {
				centiseconds: 20,
				position: {
					x: 0,
					y: 0
				}
			});
		}

		// var
		bm = new BattleManager();
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

		var buffToIcon:Map<String, String> = [
			"regen" => "&#127807;",
			"enchant-fire" => "&#128293;",
			"protect" => "&#9960;",
			"haste" => "&#128094;"
		];

		var buffToExplanation:Map<String, String> = [
			"regen" => "Slowly recovers HP",
			"enchant-fire" => "Adds fire element and makes attacks magical",
			"protect" => "Increases defense",
			"haste" => "Increases speed",
			"nap" => "Resting to recover HP",
			"pierce" => "Increases armor piercing power",
			"noblesse" => "Increases damage as long as not hit",
		];
		var SkillToExplanation:Map<String, String> = [
			"Fogo" => "Deals fire damage", "Gelo" => "Deals ice damage", "Raio" => "Deals thunder damage", "DeSpell" => "Removes enemy buffs",
			"Cure" => "Heals wounds", "Haste" => "Increases speed", "Bloodlust" => "Increases the power of Blood",
			"Noblesse" => "Increases damage as long as not hit", "Sharpen" => "Increases armor piercing power", "Armor Break" => "Decreases enemy defense",
			"Attack Break" => "Decreases enemy attack", "Protect" => "Increases defense", "Regen" => "Slowly recovers HP",
			"Light Slash" => "Deals light damage", "Slash" => "Deals damage", "Heavy Slash" => "deals heavy damage",
		];

		var AttributeExplanation:Map<String, String> = [
			"Attack" => "Influences inflicted damage",
			"Defense" => "Decreases incoming damage",
			"Speed" => "Frequency of attacks",
			"Blood" => "Increases damage, but loses life with each attack",
			"Piercing" => "Armor piercing power",
			"Life" => "When it gets to 0, you need to recover",
			"LifeMax" => "When it gets to 0, you need to recover",
			"MPMax" => "Skills consume this. Expend it all to start recovering.",

		];

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

		var keyMappings = new Map<String, Void->Void>();
		Browser.document.addEventListener("keydown", e -> {
			var ke = cast(e, KeyboardEvent);
			if (keyMappings.exists(ke.key)) {
				keyMappings[ke.key]();
			}
		});

		var CreateButtonFromAction = function(actionId:String, buttonLabel:String, warning:String = null, key:String = null, parent:Component = null) {
			// var action = bm.wdata.playerActions[actionId];
			var action = bm.playerActions[actionId];
			var actionData = bm.wdata.playerActions[actionId];
			if (key != null) {
				keyMappings[key] = () -> {
					action = bm.playerActions[actionId];
					actionData = bm.wdata.playerActions[actionId];
					if (actionData.enabled) {
						action.actualAction(actionData);
						view.AnimateButtonPress(buttonLabel);
					}
				}
			}
			view.AddButton(actionId, buttonLabel, function(e) {
				action.actualAction(actionData);
			}, warning, -1, parent);
		}

		view.AddButton("advance", "Next Area", function(e) {
			bm.AdvanceArea();
		});

		view.AddButton("retreat", "Previous Area", function(e) {
			bm.RetreatArea();
		});

		view.AddButton("levelup", "Level Up", function(e) {
			bm.LevelUp();
		}, null, -1, view.charaTab_ButtonParent);

		CreateButtonFromAction("sleep", "Sleep");
		CreateButtonFromAction("repeat", "Restart Area");
		for (i in 0...7) {
			var skillSlotId = i;
			var bid = "battleaction_" + i;
			CreateButtonFromAction(bid, "Action " + i, null, "" + (1 + i));
			var b = view.GetButton(bid);
			view.addDefaultHover(b);
			/*
				view.addHover(b, (b, component) -> {
					view.overlay.hidden = !b;
					bm.view.overlayText.text = SkillToExplanation
				});
			 */
		}
		// CreateButtonFromAction("repeat", "Restart");
		var prestigeWarn = "Your experience awards will increase by "
			+ Std.int(bm.GetXPBonusOnPrestige() * 100)
			+ "%. Your max level will increase by "
			+ bm.GetMaxLevelBonusOnPrestige()
			+
			". You will keep all permanent stats bonuses. \n\nYou will go back to Level 1. Your progress in all regions will be reset. All that is not equipped will be lost. All that is equipped will lose strength.";
		CreateButtonFromAction("prestige", "Soul Crush", prestigeWarn, null, view.charaTab_ButtonParent);
		var ignoreStats = [
			"Attack", "Defense", "Speed", "Life", "LifeMax", "MP", "SpeedCount", "MagicAttack", "MPRechargeCount", "MPRecharge"
		];

		var ActorToFullView = function(actor:Actor, actorView:ActorViewComplete) {
			// var valueView:ValueView = view.GetValueView(actorView, 0);

			view.UpdateValues(view.GetValueView(actorView, 0, true), bm.GetAttribute(actor, "Life"), bm.GetAttribute(actor, "LifeMax"), "Life:", false, null,
				AttributeExplanation["Life"]);
			view.UpdateValues(view.GetValueView(actorView, 1, false), bm.GetAttribute(actor, "Attack"), -1, "Attack:", false, null,
				AttributeExplanation["Attack"]);
			view.UpdateValues(view.GetValueView(actorView, 2, false), bm.GetAttribute(actor, "Speed"), -1, "Speed:", false, null,
				AttributeExplanation["Speed"]);
			// continue from the last one
			var valueIndex = 3;
			if (bm.GetAttribute(actor, "Defense") > 0) {
				view.UpdateValues(view.GetValueView(actorView, valueIndex, false), bm.GetAttribute(actor, "Defense"), -1, "Defense:", false, null,
					AttributeExplanation["Defense"]);
				valueIndex++;
			}

			for (key => value in actor.attributesCalculated) {
				if (!ignoreStats.contains(key) && value != 0) {
					view.UpdateValues(view.GetValueView(actorView, valueIndex, false), value, -1, '$key:', false, null, AttributeExplanation[key]);
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
			if (action == View.equipmentAction_ChangeSet) {
				bm.ChangeEquipmentSet(pos);
			}
			if (action == View.equipmentAction_SetPreview) {
				view.overlayActorFullView.parent.hidden = pos < 0;
				view.overlayText.hidden = pos < 0;

				if (pos >= 0) {
					var ces = bm.wdata.hero.chosenEquipSet;
					bm.wdata.hero.chosenEquipSet = pos;

					var header = "EQUIPMENT SET " + (pos + 1);

					var actor = bm.wdata.hero;
					if (actor.equipmentSets != null) {
						if (actor.equipmentSets[actor.chosenEquipSet].equipmentSlots != null) {
							for (es in actor.equipmentSets[actor.chosenEquipSet].equipmentSlots) {
								var e = actor.equipment[es];
								if (e != null) {
									var label = GetEquipName(e, bm);
									header += '\n$label';
								}
							}
						}
					}
					view.overlayText.text = header;

					bm.RecalculateAttributes(bm.wdata.hero);
					ActorToFullView(bm.wdata.hero, view.overlayActorFullView);
					view.overlayActorFullView.parent.updateComponentDisplay();
					bm.wdata.hero.chosenEquipSet = ces;
					bm.RecalculateAttributes(bm.wdata.hero);
					view.overlay.hidden = false;
				} else {
					view.overlay.hidden = true;
				}
			}
		};
		view.regionChangeAction = i -> {
			bm.changeRegion(i);
		}
		view.areaChangeAction = i -> {
			bm.ChangeBattleArea(i);
		}
		var lastRegion = -1;
		var lastArea = -1;
		view.areaButtonHover = (i, b) -> {
			if (b) {
				if (lastRegion != bm.wdata.battleAreaRegion || lastArea != i) {
					lastArea = i;
					lastRegion = bm.wdata.battleAreaRegion;
					var enemy = null;

					if (lastArea != 0) {
						enemy = bm.CreateEnemy(bm.wdata.battleAreaRegion, i);
					}
					view.enemyAreaStats.parent.hidden = enemy == null;
					if (enemy != null)
						ActorToFullView(enemy, view.enemyAreaStats);
				}
			}
		}

		var ls = Browser.getLocalStorage();

		/*
			var button = new Button();
			button.top = 200;
			button.left = 200;
			button.text = "TEST";
		 */

		var time:Float = 0;

		var saveCount:Float = 0.3;

		bm.ForceSkillSetDrop(-1, null, {
			skills: [{id: "Slash", level: 1}, {id: "Cure", level: 1}, {id: "Protect", level: 3}]
		}, false);
		bm.wdata.hero.equipmentSets[bm.wdata.hero.chosenEquipSet].equipmentSlots[2] = 0;

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
				"you" => "graphics/main.jpg",
				"cid" => "graphics/cid.jpg",
				"man" => "graphics/cid.jpg"
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
		}, "You will lose all your progress", -1, view.title_buttonHolder);
		view.GetButton("reset").percentWidth = 100;

		StoryControlLogic.Init(haxe.Resource.getString("storyjson"), view, storyRuntime);
		var scriptExecuter = new Interp();
		var global = new Map<String, Float>();
		scriptExecuter.variables.set("global", global);

		var update = null;

		var overlayFullActorId = -1;

		view.addHover(view.heroView.parent, (b, comp) -> {
			trace("hero view");
			if (b == true && view.overlay.hidden) {}

			view.overlay.hidden = !b;
			overlayFullActorId = -1;
			view.overlayActorFullView.parent.hidden = !b;
			if (b) {
				overlayFullActorId = 0;
				view.overlayActorFullView.parent.hidden = false;
				ActorToFullView(bm.wdata.hero, view.overlayActorFullView);
				view.positionOverlay(view.heroView.parent);
			} else {
				trace("left");
			}
		});

		// var lagrimaAreaEnemies = ["Goblin", "Dog", "Giant", "Turtle"];
		var enemyLabels = [
			["Goblin", "Dog", "Giant", "Turtle"],
			["Wolf"],
			["Tonberry"],
			["Adamanstoise"],
			["Cactuar"],
			["Reaper"],
			["Witchhunter"],
			["Buff Witch"],
			["Witchkiller"],
		];
		var lagrimaAreaPrefix = [null, null, null, null, null, "Fire", "Ice", "Thunder"];

		view.addHover(view.enemyView.parent, (b, comp) -> {
			view.overlay.hidden = !b;
			overlayFullActorId = -1;
			view.overlayActorFullView.parent.hidden = !b;
			if (b) {
				overlayFullActorId = 1;
				ActorToFullView(bm.wdata.enemy, view.overlayActorFullView);
				view.positionOverlay(view.enemyView.parent);
			}
		});

		var GetBuffIcon = function(uniqueId, debuff):String {
			var buffText;
			if (buffToIcon.exists(uniqueId))
				buffText = buffToIcon[uniqueId];
			else {
				if (debuff == true)
					buffText = " &#129095;";
				else
					buffText = " &#129093;";
			}
			return buffText;
		}

		var ActorToView = function(actor:Actor, actorView:ActorView, enemyName = false) {
			if (actor != null) {
				if (enemyName) {
					if (bm.wdata.battleAreaRegion == 0) {
						var eafp = bm.enemyAreaFromProcedural;
						var eai = eafp.GetEnemyAreaInformation(bm.wdata.battleArea - 1);
						actorView.name.text = enemyLabels[0][eai.sheetId];
						if (lagrimaAreaPrefix[eai.equipId] != null) {
							actorView.name.text = lagrimaAreaPrefix[eai.equipId] + " " + actorView.name.text;
						}
						if (eai.level > 0) {
							if (eai.level < 10) {
								actorView.name.text = actorView.name.text + " Forte";
							} else if (eai.level < 30) {
								actorView.name.text = actorView.name.text + " Monstro";
							} else {
								actorView.name.text = actorView.name.text + " do Carai";
							}
						}
					} else {
						actorView.name.text = enemyLabels[bm.wdata.battleAreaRegion][0];
						actorView.name.text += " " + String.fromCharCode('A'.code + bm.wdata.battleArea - 1);

						/*var name = actorView.defaultName;
							if (name != actorView.name.text) {
								actorView.name.text = name;
						}*/
					}
				}

				if (actor == bm.wdata.hero) {
					actorView.portrait.resource = "graphics/heroicon.png";
				}
				if (actor == bm.wdata.enemy) {
					actorView.portrait.resource = "graphics/enemyicon.png";
				}
				var buffPos = 0;
				for (b in actor.buffs) {
					if (b != null && b.uniqueId != null) {
						view.FeedBuffView(actorView, buffPos, GetBuffIcon(b.uniqueId, b.debuff), b.uniqueId);
						buffPos++;
					}
				}
				if (bm.wdata.sleeping) {
					view.FeedBuffView(actorView, buffPos, "zZz", "nap");
					buffPos++;
				}
				if (bm.wdata.recovering) {
					view.FeedBuffView(actorView, buffPos, "&#x2620;", "dead");
					buffPos++;
				}

				view.FinishFeedBuffInfo(actorView, buffPos);
				// actorView.buffText.text = buffText;

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
		var lagrimaAreaLabels = [
			"Forest",
			"Streets",
			"Mountain",
			"Seaside",
			"Wild Plains",
			"Inactive Volcano",
			"Snow Fields",
			"Thunder Roads"
		];

		view.buffButtonHover = (struct, b) -> {
			view.overlayText.hidden = !b;
			if (b) {
				trace("buff view");
				if (buffToExplanation.exists(struct.buffId)) {
					var exp = buffToExplanation[struct.buffId];
					var id = struct.buffId;
					var icon = struct.labelText.text;
					view.overlayText.text = '$icon  ($id)\n$exp';
				} else {
					view.overlayText.text = struct.buffId;
				};
			}
		}

		var saveFileImporterSetup = false;

		var originMessage = "Hard Area Cleared!\nYour stats permanently increased!\n\n";
		var bossMessage = originMessage;

		var areaNames = new Array<Array<String>>();
		var battleIcons = ["graphics/heroicon.png", "graphics/enemyicon.png"];
		var turnIcons = new Array<String>();

		update = function(timeStamp:Float):Bool {
			if (overlayFullActorId == 0)
				ActorToFullView(bm.wdata.hero, view.overlayActorFullView);
			if (overlayFullActorId == 1 && bm.wdata.enemy != null)
				ActorToFullView(bm.wdata.enemy, view.overlayActorFullView);

			{
				var id = 0;
				for (i in 0...bm.wdata.regionProgress.length) {
					var rbl = bm.GetRegionBonusLevel(i);
					if (rbl > 0) {
						view.FeedRegionBonusView(id, enemyRegionNames[i], rbl);
						id++;
					}
				}
			}

			view.FeedEquipmentSetInfoAll(bm.wdata.hero.equipmentSets.length, bm.wdata.hero.chosenEquipSet);

			global["maxarea"] = bm.wdata.maxArea;
			global["herolevel"] = bm.wdata.hero.level;

			GameAnalyticsIntegration.InitializeCheck();
			ActorToView(bm.wdata.hero, view.heroView);
			ActorToView(bm.wdata.enemy, view.enemyView, true);

			var activeImage = null;
			turnIcons[0] = battleIcons[0];
			turnIcons[1] = battleIcons[1];
			if (bm.lastActiveActor != null) {
				if (bm.lastActiveActor == bm.wdata.hero)
					activeImage = turnIcons[0];
				else
					activeImage = turnIcons[1];
			}
			view.feedTurnOrder(bm.turnList, turnIcons, activeImage);
			ActorToFullView(bm.wdata.hero, view.equipHeroStats);

			{
				bm.RecalculateAttributes(bm.wdata.hero, false, false);
				ActorToFullView(bm.wdata.hero, view.charaTab_CharaBaseStats);
				bm.RecalculateAttributes(bm.wdata.hero);
			}

			ActorToFullView(bm.wdata.hero, view.charaTab_CharaEquipStats);
			var actor = bm.wdata.hero;
			view.UpdateValues(view.level, bm.wdata.hero.level, -1);
			view.UpdateValues(view.levelMax, bm.CalculateHeroMaxLevel(), -1);
			view.UpdateValues(view.xpBar, bm.wdata.hero.xp.value, bm.wdata.hero.xp.calculatedMax);

			view.UpdateValues(view.currencyViews[0], bm.wdata.currency.currencies["Lagrima"].value, -1);
			view.UpdateValues(view.currencyViews[1], bm.wdata.currency.currencies["Lagrima Stone"].value, -1);

			// view.UpdateValues(view.lifeView, bm.wdata.hero.attributesCalculated["LifeMax"], -1);

			RefreshAreaName(bm, bm.wdata.battleAreaRegion, bm.wdata.maxArea, areaNames, lagrimaAreaLabels);
			view.FeedAreaNames(areaNames[bm.wdata.battleAreaRegion], bm.wdata.battleArea);
			view.UpdateValues(view.areaLabel, 1, 1, null, false, areaNames[bm.wdata.battleAreaRegion][bm.wdata.battleArea]);

			view.UpdateValues(view.enemyToAdvance, bm.wdata.killedInArea[bm.wdata.battleArea], bm.wdata.necessaryToKillInArea);
			StoryControlLogic.Update(timeStamp, storyRuntime, view, scriptExecuter);

			var showLocked = 0;
			if (bm.wdata.battleAreaRegionMax < enemyRegionNames.length) {
				showLocked = 1;
			}
			view.FeedDropDownRegion(enemyRegionNames, bm.wdata.battleAreaRegionMax, bm.wdata.battleAreaRegion, showLocked, "Unreached");

			saveFileImporterSetup = updateImportExport(saveFileImporterSetup, view);

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
						view.FeedEquipmentBase(equipmentViewPos, equipName, bm.IsEquipped(i, false), rarity, -1, e.type == 2, e.seen == 1, upgradable,
							canUpgrade, upgradeCost, BattleManager.GetSellPrize(e, bm.wdata), upgradeLabel, upgradeCurrency, bm.IsEquipped(i, true));
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
										view.FeedEquipmentValue(equipmentViewPos, vid, "Skill", -1, SkillToExplanation[ssd.skills[s].id], false, skillName);
									}
									if (action.mode == 1) {
										view.FeedEquipmentValue(equipmentViewPos, vid, "Skill", -1, "You are not strong enough to use this skill", "???");
										// view.ButtonLabel(actionId, "Unlock at Level " + bm.skillSlotUnlocklevel[i]);
									}

									vid++;
								}
								view.FeedEquipmentSeparation(equipmentViewPos, vid - 1);
							}
						}

						for (v in e.attributes.keyValueIterator()) {
							view.FeedEquipmentValue(equipmentViewPos, vid, v.key, v.value, AttributeExplanation[v.key], false, null);
							vid++;
						}
						if (e.attributeMultiplier != null)
							for (v in e.attributeMultiplier.keyValueIterator()) {
								view.FeedEquipmentValue(equipmentViewPos, vid, v.key, v.value, AttributeExplanation[v.key], true);
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
					if (e.origin.type == 0)
						animations.playAnimation(view.heroView.parent, "attack-left");
					else
						animations.playAnimation(view.enemyView.parent, "attack-right");
					// view.enemyView.parent.paddingLeft = 200;
					// view.enemyView.parent.marginLeft = 100;
					// view.enemyView.parent.top = -10;
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
					view.ShowMessage("Equipment reached Limit Level", 'Your equipment reached Limit Level. The energy materializes into $dataString +$data');
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
					view.ShowMessage("Found New Location", 'Gained access to $regionName.\n\n(Accessed by using the Region Tab)');
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
			if (view.tabMaster.selectedPage == view.mainComponentB) {
				buttonToAction("advance", "advance");
				view.ButtonVisibility("advance", storyHappened);
				{
					var changeLabel = false;
					if (bm.wdata.battleAreaRegion == 0) {
						var nextAreaInformation = bm.enemyAreaFromProcedural.GetEnemyAreaInformation(bm.wdata.battleArea);
						if (nextAreaInformation.level > 0) {
							changeLabel = true;
							view.ButtonLabel("advance", "Next Area <br><span style='color:red;'>(Gate)</span>");
						}
					}
					if (changeLabel == false)
						view.ButtonLabel("advance", "Next Area");
				}
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
							view.updateDefaultHoverText(view.GetButton(id), SkillToExplanation[sb.id]);
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
							view.updateDefaultHoverText(view.GetButton(id), "");
						}
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
				var action = bm.wdata.playerActions["tabcharacter"];
				// view.TabVisible(view.storyTab, action.visible);
				view.TabVisible(view.charaTabWrap, action.visible);
			}
			{
				var action = bm.wdata.playerActions["tabregion"];
				// view.TabVisible(view.storyTab, action.visible);
				view.TabVisible(view.regionTab, action.visible);
			}
			{
				var action = bm.wdata.playerActions["equipset_menu"];
				view.equipmentSetButtonParent_Equipment.parentComponent.hidden = !action.visible;
			}
			{
				var action = bm.wdata.playerActions["equipset_battle"];
				view.equipmentSetButtonParent_Battle.parentComponent.hidden = !action.visible;
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
			animations.update(delta);
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
		view.tabMaster.selectedPage = view.mainComponentB;
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

	static function RefreshAreaName(bm:BattleManager, region:Int, maxArea:Int, areaNames:Array<Array<String>>, lagrimaAreaLabels) {
		if (areaNames[region] == null)
			areaNames[region] = new Array<String>();
		while (areaNames[region].length <= maxArea) {
			var bArea = areaNames[region].length;
			if (region == 0) {
				if (bArea > 0) {
					var pur = bm.enemyAreaFromProcedural.GetProceduralUnitRepeated(bArea - 1);
					var characteristic = pur.proceduralUnit.characteristics[0];
					var text = lagrimaAreaLabels[characteristic];

					switch pur.proceduralUnit.repeat {
						case 1:
							{
								text += " II";
							}
						case 2:
							{
								text += " III";
							}
						case 3:
							{
								text += " IV";
							}
						case 4:
							{
								text += " V";
							}
					}

					text += " - " + (pur.position + 1);
					areaNames[region].push(text);
					// view.UpdateValues(view.areaLabel, 1, 1, null, false, text);
				} else {
					if (region == 0)
						areaNames[region].push("Home");
					// view.UpdateValues(view.areaLabel, 1, 1, null, false, "Home");
					else
						areaNames[region].push("Entrance");
					// view.UpdateValues(view.areaLabel, 1, 1, null, false, "Entrance");
				}
				// view.UpdateValues
			} else {
				// view.UpdateValues(view.areaLabel, bm.wdata.battleArea + 1, -1);
				if (bArea == 0)
					areaNames[region].push("Entrance");
				else
					areaNames[region].push("" + (bArea));
			}
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
