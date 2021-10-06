import haxe.ui.styles.animation.util.ColorPropertyDetails;
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

	var buttonBox:Component;
	var buttonMap = new Map<String, Button>();

	public function new() {
		var boxParent = new HBox();
		mainComponent = boxParent;
		boxParent.horizontalAlign = "center";
		boxParent.paddingTop = 20;
		boxParent.width = 100;
		boxParent.height = 800;
		boxParent.percentHeight = 100;
		//boxParent.percentHeight = 100;

		var box:VBox = new VBox();
		boxParent.addComponent(box);
		box.width = 200;

		buttonBox = CreateContainer(boxParent, true);
		buttonBox.width = 100;
		buttonBox.height = 100;
		buttonBox.percentHeight = 100;
		// boxParent.addComponent(buttonBox);

		var logContainer = CreateContainer(boxParent, true, false);
		var log = new Label();
		log.width = 200;
		logContainer.percentHeight = 100;
		logContainer.width = 200;
		// boxParent.addComponent(log);
		logText = log;
		logContainer.addComponent(log);

		var areaContainer = CreateContainer(box, true);
		areaLabel = CreateValueView(areaContainer, false, "Area: ");
		enemyToAdvance = CreateValueView(areaContainer, true, "Progress: ");
		areaContainer.width = 200;

		var levelContainer = CreateContainer(box, true);
		level = CreateValueView(levelContainer, false, "Level: ");
		xpBar = CreateValueView(levelContainer, true, "XP: ");

		var battleView = CreateContainer(box, false);
		heroView = GetActorView("You", battleView);
		enemyView = GetActorView("Enemy", battleView);
	}

	public function CreateContainer(parent:Component, vertical, extendHeight = false) {
		var container:Component;
		if(false){
		//if (extendHeight == true) {
			container = new Box();
			container.percentHeight = 100;
			
		} else {
			if (vertical == false)
				container = new HBox();
			else
				container = new VBox();
		}

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
			return;
		}

		logText.text = text + "\n\n" + logText.text;
	}

	public function AddButton(id:String, label:String, onClick, warningMessage = null) {
		var button = new Button();
		button.text = label;
		button.percentWidth = 100;
		button.height = 30;
		// button.onClick = onClick;
		if (warningMessage == null)
			button.onClick = onClick;
		else {
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
		buttonBox.addComponent(button);
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
		boxh.percentWidth = 100;
		parent.addComponent(boxh);

		var addLabel = label != null && label != "";
		if (addLabel) {
			var l:Label = new Label();
			l.text = label;
			//l.width = 50;
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
