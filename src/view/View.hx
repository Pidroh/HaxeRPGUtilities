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
	public var heroView:ActorView;
	public var enemyView:ActorView;

	public var level:ValueView;
	public var xpBar:ValueView;
	public var enemyToAdvance:ValueView;
	public var areaLabel:ValueView;
	public var mainComponent:Component;
	public var logText:Label;

	var buttonBox : Component;
	var buttonMap = new Map<String, Button>();

	public function new() {
		var boxParent = new HBox();
		mainComponent = boxParent;
		//boxParent.horizontalAlign = "center";
		boxParent.padding = 40;

		var box:VBox = new VBox();
		boxParent.addComponent(box);


		buttonBox = CreateContainer(boxParent, true);
		//buttonBox.percentHeight = 100;
		//boxParent.addComponent(buttonBox);

		

		var logContainer = CreateContainer(boxParent, true);
		var log = new Label();
		logText = log;
		logContainer.addComponent(log);


		var areaContainer = CreateContainer(box, true);
		areaLabel = CreateValueView(areaContainer, false, "Area: ");
		enemyToAdvance = CreateValueView(areaContainer, true, "Progress: ");

		var levelContainer = CreateContainer(box, true);
		level = CreateValueView(levelContainer, false, "Level: ");
		xpBar = CreateValueView(levelContainer, true, "XP: ");

		var battleView = CreateContainer(box, false);
		heroView = GetActorView("You", battleView);
		enemyView = GetActorView("Enemy", battleView);
	}

	public function CreateContainer(parent:Component, vertical) {
		var container:Component;

		
		
		if (vertical == false)
			container = new HBox();
		else
			container = new VBox();
		//container.percentWidth = 100;
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

	public function AddButton(id:String, label:String, onClick, warningMessage = null) {
		var button = new Button();
		button.text = label;
		button.repeater = true;
		button.repeatInterval = 300;
		
		
		// button.onClick = onClick;
		if (warningMessage == null){
			buttonBox.addComponent(button);
			button.onClick = onClick;
		}
			
		else {
			
			mainComponent.addComponent(button);
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

	public function UpdateValues(res:ValueView, current:Int, max:Int) {
		if (max > 0) {
			res.bar.pos = current * 100 / max;
			res.centeredText.text = current + " / " + max;
		} else {
			res.centeredText.text = current + "";
		}
	}

	function GetActorView(name:String, parent:Component):ActorView {
		var box:VBox = new VBox();
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
		if (addLabel) {
			var l:Label = new Label();
			l.text = label;
			// l.percentHeight = 100;

			l.verticalAlign = "center";
			boxh.addComponent(l);
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
		return {centeredText: l, bar: progress, parent: boxh};
	}
}

typedef Controls = {};
typedef AreaView = {};

typedef ValueView = {
	var centeredText:Label;
	var bar:HorizontalProgress;
	var parent:Component;
};

typedef ActorView = {
	var name:Label;
	var life:ValueView;
	var attack:ValueView;
	var parent:Component;
};
