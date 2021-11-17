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

	public static final equipmentAction_DiscardBad = 2;
	public static final equipmentAction_ChangeTypeToView = 3;

	public var heroView:ActorView;
	public var enemyView:ActorView;

	public var level:ValueView;
	public var xpBar:ValueView;
	public var speedView:ValueView;
	public var defView:ValueView;
	public var mDefView:ValueView;

	public var enemyToAdvance:ValueView;
	public var areaLabel:ValueView;
	public var regionLabel:ValueView;
	public var mainComponent:Component;
	public var mainComponentB:Component;
	public var equipTabChild:Component;
	public var storyTab:UIElementWrapper;
	public var equipTab:UIElementWrapper;
	public var developTab:UIElementWrapper;
	public var tabMaster:TabView;
	public var logText:Label;
	public var logTextBattle:Label;
	public var areaNouns = 'forest@meadow@cave@mountain@road@temple@ruin@bridge'.split('@');
	public var prefix = 'normal@fire@ice@water@thunder@wind@earth@poison@grass'.split('@');
	public var enemy1 = 'slime@orc@goblin@bat@eagle@rat@lizard@bug@skeleton@horse@wolf@dog'.split('@');

	public var equipmentMainAction:(Int, Int) -> Void;
	public var storyMainAction:(Int, Int) -> Void;
	public var regionChangeAction:(Int) -> Void;

	public var areaContainer:Component;
	public var regionButtonParent:Component;
	public var levelContainer:Component;
	public var battleView:Component;

	var buttonBox:Component;
	var buttonMap = new Map<String, Button>();

	var equipments = new Array<EquipmentView>();

	public var equipmentTypeSelectionTabbar:TabBar;
	public var equipmentTypeNames:Array<String>;

	var saveDataDownload:Label;

	public var storyDialogActive = false;
	public var storyDialogUtilityFlag = false;

	var cutsceneStartViews = new Array<CutsceneStartView>();

	public var amountOfStoryMessagesShown = 0;
	public var storyDialog:StoryDialog;

	public function Update() {
		// equipTabChild.width = equipTabChild.parentComponent.width - 40;
		equipTabChild.width = Screen.instance.width - 40 - 60;
	}

	public static function TabBarAlert(tabBar:TabBar, alert:Array<Bool>, names:Array<String>) {
		for (i in 0...alert.length) {
			if (alert[i])
				tabBar.getComponentAt(i).text = names[i] + " (!)";
			else
				tabBar.getComponentAt(i).text = names[i];
		}
	}

	public function LatestMessageUpdate(message:String, speaker:String, imageFile:String, messagePos:Int) {
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

	public function new() {
		{
			var boxParentP = new Box();
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
				title.width = 400;
				title.horizontalAlign = "right";
				title.textAlign = "right";
				// title.paddingRight = 20;
				title.paddingLeft = 20;
				title.paddingTop = 50;
				title.height = 20;

				// title.text = "Import save data";
				title.htmlText = "Import Save: <input id='import__' type='file'></input>";

				boxParentP.addComponent(title);
			}

			{
				var title = new Label();
				title.htmlText = "Alpha 0.08C. <a href='https://github.com/Pidroh/HaxeRPGUtilities/wiki' target='_blank'>__Road Map__</a>              A prototype for the progression mechanics in <a href='https://store.steampowered.com/app/1638970/Brave_Ball/'  target='_blank'>Brave Ball</a>.     <a href='https://discord.com/invite/AtGrxpM'  target='_blank'>   Discord Channel   </a>";
				title.percentWidth = 100;
				title.textAlign = "right";
				title.paddingRight = 20;
				title.paddingLeft = 20;
				title.paddingTop = 10;

				boxParentP.addComponent(title);
			}

			{
				var title = new Label();
				title.percentWidth = 100;
				title.textAlign = "right";
				title.paddingRight = 20;
				title.paddingLeft = 20;
				title.paddingTop = 30;
				title.height = 10;

				title.text = "Export save data";
				saveDataDownload = title;

				boxParentP.addComponent(title);
			}
		}

		tabMaster = new TabView();
		tabMaster.percentWidth = 100;
		mainComponent.addComponent(tabMaster);
		tabMaster.percentHeight = 90;
		tabMaster.verticalAlign = "bottom";

		var battleParent = new HBox();
		battleParent.percentHeight = 100;
		// mainComponent.addComponent(boxParent);
		tabMaster.addComponent(battleParent);
		battleParent.text = "Battle";
		mainComponentB = battleParent;
		// boxParent.horizontalAlign = "center";
		battleParent.paddingLeft = 40;
		battleParent.paddingTop = 10;
		var verticalBox = new Box();
		var hgl = new HorizontalGridLayout();
		hgl.rows = 3;
		verticalBox.layout = hgl;
		verticalBox.percentHeight = 100;
		// var verticalBox = new Grid();
		// verticalBox.columns= 1;

		battleParent.addComponent(verticalBox);

		buttonBox = CreateContainer(battleParent, true);
		// buttonBox.percentHeight = 100;
		// boxParent.addComponent(buttonBox);

		{
			var box = new Box();
			box.width = 250;
			box.percentHeight = 100;
			battleParent.addComponent(box);

			{
				var scroll = CreateScrollable(box);
				scroll.width = 250;
				scroll.percentHeight = 60; // TODO change this to 60 and add new log below it  X_X
				var logContainer = CreateContainer(scroll, true);

				var log = new Label();
				logTextBattle = log;
				logContainer.addComponent(log);
				log.width = 190;
				log.horizontalAlign = "center";
				logContainer.horizontalAlign = "center";
			}
			{
				var scroll = CreateScrollable(box);
				scroll.width = 250;
				scroll.percentHeight = 40;
				var logContainer = CreateContainer(scroll, true);
				scroll.verticalAlign = "bottom";

				var log = new Label();
				logText = log; // make this battle log
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
		// areaContainer.percentHeight = 60;

		// areaLabel = CreateValueView(areaContainer, false, "Area: ");
		/*var ddv = CreateDropDownView(areaContainer, "Location: ");
			ddv.dropdown.onChange = event -> {
				var region = ddv.dropdown.selectedIndex;
				regionChangeAction(region);
			};
			dropDownRegion = ddv;
		 */
		{
			var container = new VBox();
			areaContainer.addComponent(container);
			regionLabel = CreateValueView(container, false, "Region: ");
			areaLabel = CreateValueView(container, false, "Area: ");
			enemyToAdvance = CreateValueView(container, true, "Progress: ");
		}
		{
			var container = new ContinuousHBox();
			areaContainer.addComponent(container);
			regionButtonParent = container;
		}

		levelContainer = CreateContainer(verticalBox, true);
		level = CreateValueView(levelContainer, false, "Level: ");
		xpBar = CreateValueView(levelContainer, true, "XP: ");
		speedView = CreateValueView(levelContainer, false, "Speed: ");
		defView = CreateValueView(levelContainer, false, "Def: ");
		mDefView = CreateValueView(levelContainer, false, "mDef: ");

		battleView = CreateContainer(verticalBox, false);

		battleView.width = 400;
		heroView = GetActorView("You", battleView);
		enemyView = GetActorView("Enemy", battleView);

		{
			equipTabChild = new ContinuousHBox();
			var tabBar = new TabBar();
			tabBar.percentWidth = 100;
			equipmentTypeSelectionTabbar = tabBar;
			equipTabChild.addComponent(tabBar);
			var buttonDiscardBad = new Button();
			buttonDiscardBad.text = "Discard worse equipment";
			buttonDiscardBad.onClick = event -> {
				equipmentMainAction(-1, View.equipmentAction_DiscardBad);
			}
			equipTabChild.addComponent(buttonDiscardBad);

			var scroll = CreateScrollable(null);

			scroll.height = 300;
			scroll.text = "Equipment";
			scroll.addComponent(equipTabChild);
			scroll.paddingLeft = 40;
			scroll.paddingTop = 10;
			// scroll.width = 640;
			scroll.percentWidth = 100;
			// scroll.width = Screen.instance.width;
			scroll.percentHeight = 100;

			equipTab = new UIElementWrapper(scroll, tabMaster);
			equipTab.desiredPosition = 1;
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

	public function GetEquipmentType():Int {
		return equipmentTypeSelectionTabbar.selectedIndex;
	}

	public function FeedEquipmentTypes(types:Array<String>) {
		equipmentTypeNames = types;
		for (type in types) {
			var b = new Button();
			b.text = type;
			equipmentTypeSelectionTabbar.addComponent(b);
		}
	}

	public function FeedDropDownRegion(regionNames, regionAmount, currentRegion) {
		regionLabel.centeredText.text = regionNames[currentRegion];
		var buttonAmount = regionAmount;
		var children = regionButtonParent.childComponents;
		if (children.length < buttonAmount) {
			var b = new Button();
			var regionPos = children.length;
			regionButtonParent.addComponent(b);

			b.onClick = event -> regionChangeAction(regionPos);
			b.width = 100;
		}
		for (i in 0...children.length) {
			var hide = i >= buttonAmount;
			if (currentRegion == i)
				hide = true;
			children[i].hidden = hide;
			if (hide == false) {
				children[i].text = regionNames[i];
			}
		}
	}

	public function FeedSave(saveDataContent:String) {
		// saveDataContent = StringTools.htmlEscape(saveDataContent);
		// saveDataContent = "ssssss";
		saveDataDownload.htmlText = "<a href='data:text/plain;charset=utf-8,";
		saveDataDownload.htmlText += saveDataContent;
		saveDataDownload.htmlText += "' download='savedata.json'>Export save data</a>";

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
			} else {
				if(element.desiredPosition >= 0)
					tabMaster.removePage(element.desiredPosition);

				// tabMaster.removeAllPages();
				element.parent.removeComponent(element.component);
			}
		}
		element.tabVisible = visible;
	}

	public function CreateScrollable(parent:Component) {
		var container:Component;
		container = new ScrollView();
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
		container.borderColor = "#333333";
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
			var name = new Label();
			name.text = "Sword";
			viewParent.addComponent(name);

			var buttonsAct = new Vector<Button>(2);

			for (i in 0...buttonsAct.length) {
				var button = new Button();
				button.text = "Equip";
				if (i == 1)
					button.text = "Discard";
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
				actionButtons: buttonsAct
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

	public function FeedEquipmentBase(pos:Int, name:String, equipped:Bool,rarity = 0, numberOfValues:Int = -1) {
		equipments[pos].parent.hidden = false;
		equipments[pos].name.text = name;
		var color = "#000000";
		if(rarity == 1){
			color = "#002299";
		}
		equipments[pos].name.color = color;
		if (equipped) {
			equipments[pos].actionButtons[0].text = "Unequip";
			equipments[pos].parent.borderSize = 2;
			equipments[pos].parent.backgroundColor = "#FAEBD7";
		} else {
			equipments[pos].actionButtons[0].text = "Equip";
			equipments[pos].parent.borderSize = 1;
			equipments[pos].parent.backgroundColor = "white";
		}
		equipments[pos].actionButtons[1].hidden = equipped == true;
		while (equipments[pos].values.length < numberOfValues) {
			var vv = CreateValueView(equipments[pos].parent, false, "Attr");
			equipments[pos].values.push(vv);
		}
	}

	public function HideEquipmentView(pos:Int) {
		equipments[pos].parent.hidden = true;
	}

	public function FeedEquipmentValue(pos:Int, valuePos:Int, valueName:String, value:Int, percent = false) {
		while (equipments[pos].values.length <= valuePos) {
			var vv = CreateValueView(equipments[pos].parent, false, "Attr");
			equipments[pos].values.push(vv);
		}
		UpdateValues(equipments[pos].values[valuePos], value, -1, valueName, percent);
	}

	public function AddButton(id:String, label:String, onClick, warningMessage = null, position = -1, secondArea = false) {
		var button = new Button();
		button.text = label;
		button.repeater = true;
		button.repeatInterval = 300;

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
		b.hidden = !visible;
	}

	public function ButtonLabel(id:String, label:String) {
		var b = buttonMap[id];
		var lab = cast(b.getComponentAt(0), Label);
		if (lab != null)
			lab.htmlText = label;
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

	public function UpdateValues(res:ValueView, current:Int, max:Int, label:String = null, percent = false) {
		if (label != null) {
			res.labelText.text = label;
		}
		if (max > 0) {
			res.bar.pos = current * 100 / max;
			res.centeredText.text = current + " / " + max;
		} else {
			if (percent)
				res.centeredText.text = current + "%";
			else
				res.centeredText.text = current + "";
		}
	}

	public function IsTabSelected(tab:Component):Bool {
		return tabMaster.selectedPage == tab;
	}

	function GetActorView(name:String, parent:Component):ActorView {
		var box:VBox = new VBox();
		box.width = 180;
		parent.addComponent(box);
		var label:Label = new Label();
		var lifeView:ValueView = null;
		box.addComponent(label);
		label.text = name;
		lifeView = CreateValueView(box, true, "Life: ");

		return {
			name: label,
			life: lifeView,
			attack: CreateValueView(box, false, "Attack: "),
			parent: box
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

	function CreateValueView(parent:Component, withBar:Bool, label:String):ValueView {
		var boxh = new Box();
		boxh.width = 180;
		parent.addComponent(boxh);

		var addLabel = label != null && label != "";
		var nameLabel = null;
		if (addLabel) {
			var l = new Label();
			l.text = label;
			// l.percentHeight = 100;

			l.verticalAlign = "center";
			boxh.addComponent(l);

			nameLabel = l;
		}

		var progress:HorizontalProgress = new HorizontalProgress();
		boxh.addComponent(progress);

		progress.width = 120;
		progress.height = 20;
		if (addLabel)
			progress.horizontalAlign = "right";
		if (withBar) {
			progress.getComponentAt(0).backgroundColor = "#999999";
			progress.pos = 100;
		} else {
			progress.borderSize = 0;
		}

		// progress.getComponentAt(0).height = progress.height - 4;

		var l = new Label();
		l.text = "32/32";
		l.textAlign = "center";
		l.styleString = "font-size:14px; text-align: center;
			vertical-align: middle; width:100%;";
		l.verticalAlign = "middle";
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
	var life:ValueView;
	var attack:ValueView;
	var parent:Component;
};

typedef EquipmentView = {
	var name:Label;
	var values:Array<ValueView>;
	var parent:Component;
	var actionButtons:Vector<Button>;
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
		title = "Entry Form";
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
		scroll.horizontalAlign = "center";
		addComponent(scroll);

		// var vbox = new VBox();
		// vbox.percentWidth = 100;

		// mainText = new Label();
		// mainText.text = "";
		// mainText.percentWidth = 100;
		// scroll.addComponent(mainText);
		// vbox.addComponent(mainText);

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
