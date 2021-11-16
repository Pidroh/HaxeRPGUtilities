class PrototypeItemMaker {
	public static final itemType_Weapon = 0;
	public static final itemType_Armor = 1;

	public var items = new Array<ItemBase>();

    public function new(){}

    function R(min, max){
        return {min:min, max:max}
    }

	public function MakeItems() {
		//AddItem("Garb", itemType_Armor, ["LifeMax" => 3, "Attack" => 0.5, "Defense" => 0.2]);
		//AddItem("Shirt", itemType_Armor, ["LifeMax" => 4, "Speed" => 0.3, "Defense" => 0.15]);
        AddItem("Shirt", itemType_Armor, ["LifeMax" => 5]);
        AddItem("Vest", itemType_Armor, ["LifeMax" => 3, "Defense"=>0.6]);
		AddItem("Plate", itemType_Armor, ["Defense" => 1]);
		AddItem("Broad Sword", itemType_Weapon, ["Attack" => 1]);
        AddItem("Heavy Sword", itemType_Weapon, ["Attack" => 1], ["Attack"=>R(110, 130), "Speed"=>R(75, 95)]);
        AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1], ["Attack"=>R(140, 180), "Speed"=>R(50, 70)]);
        
        //AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1], ["Attack"=>R(200,280), "Speed"=>R(30, 45)]);
        //AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1.1], ["Speed"=>R(30, 40), "Power"=>(50,60)]);
	}

	public function AddItem(name, type, scalingStats:Map<String, Float>, statMultipliers = null) {
		items.push({
			name: name,
			type: type,
			scalingStats: scalingStats,
            statMultipliers: statMultipliers
		});
	}
}

typedef Range = {
    var min : Int;
    var max : Int;
}

typedef ItemBase = {
	var name:String;
	var type:Int;
	var scalingStats:Map<String, Float>;
    var statMultipliers:Map<String, Range>;
}
