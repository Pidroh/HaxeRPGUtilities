import Library.JSLibrary;
import js.Browser;
import js.html.Document;
import js.html.Location;
import js.html.Window;
import haxe.ui.styles.CompositeStyleSheet;
import haxe.ui.styles.StyleSheet;
import haxe.ui.util.StyleUtil;
import haxe.ui.events.UIEvent;
import ProceduralEnemyGeneration.EnemyAreaInformation;
import haxe.ui.styles.animation.util.ColorPropertyDetails;
import haxe.ui.Toolkit;
import haxe.ui.events.MouseEvent;
import Macros.MyMacro;
import haxe.ui.styles.elements.AnimationKeyFrame;
import haxe.ui.styles.elements.AnimationKeyFrames;
import haxe.ui.styles.animation.Animation;
import haxe.ui.components.TextArea;
import js.html.Text;
import haxe.ui.layouts.HorizontalGridLayout;
import haxe.ui.components.TabBar;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.components.DropDown;
import haxe.ui.styles.Style;
import js.html.StyleElement;
import haxe.ui.backend.html5.native.layouts.ButtonLayout;
import haxe.ui.layouts.VerticalLayout;
import haxe.ui.containers.Grid;
import haxe.ui.components.Image;
import js.html.AbortController;
import haxe.ui.components.Scroll;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.ContinuousHBox;
import haxe.ui.containers.ScrollView;
import haxe.ds.Vector;
import haxe.ui.containers.TabView;
import haxe.ui.containers.dialogs.MessageBox.MessageBoxType;
import RPGData.AttributeLogic;
import haxe.ui.components.Button;
import haxe.ui.containers.Box;
import haxe.ui.core.Screen;
import haxe.ui.containers.HBox;
import haxe.ui.core.Component;
import haxe.ui.containers.VBox;
import haxe.ui.components.Label;
import haxe.ui.components.HorizontalProgress;

class View {
	public static final storyAction_Start = 0;
	public static final storyAction_Continue = 1;
	public static final storyAction_AdvanceMessage = 2;
	public static final storyAction_SkipStory = 3;
	public static final storyAction_WatchLater = 4;
	public static final storyAction_WatchLaterClose = 5;

	public static final equipmentAction_DiscardBad = 4;
	public static final equipmentAction_ChangeTypeToView = 5;
	public static final equipmentAction_ChangeSet = 6;
	public static final equipmentAction_SetPreview = 7;

	public static final Title_ActionGame = 0;

	public var heroView:ActorView;
	public var enemyView:ActorView;

	public var equipHeroStats:ActorViewComplete;
	public var enemyAreaStats:ActorViewComplete;

	public var level:ValueView;
	public var xpBar:ValueView;
	// public var speedView:ValueView;
	// public var attackView:ValueView;
	public var lifeView:ValueView;

	// public var defView:ValueView;
	// public var mDefView:ValueView;
	public var currencyViews = new Array<ValueView>();

	public var statEquipmentParent:Component;

	public var enemyToAdvance:ValueView;
	public var areaLabel:ValueView;
	// public var regionLabel:ValueView;
	public var mainComponent:Component;
	public var mainComponentB:Component;
	public var equipTabChild:Component;
	public var storyTab:UIElementWrapper;
	public var equipTab:UIElementWrapper;
	public var developTab:UIElementWrapper;
	public var tabMaster:TabView;
	public var regionTab:UIElementWrapper;
	public var logText:Label;
	public var logTextBattle:Label;
	public var areaNouns = 'forest@meadow@cave@mountain@road@temple@ruin@bridge'.split('@');
	public var prefix = 'normal@fire@ice@water@thunder@wind@earth@poison@grass'.split('@');
	public var enemy1 = 'slime@orc@goblin@bat@eagle@rat@lizard@bug@skeleton@horse@wolf@dog'.split('@');

	public var charaTabWrap:UIElementWrapper;
	public var charaTab:Component;
	public var charaTab_CharaBaseStats:ActorViewComplete;
	public var charaTab_CharaEquipStats:ActorViewComplete;
	public var charaTab_RegionElements:Component;
	public var charaTab_ButtonParent:VBox;
	public var charaTab_bonusesView = new Array<BonusView>();

	public var turnOrder_Images = new Array<Image>();
	public var turnOrder_ActiveImage:Image;
	public var turnOrder_ImageParent:Component;

	public var titleAction:(Int) -> Void;
	public var title_NewGameButton:Button;

	var turnOrder_Dimension = 32;

	public var equipmentMainAction:(Int, Int) -> Void;
	public var storyMainAction:(Int, Int) -> Void;
	public var regionChangeAction:(Int) -> Void;
	public var areaChangeAction:(Int) -> Void;
	public var areaButtonHover:(Int, Bool) -> Void;
	public var buffButtonHover:(BuffView, Bool) -> Void;

	public var areaContainer:Component;
	// public var regionButtonParent:Component;
	public var levelContainer:Component;
	public var battleView:Component;

	public var equipmentSetButtonParent_Battle:Component;
	public var equipmentSetButtonParent_Equipment:Component;

	public var buttonDiscardBad:Button;

	var buttonBox:Component;
	var buttonMap = new Map<String, Button>();
	var hoverTextMap = new Map<Component, String>();

	var equipments = new Array<EquipmentView>();

	public var equipmentTypeSelectionTabbar:TabBar;
	public var equipmentTypeNames:Array<String>;

	var saveDataDownload:Label;

	public var storyDialogActive = false;
	public var storyDialogUtilityFlag = false;

	var cutsceneStartViews = new Array<CutsceneStartView>();

	public var amountOfStoryMessagesShown = 0;
	public var storyDialog:StoryDialog;

	public var overlay:Component;
	public var overlayActorFullView:ActorViewComplete;
	public var overlayText:Label;

	public function Update() {
		// equipTabChild.width = equipTabChild.parentComponent.width - 40;
		equipTabChild.width = Screen.instance.width - 40 - 60 - 200;
		if (overlay.hidden == false) {
			if (overlay.top + overlay.height > Screen.instance.height) {
				overlay.top = -overlay.height + Screen.instance.height;
			}
		}
	}

	public static function TabBarAlert(tabBar:TabBar, alert:Array<Bool>, names:Array<String>) {
		for (i in 0...alert.length) {
			if (alert[i])
				tabBar.getComponentAt(i).text = names[i] + " (!)";
			else
				tabBar.getComponentAt(i).text = names[i];
		}
	}

	function FeedEquipmentSetInfo(numberOfSets:Int, chosenSet:Int, parent:Component) {
		if (parent == null)
			return;
		var cc = parent.childComponents;
		while (cc.length < numberOfSets) {
			var button = new Button();
			var setPos = cc.length;
			button.onClick = event -> {
				equipmentMainAction(setPos, equipmentAction_ChangeSet);
			};
			addHover(button, (b, component) -> {
				var pos = setPos;
				equipmentMainAction(pos, equipmentAction_SetPreview);
				overlay.hidden = !b;

				if (b) {
					positionOverlay(button);
				} else {
					overlayText.text = "";
					overlayText.hidden = true;
					pos = -1;
				}
				// overlay.hidden = !b;
			});
			button.text = "Set " + (setPos + 1);
			button.width = 65;
			button.height = 30;
			button.toggle = true;
			parent.addComponent(button);
			cc = parent.childComponents;
		}
		for (i in 0...cc.length) {
			cc[i].hidden = i >= numberOfSets;
			var b:Button = cast(cc[i], Button);
			b.selected = i == chosenSet;
		}
	}

