import seedyrng.Random;

class PrototypeItemMaker {
	public static final itemType_Weapon = 0;
	public static final itemType_Armor = 1;

	public var items = new Array<ItemBase>();
	public var mods = new Array<ModBase>();

	public function new() {}

	function R(min, max) {
		return {min: min, max: max}
	}

	public function MakeItems() {
		// AddItem("Garb", itemType_Armor, ["LifeMax" => 3, "Attack" => 0.5, "Defense" => 0.2]);
		// AddItem("Shirt", itemType_Armor, ["LifeMax" => 4, "Speed" => 0.3, "Defense" => 0.15]);
		AddItem("Shirt", itemType_Armor, ["LifeMax" => 5]);
		AddItem("Vest", itemType_Armor, ["LifeMax" => 3, "Defense" => 0.6]);
		AddItem("Plate", itemType_Armor, ["Defense" => 1]);
		AddItem("Broad Sword", itemType_Weapon, ["Attack" => 1]);
		AddItem("Heavy Sword", itemType_Weapon, ["Attack" => 1], ["Attack" => R(115, 115), "Speed" => R(80, 80), "Piercing" => R(20,20)]);
		AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1], ["Attack" => R(150, 150), "Speed" => R(50, 50), "Piercing" => R(50,50)]);
        AddItem("Dagger", itemType_Weapon, ["Attack" => 1], ["Attack" => R(70, 70), "Speed" => R(175, 175)]);

		AddMod("of the Brute", "Barbarian's", ["Attack" => R(105, 110)]);
		AddMod("of the Guardian", "Golem's", ["Defense" => R(120, 150)]);
		AddMod("of the Thief", "Zidane's", ["Speed" => R(115, 130)]);
		AddMod("of Nature", "Aerith's", ["LifeMax" => R(130, 150)]);

		AddMod("of Rage", "Beserker's", ["Attack" => R(115, 125), "Defense" => R(70, 90)]);

		// AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1], ["Attack"=>R(200,280), "Speed"=>R(30, 45)]);
		// AddItem("Bastard Sword", itemType_Weapon, ["Attack" => 1.1], ["Speed"=>R(30, 40), "Power"=>(50,60)]);
	}

	public function AddMod(suffix, prefix, statMultipliers = null) {
		mods.push({
			prefix: prefix,
			suffix: suffix,
			statMultipliers: statMultipliers
		});
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
	var min:Int;
	var max:Int;
}

class RandomExtender{
    static public function Range(random:Random, range:Range) : Int{
        return random.randomInt(range.min, range.max);
    }
}

typedef ItemBase = {
	var name:String;
	var type:Int;
	var scalingStats:Map<String, Float>;
	var statMultipliers:Map<String, Range>;
}

typedef ModBase = {
	var prefix:String;
	var suffix:String;
	var statMultipliers:Map<String, Range>;
}
