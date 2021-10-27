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

	public static final equipmentAction_DiscardBad = 2;

	public var heroView:ActorView;
	public var enemyView:ActorView;

	public var level:ValueView;
	public var xpBar:ValueView;
	public var speedView:ValueView;
	public var defView:ValueView;
	public var mDefView:ValueView;

	public var enemyToAdvance:ValueView;
	public var areaLabel:ValueView;
	public var mainComponent:Component;
	public var mainComponentB:Component;
	public var equipTab:Component;
	public var storyTab:Component;
	public var logText:Label;
	public var areaNouns = 'forest@meadow@cave@mountain@road@temple@ruin@bridge'.split('@');
	public var prefix = 'normal@fire@ice@water@thunder@wind@earth@poison@grass'.split('@');
	public var enemy1 = 'slime@orc@goblin@bat@eagle@rat@lizard@bug@skeleton@horse@wolf@dog'.split('@');

	public var equipmentMainAction:(Int, Int) -> Void;
	public var storyMainAction:(Int, Int) -> Void;

	var buttonBox:Component;
	var buttonMap = new Map<String, Button>();
	var equipments = new Array<EquipmentView>();
	var cutsceneStartViews = new Array<CutsceneStartView>(); 
	var saveDataDownload:Label;
	var amountOfStoryMessagesShown = 0;
	var storyDialog : StoryDialog;
	public var storyDialogActive = false;


	public function LatestMessageUpdate(message : String, speaker: String, messagePos : Int){
		if(messagePos >= amountOfStoryMessagesShown){
			amountOfStoryMessagesShown = messagePos + 1;
			storyDialog.mainText.text += '$speaker: $message\n';
		}
	}

	public function HideStory(){
		storyDialog.hide();
		storyDialogActive = false;
		this.amountOfStoryMessagesShown = 0;
	}

	public function StartStory(){
		storyDialog.showDialog();
		storyDialogActive = true;
		storyDialog.mainText.text = "";
	}

	public function StoryButtonAmount(amount : Int){
		while(cutsceneStartViews.length < amount){
			var parent = new Box();
			var startB = new Button(); startB.text = "Watch";
			var resumeB = new Button(); resumeB.text = "Resume";
			resumeB.hidden = true;
			var title = new Label();
			title.text = "dummy";
			title.verticalAlign = "center";
			var hBox = new HBox();
			hBox.horizontalAlign = "right";
			hBox.percentHeight = 100;
			hBox.addComponent(startB);
			hBox.addComponent(resumeB);
			parent.addComponent(title);
			parent.addComponent(hBox);
			parent.width = 200;
			parent.height = 50;
			startB.verticalAlign = "center";
			resumeB.verticalAlign = "center";
			
			cutsceneStartViews.push({startButton: startB, resumeButton: resumeB, title: title});
			var pos = cutsceneStartViews.length-1;
			startB.onClick = (e) ->{
				storyMainAction(View.storyAction_Start, pos);
			}
			resumeB.onClick = (e) ->{
				storyMainAction(View.storyAction_Continue, pos);
			}

			storyTab.addComponent(parent);
		}
	}

	public function StoryButtonFeed(buttonPos : Int, label : String, cleared : Bool){
		cutsceneStartViews[buttonPos].title.text = label;
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
				title.htmlText = "Alpha 0.06B. <a href='https://github.com/Pidroh/HaxeRPGUtilities/wiki' target='_blank'>__Road Map__</a>              A prototype for the progression mechanics in <a href='https://store.steampowered.com/app/1638970/Brave_Ball/'  target='_blank'>Brave Ball</a>.     <a href='https://discord.com/invite/AtGrxpM'  target='_blank'>   Discord Channel   </a>";
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

		var tabMaster = new TabView();
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
		var box:VBox = new VBox();
		battleParent.addComponent(box);

		buttonBox = CreateContainer(battleParent, true);
		// buttonBox.percentHeight = 100;
		// boxParent.addComponent(buttonBox);

		var scroll = CreateScrollable(battleParent);

		scroll.width = 200;
		scroll.percentHeight = 100;
		var logContainer = CreateContainer(scroll, true);
		var log = new Label();
		logText = log;
		logContainer.addComponent(log);

		var areaContainer = CreateContainer(box, true);
		areaLabel = CreateValueView(areaContainer, false, "Area: ");
		enemyToAdvance = CreateValueView(areaContainer, true, "Progress: ");

		var levelContainer = CreateContainer(box, true);
		level = CreateValueView(levelContainer, false, "Level: ");
		xpBar = CreateValueView(levelContainer, true, "XP: ");
		speedView = CreateValueView(levelContainer, false, "Speed: ");
		defView = CreateValueView(levelContainer, false, "Def: ");
		mDefView = CreateValueView(levelContainer, false, "mDef: ");

		var battleView = CreateContainer(box, false);
		battleView.width = 400;
		heroView = GetActorView("You", battleView);
		enemyView = GetActorView("Enemy", battleView);



		{
			equipTab = new ContinuousHBox();
			// equipTab.percentWidth = 100;
			equipTab.width = 600;
			// equipTab.height = 300;
			var buttonDiscardBad = new Button();
			buttonDiscardBad.text = "Discard worse equipment";
			buttonDiscardBad.onClick = event -> {
				equipmentMainAction(-1, View.equipmentAction_DiscardBad);
			}
			equipTab.addComponent(buttonDiscardBad);


			equipTab.text = "Equipment";
			var scroll = CreateScrollable(tabMaster);
			scroll.height = 300;

			scroll.text = "Equipment";
			scroll.addComponent(equipTab);
			// scroll.percentWidth = 100;
			scroll.width = 640;
			// tabMaster.addComponent(equipTab);
		}
		{
			var storyTab = new ContinuousHBox();
			storyTab.width = 600;
			storyTab.height = 300;
			storyTab.text = "Story";
			tabMaster.addComponent(storyTab);
			this.storyTab = storyTab;

			//var messageLabel = new Label();
			//messageLabel.percentWidth = 100;
			//messageLabel.textAlign = "left";
			//storyTab.addComponent(messageLabel);
			//messageLabel.text = "Biahdfsauidhsaiudhsa.\nDIOASdjasiodjaso\nFred: I am Fred.";

		}
		
		storyDialog = new StoryDialog();
		storyDialog.advanceButton.onClick = (e)->{
			storyMainAction(View.storyAction_AdvanceMessage, 0);
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

	public function CreateScrollable(parent:Component) {
		var container:Component;
		container = new ScrollView();
		parent.addComponent(container);
		return container;
	}

	public function CreateContainer(parent:Component, vertical) {
		var container:Component;

		if (vertical == false)
			container = new HBox();
		else
			container = new VBox();
		// container.percentWidth = 100;
		// container.borderRadius = 1;
		container.borderColor = "#333333";
		container.borderSize = 1;
		container.padding = 15;
		parent.addComponent(container);
		return container;
	}

	public function AddEventText(text:String) {
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
			equipTab.addComponent(viewParent);
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

	public function FeedEquipmentBase(pos:Int, name:String, equipped:Bool, numberOfValues:Int = -1) {
		equipments[pos].parent.hidden = false;
		equipments[pos].name.text = name;
		if (equipped) {
			equipments[pos].actionButtons[0].text = "Unequip";
			equipments[pos].parent.borderSize = 2;
		} else {
			equipments[pos].actionButtons[0].text = "Equip";
			equipments[pos].parent.borderSize = 1;
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

	public function FeedEquipmentValue(pos:Int, valuePos:Int, valueName:String, value:Int) {
		while (equipments[pos].values.length <= valuePos) {
			var vv = CreateValueView(equipments[pos].parent, false, "Attr");
			equipments[pos].values.push(vv);
		}
		UpdateValues(equipments[pos].values[valuePos], value, -1, valueName);
	}

	public function AddButton(id:String, label:String, onClick, warningMessage = null) {
		var button = new Button();
		button.text = label;
		button.repeater = true;
		button.repeatInterval = 300;

		// button.onClick = onClick;
		if (warningMessage == null) {
			buttonBox.addComponent(button);
			button.onClick = onClick;
		} else {
			mainComponentB.addComponent(button);
			button.onClick = function whatever(e) {
				trace("lol");
				Screen.instance.messageBox(warningMessage, label, MessageBoxType.TYPE_QUESTION, true, function(button) {
					trace(button);
					if (button.toString().indexOf("yes") >= 0) {
						onClick(null);
					}
					trace("call back!");
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
		b.text = label;
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

	public function UpdateValues(res:ValueView, current:Int, max:Int, label:String = null) {
		if (label != null) {
			res.labelText.text = label;
		}
		if (max > 0) {
			res.bar.pos = current * 100 / max;
			res.centeredText.text = current + " / " + max;
		} else {
			res.centeredText.text = current + "";
		}
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
	var startButton : Button;
	var resumeButton : Button;
	var title : Label;
}

class StoryDialog extends Dialog{
	public var mainText : Label;
	public var advanceButton : Button;
	public function new() {
        super();
        title = "Entry Form";
		width = 300;
		this.percentHeight = 80;
		var scroll = new Scroll(); 
		scroll.percentHeight = 90;
		scroll.percentWidth = 100;
		addComponent(scroll);

		//var vbox = new VBox();
		//vbox.percentWidth = 100;

		mainText = new Label();
		mainText.text = "";
		mainText.percentWidth = 100;
		scroll.addComponent(mainText);
		//vbox.addComponent(mainText);
		
		advanceButton = new Button();
		advanceButton.horizontalAlign = "right";
		advanceButton.percentWidth = 100;
		advanceButton.percentHeight = 10;
		advanceButton.text = "=";
		advanceButton.verticalAlign = "bottom";
		//addComponent(vbox);
		this.addComponent(advanceButton);
		

		
        //buttons = DialogButton.CANCEL | "Custom Button";
    }
}