	public function FeedEquipmentSetInfoAll(numberOfSets:Int, chosenSet:Int) {
		FeedEquipmentSetInfo(numberOfSets, chosenSet, equipmentSetButtonParent_Battle);
		FeedEquipmentSetInfo(numberOfSets, chosenSet, equipmentSetButtonParent_Equipment);
	}

	public function SetupEquipmentSetSelector(parent:Component):Component {
		var vbox = CreateContainer(parent, false);
		var title = new Label();
		title.text = "Equipment\nSet";
		title.percentHeight = 100;
		title.verticalAlign = "center";
		title.paddingRight = 20;
		vbox.addComponent(title);
		var buttonParent = new HBox();
		vbox.addComponent(buttonParent);
		// parent.addComponent(vbox);
		return buttonParent;
	}

	public function LatestMessageUpdate(message:String, speaker:String, imageFile:String, messagePos:Int) {
		if (speaker == null)
			speaker = "";
		if (messagePos >= amountOfStoryMessagesShown) {
			amountOfStoryMessagesShown = messagePos + 1;
			while (storyDialog.messages.length <= messagePos) {
				var body = new Label();
				body.percentWidth = 100;
				var speaker = new Label();
				speaker.percentWidth = 100;
				// speaker.styleString = "font-weight: bold;";
				speaker.styleString = "font-bold: true;";
				// var style = new Style();
				// style.fontBold = true;
				// style.fontBold = true;
				// speaker.style = style;

				var textBox = new VBox();
				textBox.percentWidth = 100;
				textBox.percentHeight = 100;
				textBox.addComponent(speaker);
				textBox.addComponent(body);

				var face = new Image();
				face.scaleMode = FIT_HEIGHT;
				var res = face.resource;
				face.percentHeight = 100;
				face.resource = "graphics/main.png";

				var parent = new Grid();
				parent.columns = 2;
				parent.addComponent(face);

				parent.addComponent(textBox);
				parent.percentWidth = 90;
				parent.height = 60;

				var messageView:MessageView = {
					message: body,
					parent: parent,
					speakerImage: face,
					speakerText: speaker
				};
				storyDialog.messages.push(messageView);
				storyDialog.messageParent.addComponent(parent);
			}

			storyDialog.messages[messagePos].speakerText.text = speaker;
			storyDialog.messages[messagePos].message.text = message;
			storyDialog.messages[messagePos].speakerImage.resource = imageFile;
			storyDialog.messages[messagePos].parent.hidden = false;
			storyDialog.scroll.vscrollPos = 9999;
			// storyDialog.mainText.text += '$speaker: $message\n';
		}
	}

	public function HideStory() {
		storyDialog.hide();
		storyDialogActive = false;
		this.amountOfStoryMessagesShown = 0;
	}

	public function StartStory() {
		storyDialog.showDialog();
		storyDialog.onDialogClosed = event -> {
			storyMainAction(storyAction_WatchLaterClose, 0);
		};
		storyDialogActive = true;
		// storyDialog.mainText.text = "";
		for (a in storyDialog.messages) {
			a.parent.hidden = true;
		}
		this.amountOfStoryMessagesShown = 0;
	}

	public function GetValueView(actorView:ActorViewComplete, pos, bar) {
		while (actorView.valueViews.length <= pos) {
			var vv = CreateValueView(actorView.parent, bar, "s", 240, 130);
			addDefaultHover(vv.parent);
			actorView.valueViews.push(vv);
		}
		return actorView.valueViews[pos];
	}

	public function StoryButtonAmount(amount:Int) {
		while (cutsceneStartViews.length < amount) {
			var parent = CreateContainer(storyTab.component, false, true);
			parent.horizontalAlign = "center";
			var startB = new Button();
			startB.text = "Start";
			var resumeB = new Button();
			resumeB.text = "Resume";
			// resumeB.hidden = true;
			var title = new Label();
			title.text = "dummy";
			title.verticalAlign = "center";
			// title.percentHeight = 100;

			// title.height = 20;

			parent.percentWidth = 100;
			parent.height = 60;

			var hBox = new HBox();
			hBox.percentHeight = 100;
			hBox.horizontalAlign = "right";

			var newL = new Label();
			newL.text = "NEW";
			newL.width = 70;
			newL.textAlign = "center";
			hBox.addComponent(newL);

			newL.verticalAlign = "center";
			newL.textAlign = "center";
			// newL.percentHeight = 100;

			hBox.addComponent(startB);
			hBox.addComponent(resumeB);
			parent.addComponent(title);
			parent.addComponent(hBox);

			startB.verticalAlign = "center";
			resumeB.verticalAlign = "center";

			cutsceneStartViews.push({
				startButton: startB,
				resumeButton: resumeB,
				title: title,
				parent: parent,
				newLabel: newL
			});
			var pos = cutsceneStartViews.length - 1;
			startB.onClick = (e) -> {
				storyMainAction(View.storyAction_Start, pos);
			}
			resumeB.onClick = (e) -> {
				storyMainAction(View.storyAction_Continue, pos);
			}

			// storyTab.component.addComponent(parent);
		}
	}

	public function SetTabNotification(notify:Bool, comp:UIElementWrapper) {
		comp.component.text = comp.baseText;
		if (notify)
			comp.component.text += " (!)";
	}

	public function StoryButtonFeed(buttonPos:Int, label:String, cleared:Bool, resumable:Bool, newLabel:Bool, newLabelText:String) {
		cutsceneStartViews[buttonPos].title.text = label;
		cutsceneStartViews[buttonPos].parent.show();
		cutsceneStartViews[buttonPos].resumeButton.hidden = !resumable;
		cutsceneStartViews[buttonPos].newLabel.hidden = !newLabel;
		cutsceneStartViews[buttonPos].newLabel.text = newLabelText;
	}

	public function StoryButtonHide(buttonPos:Int) {
		cutsceneStartViews[buttonPos].parent.hide();
	}

	public function updateDefaultHoverText(c:Component, text) {
		hoverTextMap[c] = text;
	}

	public function addHoverClasses(c:Component) {
		c.addClass(style_Class_HoverableBack);
		addHover(c, (b, component) -> {
			if (b)
				c.addClass(":hover", true, true);
			else
				c.removeClass(":hover", true, true);
		});
	}

	public function addDefaultHover(c:Component) {
		addHover(c, (b, component) -> {
			overlay.hidden = !b;
			overlayText.hidden = !b;
			if (b) {
				positionOverlay(c);
				overlayText.text = hoverTextMap[c];
			}
		});
	}

