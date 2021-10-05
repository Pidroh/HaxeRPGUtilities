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
	
    public var level : ValueView;
    public var xpBar : ValueView;
	public var enemyToAdvance : ValueView;
	public var areaLabel : ValueView;

	public var mainComponent:Component;

	public function new() {
		var box:VBox = new VBox();
        
		areaLabel = CreateValueView(box, false, "Area: ");
		enemyToAdvance = CreateValueView(box, true, "Progress: ");
		

        level = CreateValueView(box, false, "Level: ");
        xpBar = CreateValueView(box, true, "XP: ");

		

		heroView = GetActorView("You", box);
		enemyView = GetActorView("Enemy", box);
		mainComponent = box;
		box.horizontalAlign = "center";
		box.paddingTop = 20;
	}

	public function AddButton(label:String, onClick){
		var button = new Button();
		button.text = label;
		button.onClick = onClick;
		mainComponent.addComponent(button);
	}

	public function UpdateValues(res : ValueView, current:Int, max: Int){
		if(max > 0){ 
			res.bar.pos = current*100 / max;
			res.centeredText.text = current + " / " + max;
		} else{
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
		

		return {name: label, life: lifeView, attack: CreateValueView(box, false, "Attack: ")};
	}

	function CreateValueView(parent:Component, withBar:Bool, label : String) : ValueView {
		var boxh = new Box();
        boxh.width = 180;
		parent.addComponent(boxh);

        var addLabel = label != null && label != "" ;
        if(addLabel){
            var l:Label = new Label();
            l.text = label;
            //l.percentHeight = 100;
            
            l.verticalAlign = "center";
            boxh.addComponent(l);
        }

        
		var progress:HorizontalProgress = new HorizontalProgress();
		boxh.addComponent(progress);

		progress.width = 120;
		progress.height = 20;
        if(addLabel)
            progress.horizontalAlign = "right";
        if(withBar){
            progress.getComponentAt(0).backgroundColor = "#999999";
            progress.pos = 100;
        } else{
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
		return {centeredText: l, bar: progress};
	}
}

typedef Controls = {};
typedef AreaView = {};

typedef ValueView = {
	var centeredText:Label;
	var bar:HorizontalProgress;
};

typedef ActorView = {
	var name:Label;
	var life:ValueView;
	var attack:ValueView;
};
