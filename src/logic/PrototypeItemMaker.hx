class PrototypeItemMaker {
	public static final itemType_Weapon = 0;
	public static final itemType_Armor = 1;

	public var items = new Array<ItemBase>();

    public function new(){}

	public function MakeItems() {
		//AddItem("Garb", itemType_Armor, ["LifeMax" => 3, "Attack" => 0.5, "Defense" => 0.2]);
		//AddItem("Shirt", itemType_Armor, ["LifeMax" => 4, "Speed" => 0.3, "Defense" => 0.15]);
        AddItem("Shirt", itemType_Armor, ["LifeMax" => 5]);
        AddItem("Vest", itemType_Armor, ["LifeMax" => 3, "Defense"=>0.6]);
		AddItem("Plate", itemType_Armor, ["Defense" => 1]);
		AddItem("Sword", itemType_Weapon, ["Attack" => 1]);
	}

	public function AddItem(name, type, scalingStats:Map<String, Float>) {
		items.push({
			name: name,
			type: type,
			scalingStats: scalingStats
		});
	}
}

typedef ItemBase = {
	var name:String;
	var type:Int;
	var scalingStats:Map<String, Float>;
}