	public function addHover(c:Component, callback) {
		var hovering = false;
		c.registerEvent(MouseEvent.MOUSE_OVER, (e) -> {
			hovering = true;
			callback(true, c);
		});
		c.registerEvent(MouseEvent.MOUSE_OUT, (e) -> {
			hovering = false;
			callback(false, c);
		});
		c.registerEvent(UIEvent.DISABLED, (e) -> {
			if (hovering) {
				hovering = false;
				callback(false, c);
			}
		});
	}

	var style_Class_HoverableBack = "hoverableback";

	public function new() {
		Toolkit.styleSheet.parse('
		.$style_Class_HoverableBack:hover {
			background-color: #2F4F4F;
			}
		.button:hover{
			background: #01594f #1e3e7d;
			background-gradient-style: horizontal;
		}
		.fade-in {
			animation: animationFadeIn 4s linear 0s 1;
		}
		a {
			background: #3e4142 #36383a;
    		border-color: #181a1b;
    		color: #b4b4b4;
		}
		.a:hover{
			background: #01594f #1e3e7d;
			background-gradient-style: horizontal;
		}
		');

		// Toolkit.styleSheet.addStyleSheet(ss);
		overlay = new VBox();
		overlay.hidden = true;
		overlay.addClass("default-background");
		// overlay.borderColor = "#BBBBBB";
		overlay.borderSize = 1;
		overlay.padding = 10;

		{
			overlayText = new Label();
			overlay.addComponent(overlayText);
		}

		overlayActorFullView = CreateActorViewComplete("", overlay);

		{
			var boxParentP = new Box();
			boxParentP.addClass("default-background");
			boxParentP.percentHeight = 100;
			boxParentP.verticalAlign = "bottom";
			mainComponent = boxParentP;
			boxParentP.paddingTop = 5;
			boxParentP.paddingLeft = 20;
			boxParentP.paddingRight = 20;
			boxParentP.paddingBottom = 5;
			boxParentP.percentWidth = 100;

			{
				var title = new Label();
				title.htmlText = "<h1>Generic RPG I</h1>";
				boxParentP.addComponent(title);
				title.height = 40;
			}

			{
				var title = new Label();
				var platform = MyMacro.GetPlatform();
				title.htmlText = platform
					+
					" Alpha 0.15B. <a href='https://github.com/Pidroh/HaxeRPGUtilities/wiki' target='_blank'>__Road Map__</a>              A prototype for the progression mechanics in <a href='https://store.steampowered.com/app/1638970/Brave_Ball/'  target='_blank'>Brave Ball</a>.     <a href='https://discord.com/invite/AtGrxpM'  target='_blank'>   Discord Channel   </a>";
				title.percentWidth = 100;
				title.textAlign = "right";
				title.paddingRight = 20;
				title.paddingLeft = 20;
				title.paddingTop = 10;

				boxParentP.addComponent(title);
			}
		}

		tabMaster = new TabView();
		tabMaster.percentWidth = 100;
		mainComponent.addComponent(tabMaster);
		tabMaster.percentHeight = 90;
		tabMaster.verticalAlign = "bottom";

		{
			var gameTab = new Box();
			gameTab.percentWidth = 100;
			gameTab.percentHeight = 100;
			gameTab.text = "Title";
			var buttonHolder = CreateContainer(gameTab, true);
			buttonHolder.width = 250;

			{
				
				var b = new Button();
				b.text = "New Game";
				b.onClick = event -> {
					titleAction(Title_ActionGame);
				}
				b.percentWidth = 100;
				title_NewGameButton = b;
				buttonHolder.addComponent(b);
			}
			{
				var b = new Button();
				b.text = "Roadmap";
				b.onClick = event -> {
					JSLibrary.OpenURL("https://github.com/Pidroh/HaxeRPGUtilities/wiki");
				}
				b.percentWidth = 100;
				buttonHolder.addComponent(b);
			}

			{
				var discord = new Button();
				discord.percentWidth = 100;
				buttonHolder.addComponent(discord);

				var dim = new Image();
				dim.resource = "graphics/discord.png";
				dim.scaleMode = FIT_HEIGHT;
				dim.height = 30;
				dim.horizontalAlign = "center";

				discord.addComponent(dim);
				discord.onClick = event -> {
					JSLibrary.OpenURL("https://discord.gg/AtGrxpM ");
				}
			}
			{
				var white = new Box();
				white.height = 40;
				buttonHolder.addComponent(white);

				{
					var title = new Label();
					title.percentWidth = 100;
					title.height = 40;
					// title.addClass("button");

					title.text = "Export save data";
					saveDataDownload = title;

					buttonHolder.addComponent(title);
				}
				{
					var title = new Label();
					title.percentWidth = 100;
					title.horizontalAlign = "left";
					title.textAlign = "left";
					title.height = 40;
					// title.addClass("button");

					title.htmlText = "Import Save: <input id='import__' type='file'></input>";

					buttonHolder.addComponent(title);
				}
			}

			// discord.icon = "graphics/discord.png";

			// discord.text = "Discord";

			tabMaster.addComponent(gameTab);
		}
	}

	public function tabMasterSetup() {
		{
			var grid = new Grid();
			var regionTabComp = grid;
			this.regionTab = new UIElementWrapper(regionTabComp, tabMaster);
			regionTab.desiredPosition = 1;

			regionTabComp.percentWidth = 100;
			grid.columns = 3;

			regionTabComp.text = "Regions";
			regionTabComp.percentHeight = 90;

			{
				var scroll = CreateScrollable(regionTabComp);
				scroll.marginLeft = 15;
				scroll.marginTop = 15;
				scroll.padding = 15;
				scroll.width = 200;
				scroll.percentHeight = 100;
				var vb = new VBox();
				vb.horizontalAlign = "center";
				scroll.addComponent(vb);
			}

			{
				var scroll = CreateScrollable(regionTabComp);
				scroll.marginLeft = 15;
				scroll.marginTop = 15;
				scroll.padding = 15;
				scroll.width = Screen.instance.width * 0.28;
				scroll.percentHeight = 100;
				scroll.horizontalAlign = "center";

				var vb = new ContinuousHBox();
				vb.width = scroll.width - 30;
				vb.horizontalAlign = "center";
				scroll.addComponent(vb);
			}
			{
				enemyAreaStats = CreateActorViewComplete("Enemy", regionTabComp);
				enemyAreaStats.parent.marginLeft = 30;
				enemyAreaStats.parent.marginTop = 15;
				enemyAreaStats.parent.percentHeight = 90;
			}
			// regionTab.hidden = false;
		}
		var battleParent = new HBox();
		battleParent.percentHeight = 100;
		// mainComponent.addComponent(boxParent);
		tabMaster.addComponent(battleParent);
		battleParent.text = "Main";
		mainComponentB = battleParent;
		// boxParent.horizontalAlign = "center";
		battleParent.paddingLeft = 40;
		battleParent.paddingTop = 10;
		var verticalBox = new Box();
		var hgl = new HorizontalGridLayout();
		hgl.rows = 5;
		verticalBox.layout = hgl;
		verticalBox.percentHeight = 100;

		battleParent.addComponent(verticalBox);

		buttonBox = CreateContainer(battleParent, true);

		{
			var box = new Box();
			box.width = 250;
			box.percentHeight = 100;
			battleParent.addComponent(box);
			{
				var scroll = CreateScrollable(box);
				scroll.width = 250;
				scroll.percentHeight = 40;
				var logContainer = CreateContainer(scroll, true);

				var log = new Label();
				logText = log; // make this battle log
				logText.text = "You exist";
				logText.htmlText = logText.text;
				logContainer.addComponent(log);
				log.width = 190;
				log.horizontalAlign = "center";
				logContainer.horizontalAlign = "center";
			}
			{
				var scroll = CreateScrollable(box);
				scroll.width = 250;
				scroll.percentHeight = 60; // TODO change this to 60 and add new log below it  X_X
				var logContainer = CreateContainer(scroll, true);
				scroll.verticalAlign = "bottom";

				var log = new Label();
				logTextBattle = log;
				logTextBattle.text = "You are healthy";
				logTextBattle.htmlText = "You are healthy";
				logContainer.addComponent(log);
				log.width = 190;
				log.horizontalAlign = "center";
				logContainer.horizontalAlign = "center";
			}
		}

		if (false) {
			var tt = new Box();
			tt.width = 100;
			tt.percentHeight = 100;
			// new Box
		}

		areaContainer = CreateContainer(verticalBox, false);

		{
			levelContainer = CreateContainer(verticalBox, true);
			level = CreateValueView(levelContainer, false, "Level: ");
			xpBar = CreateValueView(levelContainer, true, "XP: ");
		}
		{
			// var container = CreateContainer(areaContainer, false);

			areaLabel = CreateValueView(areaContainer, false, "Area: ", 200, 140);

			var b = new Box();
			b.width = 30;
			areaContainer.addComponent(b);
			// areaLabel.parent.width += 40;
			enemyToAdvance = CreateValueView(areaContainer, true, "Progress: ");
		}

		{
			var size = 36;
			var turnParent = CreateContainer(verticalBox, false);
			// verticalBox.addComponent(turnParent);
			var thisTurnBox = new Box();
			thisTurnBox.width = 40;
			thisTurnBox.height = 40;
			thisTurnBox.padding = 4;
			thisTurnBox.borderSize = 1;
			var imageActive = new Image();
			imageActive.opacity = 0.3;
			imageActive.width = turnOrder_Dimension;
			imageActive.height = turnOrder_Dimension;
			turnParent.percentWidth = 100;
			turnParent.addComponent(thisTurnBox);
			thisTurnBox.addComponent(imageActive);

			turnOrder_ActiveImage = imageActive;
			turnOrder_ImageParent = turnParent;
		}

		battleView = CreateContainer(verticalBox, false);
		battleView.width = 440;
		heroView = GetActorView("You", battleView);
		var box = new Box();
		box.width = 40;
		battleView.addComponent(box);
		enemyView = GetActorView("Enemy", battleView);

		{
			equipmentSetButtonParent_Battle = SetupEquipmentSetSelector(verticalBox);
		}

		// var battleButtonView = CreateContainer(verticalBox, false);

		{
			equipTabChild = new ContinuousHBox();
			var tabBar = new TabBar();
			tabBar.percentWidth = 100;
			equipmentTypeSelectionTabbar = tabBar;
			equipTabChild.addComponent(tabBar);

			buttonDiscardBad = new Button();
			buttonDiscardBad.text = "Discard worse equipment";
			buttonDiscardBad.onClick = event -> {
				equipmentMainAction(-1, View.equipmentAction_DiscardBad);
			}
			equipTabChild.addComponent(buttonDiscardBad);

			var gridBox = new HBox();
			// gridBox.columns =2;
			gridBox.text = "Equipment";
			equipTab = new UIElementWrapper(gridBox, tabMaster);
			equipTab.desiredPosition = 2;
			gridBox.percentHeight = 100;
			gridBox.percentWidth = 100;

			{
				var statContainer = CreateContainer(gridBox, true);

				currencyViews.push(CreateValueView(statContainer, false, "Lagrima: "));
				currencyViews.push(CreateValueView(statContainer, false, "Lagrima\nStone: "));

				var box = new Box();
				box.height = 40;
				statContainer.addComponent(box);

				{}
				equipHeroStats = CreateActorViewComplete("You", statContainer);

				// lifeView = CreateValueView(statContainer, true, "Life: ");
				// attackView = CreateValueView(statContainer, false, "Attack: ");
				// speedView = CreateValueView(statContainer, false, "Speed: ");
				// defView = CreateValueView(statContainer, false, "Def: ");
				// mDefView = CreateValueView(statContainer, false, "mDef: ");

				statEquipmentParent = statContainer;
			}
			var equipRightSide = new VBox();
			equipRightSide.percentWidth = 100;
			equipRightSide.percentHeight = 100;
			this.equipmentSetButtonParent_Equipment = SetupEquipmentSetSelector(equipRightSide);
			gridBox.addComponent(equipRightSide);

			var scroll = CreateScrollable(equipRightSide);

			scroll.height = 300;
			scroll.text = "Equipment";

			scroll.addComponent(equipTabChild);
			gridBox.paddingLeft = 40;
			gridBox.paddingTop = 10;
			// scroll.width = 640;
			scroll.percentWidth = 100;
			// scroll.width = Screen.instance.width;
			scroll.percentHeight = 100;
		}
		{
			var grid = new Grid();
			charaTab = grid;
			charaTabWrap = new UIElementWrapper(charaTab, tabMaster);
			grid.columns = 3;
			grid.text = "Character";
			grid.percentHeight = 100;

			{
				var box = new VBox();
				box.padding = 15;
				charaTab_CharaBaseStats = CreateActorViewComplete("BASE STATS", box);
				grid.addComponent(box);
			}
			{
				var box = new VBox();
				box.padding = 15;
				charaTab_CharaEquipStats = CreateActorViewComplete("FINAL STATS", box);
				grid.addComponent(box);
			}
			{
				var upperBox = new Box();
				grid.addComponent(upperBox);
				var header = new Label();
				upperBox.addComponent(header);
				header.text = "PERMANENT BONUSES";
				var box = new VBox();
				box.padding = 15;
				charaTab_RegionElements = box;
				box.width = 200;
				var scroll = CreateScrollable(upperBox);
				scroll.verticalAlign = "bottom";
				scroll.width = 200;
				scroll.percentHeight = 90;
				// scroll.top = 30;
				// scroll.paddingTop = 80;
				upperBox.width = scroll.width;
				upperBox.percentHeight = 100;

				scroll.addComponent(box);
			}

			for (i in 0...2) {
				var box = new VBox();
			}
		}
		{
			var storyTabComp = new ContinuousHBox();
			storyTabComp.width = 600;
			storyTabComp.height = 300;
			storyTabComp.text = "Memories";
			var storyLabel = new Label();
			storyLabel.percentWidth = 100;
			storyLabel.textAlign = "center";
			storyLabel.text = "Revisit your memories";
			storyTabComp.addComponent(storyLabel);
			storyTabComp.paddingLeft = 40;
			storyTabComp.paddingTop = 10;
			// tabMaster.addComponent(storyTabComp);

			this.storyTab = new UIElementWrapper(storyTabComp, tabMaster);
			storyTab.desiredPosition = 2;
		}

		storyDialog = new StoryDialog();
		storyDialog.advanceButton.onClick = (e) -> {
			storyMainAction(View.storyAction_AdvanceMessage, 0);
		}
		storyDialog.skipButton.onClick = event -> storyMainAction(View.storyAction_SkipStory, 0);
		storyDialog.watchLaterButton.onClick = event -> storyMainAction(View.storyAction_WatchLater, 0);

		{
			var devTab = new VBox();

			devTab.paddingLeft = 40;
			var texter = (text, bigfont = false) -> {
				var label = new Label();
				label.htmlText = text;
				devTab.addComponent(label);

				if (bigfont) {
					label.styleString = "font-size: 18";
				}
			};
			{
				texter('<h2 style="color: #2e6c80;">Stay up to date</h2>');
			}
			{
				// texter('You can join us on Discord to stay up to date on news for the game!');
				texter('You can join us on Discord to stay up to date on news for the game!
				<br>Hate Discord? you can subscribe to our mailing list!');
			}
			texter('<h2 style="color: #2e6c80;">Suggest new features</h2>');
			texter('There is a channel on Discord to suggest new features and you can also add them as comments on the mailing list articles');
			// texter('There is a channel on Discord to suggest new features');
			texter('<br><a href="https://discord.com/invite/AtGrxpM" target="_blank">DISCORD</a>', true);
			texter('<a href="https://pidroh.substack.com/" target="_blank">MAILING LIST</a>', true);

			devTab.text = "News & Suggestions";
			developTab = new UIElementWrapper(devTab, tabMaster);
			developTab.tabVisible = false;
			// tabMaster.addComponent(devTab);

			// How to stay up to date
			// How to suggest features
		}
	}

	public function feedTurnOrder(turnOrder:Array<Int>, images:Array<String>, currentActorImageF:String) {
		turnOrder_ActiveImage.resource = currentActorImageF;
		while (turnOrder.length > turnOrder_Images.length) {
			var im = new Image();
			im.width = turnOrder_Dimension;
			im.height = turnOrder_Dimension;
			im.verticalAlign = "center";
			turnOrder_ImageParent.addComponent(im);
			turnOrder_Images.push(im);
			im.opacity = 0.3;
		}
		for (index => value in turnOrder_Images) {
			value.hidden = index >= turnOrder.length;
			if (value.hidden == false) {
				value.resource = images[turnOrder[index]];
			}
		}
	}

	public function GetEquipmentType():Int {
		return equipmentTypeSelectionTabbar.selectedIndex;
	}

	public function positionOverlay(comp:Component) {
		var xDis = 10;
		var yDis = 10;
		var left = comp.screenLeft;
		left += comp.width + xDis;
		var top = comp.screenTop - yDis;
		var screenH = Screen.instance.height;
		var overH = overlay.height;
		var screenOverFlowY = top + overH - screenH;
		if (screenOverFlowY > 0) {
			top -= screenOverFlowY;
		}

		overlay.left = left;
		overlay.top = top;
	}

	public function FeedEquipmentTypes(types:Array<String>) {
		equipmentTypeNames = types;
		for (type in types) {
			var b = new Button();
			b.text = type;
			equipmentTypeSelectionTabbar.addComponent(b);
		}
	}

	public function FeedAreaNames(areaNames:Array<String>, currentArea) {
		var children = regionTab.component.getComponentAt(1).getComponentAt(0).childComponents;
		var buttonAmount = children.length;
		if (children.length < areaNames.length) {
			var b = new Button();
			var areaPos = children.length;

			b.onClick = event -> {
				areaChangeAction(areaPos);
				tabMaster.selectedPage = mainComponentB;
			}
			b.width = 150;
			b.height = 40;
			/*
				if (children.length == 0) {
					b.marginLeft = 100;
					b.marginTop = 100;
				}
			 */
			b.toggle = true;
			addHover(b, (b, component) -> areaButtonHover(areaPos, b));
			regionTab.component.getComponentAt(1).getComponentAt(0).addComponent(b);
		}
		for (i in 0...children.length) {
			var hide = i >= areaNames.length;
			var b:Button = cast(children[i], Button);
			b.selected = currentArea == i;
			b.marginTop = 100;
			b.marginLeft = 100;
			// hide = true;
			children[i].hidden = hide;
			if (hide == false) {
				children[i].text = areaNames[i];
			}
		}

		// regionTab.component.getComponentAt(1).getComponentAt(0).marginRight = 100;
	}

	public function FeedDropDownRegion(regionNames, regionAmount, currentRegion, showLocked = 0, lockedMessage = null) {
		// feed the current region view
		// regionLabel.centeredText.text = regionNames[currentRegion];

		var buttonAmount = regionAmount + showLocked;

		var children = regionTab.component.getComponentAt(0).getComponentAt(0).childComponents;

		if (children.length < buttonAmount) {
			var b = new Button();
			var regionPos = children.length;
			// regionButtonParent.addComponent(b);
			regionTab.component.getComponentAt(0).getComponentAt(0).addComponent(b);

			b.onClick = event -> regionChangeAction(regionPos);
			b.width = 150;
			b.height = 40;
			b.toggle = true;
		}
		for (i in 0...children.length) {
			var hide = i >= buttonAmount;
			var b:Button = cast(children[i], Button);
			if (currentRegion == i) {}
			b.selected = currentRegion == i;
			// hide = true;
			children[i].hidden = hide;
			if (hide == false) {
				children[i].text = regionNames[i];
			}

			b.disabled = i >= regionAmount;
			if (b.disabled && hide == false) {
				b.text = lockedMessage;
			}
		}
	}

	public function FeedSave(saveDataContent:String) {
		// saveDataContent = StringTools.htmlEscape(saveDataContent);
		// saveDataContent = "ssssss";
		saveDataDownload.htmlText = "<a href='data:text/plain;charset=utf-8,";
		saveDataDownload.htmlText += saveDataContent;
		saveDataDownload.htmlText += "' download='savedata.json'>Export save data</a>";

		// saveDataDownload.htmlText += "' download='savedata.json'><button>Export save data</button></a>";

		// title.html = "";
		/**
			<a href="data:text/plain;charset=utf-8,blablabla" download="savedata.json">
			DSADSADASD
			</a>					
		**/
	}

	// the current implementation for tab elements is to remove and add back to the parent
	public function TabVisible(element:UIElementWrapper, visible:Bool) {
		var currentStateVisible = element.tabVisible;
		if (visible != currentStateVisible) {
			if (visible) {
				if (element.parent.childComponents.length <= element.desiredPosition || element.desiredPosition < 0) {
					element.parent.addComponent(element.component);
				} else {
					element.parent.addComponentAt(element.component, element.desiredPosition);
				}
				// element.component.fadeIn();
			} else {
				if (element.desiredPosition >= 0)
					tabMaster.removePage(element.desiredPosition);

				// tabMaster.removeAllPages();
				element.parent.removeComponent(element.component);
			}
		}
		element.tabVisible = visible;
	}

	public function CreateScrollable(parent:Component) {
		var container:Component;
		var sv = new ScrollView();
		sv.percentContentWidth = 100;
		container = sv;
		// container = new Box();
		if (parent != null)
			parent.addComponent(container);
		return container;
	}

	public function CreateContainer(parent:Component, vertical, justABox = false) {
		var container:Component;

		if (justABox)
			container = new Box();
		else {
			if (vertical == false)
				container = new HBox();
			else
				container = new VBox();
		}

		// container.percentWidth = 100;
		// container.borderRadius = 1;
		if (Toolkit.theme != 'dark')
			container.borderColor = "#AAAAAA";
		container.borderSize = 1;
		container.padding = 15;
		parent.addComponent(container);
		return container;
	}

	public function AddEventText(text:String) {
		AddEventTextWithLabel(text, logText);
	}

	public function AddEventTextWithLabel(text:String, logText:Label) {
		if (logText.text == null) {
			logText.text = text;
			logText.htmlText = text;
			return;
		}

		logText.htmlText = text + "\n\n" + logText.htmlText;
	}

	public function EquipmentAmountToShow(amount:Int) {
		while (amount > equipments.length) {
			var viewParent = new VBox();
			// viewParent.borderRadius = 10;
			viewParent.borderSize = 1;
			viewParent.padding = 6;

			var header = new Box();
			header.percentWidth = 100;
			header.height = 32;
			var name = new Label();
			name.text = "Sword";
			// name.percentHeight = 100;
			name.percentWidth = 80;
			name.verticalAlign = "Center";
			header.addComponent(name);
			var rightLabelBox = new VBox();
			// rightLabelBox.percentWidth = 20;
			// rightLabelBox.percentHeight = 100;
			rightLabelBox.paddingLeft = 5;
			rightLabelBox.paddingRight = 5;
			rightLabelBox.horizontalAlign = "right";
			var rightLabel = new Label();
			rightLabel.text = "New";
			rightLabel.horizontalAlign = "right";
			// rightLabel.verticalAlign = "center";
			rightLabelBox.backgroundColor = "#FFAAAA";
			if (Toolkit.theme == 'dark') {
				rightLabelBox.backgroundColor = "#440000";
			}
			rightLabelBox.addComponent(rightLabel);
			header.addComponent(rightLabelBox);
			viewParent.addComponent(header);

			var buttonsAct = new Vector<Button>(3);

			for (i in 0...buttonsAct.length) {
				var button = new Button();
				button.text = "Equip";
				if (i == 1)
					button.text = "Sell";
				if (i == 2)
					button.text = "Upgrade";
				button.percentWidth = 100;
				var equipmentPos = equipments.length;
				var buttonId = i;

				button.onClick = function(e) {
					ClickedEquipmentViewMainAction(equipmentPos, buttonId);
				};
				// button.onClick = function(e) => {ClickedEquipmentViewMainAction(equipmentPos;)};
				//	ClickedEquipmentViewMainAction(equipmentPos);
				buttonsAct[i] = button;

				viewParent.addComponent(button);
			}

			var ev:EquipmentView = {
				name: name,
				parent: viewParent,
				values: [],
				actionButtons: buttonsAct,
				rightLabelBox: rightLabelBox
			};
			equipTabChild.addComponent(viewParent);
			equipments.push(ev);
		}
		var i = 0;
		while (equipments.length > i) {
			equipments[i].parent.hidden = i >= amount;
			i++;
		}
		// for (var i in 0...equipments.length){
		// }
	}

	public function ClickedEquipmentViewMainAction(equipmentPos:Int, actionId:Int) {
		if (equipmentMainAction != null) {
			this.equipmentMainAction(equipmentPos, actionId);
		}
	}

	public function FeedEquipmentBase(pos:Int, name:String, equipped:Bool, rarity = 0, numberOfValues:Int = -1, unequipable = false, firstTimeSee = false,
			upgradeVisible = false, upgradable = false, cost = 0, sellGain = 0, upgradeLabel = "Upgrade", upgradeCurrencyLabel = "Lagrima",
			equippedInAnySet = false) {
		equipments[pos].parent.hidden = false;
		equipments[pos].name.text = name;
		equipments[pos].rightLabelBox.hidden = firstTimeSee == false;

		if (upgradeVisible) {}
		equipments[pos].actionButtons[2].hidden = !upgradeVisible;
		equipments[pos].actionButtons[2].disabled = !upgradable;

		var color = "#000000";
		if (rarity == 1) {
			color = "#002299";
		}
		if (Toolkit.theme == "dark") {
			color = "#EEEEEE";
			if (rarity == 1) {
				color = "#88AAFF";
			}
		}

		equipments[pos].name.color = color;
		if (equipped) {
			equipments[pos].actionButtons[0].text = "Unequip";
			equipments[pos].actionButtons[0].hidden = unequipable;
			equipments[pos].parent.borderSize = 2;
			equipments[pos].parent.backgroundColor = "#FAEBD7";
			if (Toolkit.theme == "dark") {
				equipments[pos].parent.backgroundColor = "#9C6113";
			}
		} else {
			equipments[pos].actionButtons[0].hidden = false;
			equipments[pos].actionButtons[0].text = "Equip";
			equipments[pos].parent.borderSize = 1;
			equipments[pos].parent.backgroundColor = "white";
			if (Toolkit.theme == "dark") {
				equipments[pos].parent.backgroundColor = "black";
			}
		}
		equipments[pos].actionButtons[1].hidden = equippedInAnySet == true;
		equipments[pos].actionButtons[1].text = "Sell\n" + sellGain + " Lagrima";
		equipments[pos].actionButtons[2].text = '$upgradeLabel\n-$cost $upgradeCurrencyLabel';
		while (equipments[pos].values.length < numberOfValues) {
			var vv = CreateValueView(equipments[pos].parent, false, "Attr");
			equipments[pos].values.push(vv);
		}
	}

	public function HideEquipmentView(pos:Int) {
		equipments[pos].parent.hidden = true;
	}

	public function FinishFeedingEquipmentValue(pos, vid) {
		for (i in vid...equipments[pos].values.length) {
			equipments[pos].values[i].parent.hidden = true;
		}
	}

	public function FeedEquipmentSeparation(pos:Int, valuePos:Int) {
		equipments[pos].values[valuePos].parent.height = 35;
	}

	public function FeedBuffView(actorView:ActorView, buffPos:Int, text:String, buffId:String) {
		while (actorView.buffs.length <= buffPos) {
			var parent = new HBox();
			parent.height = 20;
			var l = new Label();
			parent.addComponent(l);
			actorView.buffParent.addComponent(parent);
			var buffV:BuffView = {
				labelText: l,
				parent: parent,
				buffId: null
			};
			actorView.buffs.push(buffV);
			addHover(parent, (state, component) -> {
				buffButtonHover(buffV, state);
			});
		}
		actorView.buffs[buffPos].labelText.text = text;
		actorView.buffs[buffPos].buffId = buffId;
		actorView.buffs[buffPos].parent.hidden = false;
	}

	public function FinishFeedBuffInfo(actorView:ActorView, buffPos:Int) {
		for (i in buffPos...actorView.buffs.length) {
			actorView.buffs[i].parent.hidden = true;
		}
	}

	public function FeedRegionBonusView(index:Int, areaName:String, level:Int) {
		var parent = charaTab_RegionElements;
		var cc = parent.childComponents;

		while (charaTab_bonusesView.length <= index) {
			var b = new Box();
			var l = new Label();
			l.verticalAlign = "center";
			// l.horizontalAlign = "center";
			b.width = 140;
			b.height = 18;
			l.text = "Something";
			b.addComponent(l);
			parent.addComponent(b);

			var regionV:BonusView = {
				labelText: l,
				parent: b
			}
			charaTab_bonusesView.push(regionV);
		}
		charaTab_bonusesView[index].labelText.text = '$areaName Lv. $level';
	}

	public function FeedEquipmentValue(pos:Int, valuePos:Int, valueName:String, value:Int, hoverText:String, percent = false, valueString:String = null,
			separationNext = false) {
		while (equipments[pos].values.length <= valuePos) {
			var vv = CreateValueView(equipments[pos].parent, false, "Attr");
			vv.parent.marginBottom = 30;
			vv.parent.paddingBottom = 30;
			// vv.parent.height = 40;
			addDefaultHover(vv.parent);
			equipments[pos].values.push(vv);
		}
		if (separationNext)
			equipments[pos].values[valuePos].parent.paddingBottom = 30;
		updateDefaultHoverText(equipments[pos].values[valuePos].parent, hoverText);
		UpdateValues(equipments[pos].values[valuePos], value, -1, valueName, percent, valueString);
		equipments[pos].values[valuePos].parent.hidden = false;
	}

	public function AnimateButtonPress(key) {
		var comp = buttonMap[key];
		var f = new AnimationKeyFrame();
		// f.time = 0;

		f.directives = [];
		var frames = new AnimationKeyFrames("press", [f]);

		var a = new Animation(comp);

		buttonMap[key].componentAnimation = a;
	}

	public function ShowMessage(title, message) {
		Screen.instance.messageBox(message, title, MessageBoxType.TYPE_INFO, true, function(button) {});
	}

	public function GetButton(id):Button {
		return buttonMap[id];
	}

	public function AddButton(id:String, label:String, onClick, warningMessage = null, position = -1, secondArea = false) {
		var button = new Button();

		button.text = label;
		button.repeater = true;
		button.repeatInterval = 300;
		button.width = 180;
		button.height = 40;

		// button.onClick = onClick;
		var paren = buttonBox;
		if (secondArea) {
			paren = mainComponentB;
		}
		if (position == -1)
			paren.addComponent(button);
		else
			paren.addComponentAt(button, position);

		if (warningMessage == null) {
			button.onClick = onClick;
		} else {
			button.onClick = function whatever(e) {
				// trace("lol");
				Screen.instance.messageBox(warningMessage, label, MessageBoxType.TYPE_QUESTION, true, function(button) {
					// trace(button);

					if (button.toString().indexOf("yes") >= 0) {
						onClick(null);
					}
					// trace("call back!");
				});
			};
		}
		buttonMap[id] = button;
		// button.hidden = true;
	}

	public function ButtonVisibility(id:String, visible:Bool) {
		var b = buttonMap[id];
		// b.allowInteraction = visible;
		if (b.hidden == true && visible == true) {
			b.fadeIn();
		}
		b.hidden = !visible;
	}

	public function ButtonLabel(id:String, label:String) {
		var b = buttonMap[id];
		var lab = cast(b.getComponentAt(0), Label);
		if (lab != null)
			lab.htmlText = label;
	}

	public function ButtonAttackColor(id:String) {
		var b = buttonMap[id];
		b.backgroundColor = "#FF6666";
		if (Toolkit.theme == 'dark') {
			b.backgroundColor = "#990000";
		}
	}

	public function ButtonNormalColor(id:String) {
		var b = buttonMap[id];
		b.backgroundColor = "#EEEEFF";
		if (Toolkit.theme == 'dark') {
			b.backgroundColor = "#444444";
		}
	}

	public function ButtonEnabled(id:String, enabled:Bool) {
		var b = buttonMap[id];
		// b.allowInteraction = visible;
		b.disabled = !enabled;
	}

	public function UpdateVisibility(actorView:ActorView, visibility) {
		actorView.parent.hidden = !visibility;
	}

	public function UpdateVisibilityOfValueView(valueView:ValueView, visibility) {
		valueView.parent.hidden = !visibility;
	}

	public function UpdateValues(res:ValueView, current:Int, max:Int, label:String = null, percent = false, valueAsString:String = null,
			description:String = null) {
		res.parent.hidden = false;
		if (description != null)
			updateDefaultHoverText(res.parent, description);
		if (label != null) {
			if (res.labelText != null)
				res.labelText.text = label;
		}
		res.parent.hidden = current >= 0 == false;
		if (valueAsString == null) {
			if (max > 0) {
				res.bar.pos = current * 100 / max;
				res.centeredText.text = current + " / " + max;
			} else {
				if (percent)
					res.centeredText.text = current + "%";
				else
					res.centeredText.text = current + "";
			}
		} else {
			res.centeredText.text = valueAsString;
		}
	}

	public function IsTabSelected(tab:Component):Bool {
		return tabMaster.selectedPage == tab;
	}

	function CreateActorViewComplete(name:String, parent:Component):ActorViewComplete {
		var box:VBox = new VBox();
		box.width = 240;
		parent.addComponent(box);

		var header = new Box();
		header.percentWidth = 100;
		header.height = 20;
		box.addComponent(header);

		var label:Label = new Label();
		label.text = name;
		// label.height = 20;
		label.verticalAlign = "center";

		var rightLabel:Label = new Label();
		rightLabel.styleString = "font-weight: bold; font-size: 16px;";
		rightLabel.horizontalAlign = "right";

		header.addComponent(rightLabel);
		header.addComponent(label);

		return {
			name: label,
			valueViews: new Array<ValueView>(),
			parent: box
		};
	}

	function GetActorView(name:String, parent:Component):ActorView {
		var box:VBox = new VBox();

		addHoverClasses(box);
		// box.addClass('button');
		box.width = 180;
		parent.addComponent(box);

		var face = new Image();
		face.scaleMode = FIT_HEIGHT;
		var res = face.resource;
		face.height = 64;
		face.resource = "graphics/heroicon.png";
		face.width = 64;
		face.horizontalAlign = "center";
		face.color = "#00AAAA";
		// face.opacity = 0.5;
		box.addComponent(face);

		var header = new Box();
		header.percentWidth = 100;
		header.height = 20;
		box.addComponent(header);

		var label:Label = new Label();
		label.text = name;
		// label.height = 20;
		label.verticalAlign = "center";

		// var rightLabel:Label = new Label();
		// rightLabel.styleString = "font-weight: bold; font-size: 16px;";
		// rightLabel.horizontalAlign = "right";
		var buffBox = new HBox();
		buffBox.horizontalAlign = "right";
		buffBox.height = 20;

		header.addComponent(buffBox);
		header.addComponent(label);

		var lifeView:ValueView = null;
		lifeView = CreateValueView(box, true, "Life: ", "#FF8888");

		return {
			name: label,
			life: lifeView,
			buffs: new Array<BuffView>(),
			attack: CreateValueView(box, false, "Attack: "),
			parent: box,
			mp: CreateValueView(box, true, "MP: ", "#CC88FF"),
			defaultName: name,
			buffParent: buffBox,
			portrait: face
		};
	}

	function CreateDropDownView(parent:Component, label:String):DropDownView {
		var boxh = new Box();
		boxh.width = 180;
		boxh.height = 30;
		parent.addComponent(boxh);

		var addLabel = label != null && label != "";
		var nameLabel = null;
		if (addLabel) {
			var l = new Label();
			l.text = label;
			l.percentHeight = 100;

			l.verticalAlign = "center";
			l.paddingTop = 5;
			boxh.addComponent(l);

			nameLabel = l;
		}

		var dd = new DropDown();
		dd.width = 120;

		dd.dataSource = new ArrayDataSource<String>();
		dd.horizontalAlign = "right";
		dd.verticalAlign = "center";
		boxh.addComponent(dd);
		return {parent: boxh, dropdown: dd, labelText: nameLabel};
	}

	function CreateValueView(parent:Component, withBar:Bool, label:String, fullWidth = 180, barWidth = 120, barColor:String = "#CCCCDD",
			extraHeight = 0):ValueView {
		var color:haxe.ui.util.Color = barColor;
		if (Toolkit.theme == "dark") {
			color.r -= 128;
			color.g -= 128;
			color.b -= 128;
		}
		var boxh = new Box();
		addHoverClasses(boxh);
		boxh.width = fullWidth;
		boxh.height = 20 + extraHeight;

		parent.addComponent(boxh);

		var addLabel = label != null && label != "";
		var nameLabel = null;
		if (addLabel) {
			var l = new Label();
			l.text = label;
			l.top = 20;
			l.paddingTop = 2;
			// l.percentHeight = 100;

			// l.verticalAlign = "center";
			boxh.addComponent(l);

			nameLabel = l;
		}

		var progress:HorizontalProgress = new HorizontalProgress();
		boxh.addComponent(progress);
		addHoverClasses(progress);

		progress.width = barWidth;
		progress.height = 20;
		if (addLabel)
			progress.horizontalAlign = "right";
		if (withBar) {
			progress.getComponentAt(0).backgroundColor = color;
			progress.pos = 100;
		} else {
			progress.borderSize = 0;
		}

		// progress.getComponentAt(0).height = progress.height - 4;

		var l = new Label();
		l.text = "32/32";
		l.textAlign = "center";
		l.styleString = "font-size:14px; text-align: center;
			vertical-align: center; width:100%;";
		l.verticalAlign = "center";
		progress.addComponent(l);
		return {
			centeredText: l,
			bar: progress,
			parent: boxh,
			labelText: nameLabel
		};
	}
}

typedef Controls = {};
typedef AreaView = {};

typedef BonusView = {
	var labelText:Label;
	var parent:Component;
};

typedef BuffView = {
	var labelText:Label;
	var parent:Component;
	var buffId:String;
};

typedef ValueView = {
	var centeredText:Label;
	var labelText:Label;
	var bar:HorizontalProgress;
	var parent:Component;
};

typedef DropDownView = {
	var labelText:Label;
	var dropdown:DropDown;
	var parent:Component;
};

typedef ActorView = {
	var name:Label;
	var buffs:Array<BuffView>;
	var buffParent:Component;
	var life:ValueView;
	var mp:ValueView;
	var attack:ValueView;
	var parent:Component;
	var defaultName:String;
	var portrait:Image;
};

typedef ActorViewComplete = {
	var name:Label;
	var parent:Component;
	var valueViews:Array<ValueView>;
}

typedef EquipmentView = {
	var name:Label;
	var values:Array<ValueView>;
	var parent:Component;
	var actionButtons:Vector<Button>;
	var rightLabelBox:Component;
	// var actionButton:Button;
	// var actionButton2:Button;
};

typedef CutsceneStartView = {
	var startButton:Button;
	var resumeButton:Button;
	var parent:Component;
	var title:Label;
	var newLabel:Label;
}

typedef MessageView = {
	var speakerImage:Image;
	var speakerText:Label;
	var message:Label;
	var parent:Component;
}

class StoryDialog extends Dialog {
	public var messages = new Array<MessageView>();
	public var advanceButton:Button;
	public var skipButton:Button;
	public var watchLaterButton:Button;
	public var messageParent:Component;
	public var scroll:ScrollView;

	public function new() {
		super();

		title = "";
		width = 400;
		this.percentHeight = 80;

		messageParent = new VBox();
		// messageParent.percentWidth = 100;
		messageParent.width = width - 30;
		messageParent.paddingBottom = 20;

		scroll = new ScrollView();
		scroll.addComponent(messageParent);
		scroll.percentHeight = 90;
		scroll.width = width - 10;
		scroll.percentContentWidth = 100;
		scroll.horizontalAlign = "center";
		addComponent(scroll);

		{
			var hbox = new ContinuousHBox();
			hbox.percentWidth = 100;
			hbox.percentHeight = 10;
			this.addComponent(hbox);
			for (j in 0...3) {
				var button = new Button();
				button.horizontalAlign = "right";
				button.percentWidth = 33;
				button.percentHeight = 100;
				button.text = ">";
				button.verticalAlign = "bottom";
				if (j == 0) {
					button.text = "Skip";
					skipButton = button;
				}
				if (j == 1) {
					button.text = "Watch Later";
					watchLaterButton = button;
				}
				if (j == 2) {
					advanceButton = button;
				}
				// addComponent(vbox);
				hbox.addComponent(button);
			}
		}

		// buttons = DialogButton.CANCEL | "Custom Button";
	}
}

class UIElementWrapper {
	public var component:Component;
	public var baseText:String;
	public var desiredPosition:Int;
	public var parent:Component;

	// for tab only
	public var tabVisible = false;

	public function new(component, parent) {
		this.component = component;
		this.baseText = component.text;
		this.desiredPosition = parent.getComponentIndex(component);
		this.parent = parent;
	}
}
