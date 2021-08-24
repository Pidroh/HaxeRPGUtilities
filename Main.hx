class Main {
    static function main() {
        
        trace("Haxe is great!");
    }
  }

typedef Actor = {
	var level:Int;
	var attributesBase:Map<String, Int>;
	var equipment:Array<Equipment>;
	var equipmentSlots:Array<Int>;
}
typedef LevelGrowth = {
    var attributesBase:Map<String, Int>;
}

typedef Equipment = {
	var type:Int;
	var requiredAttributes:Map<String, Int>;
	var attributes:Map<String, Int>;
}



