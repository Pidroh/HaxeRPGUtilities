import seedyrng.Random;

class Generation {
	static var random = new Random();

	static function GenerateNumber(seed:String, min:Int, max:Int) {}

	public function new(seed:String) {}

	// all possibilities: maxChar1 x maxChar2 x repetition
	public static function Generate(seed:String, maxChar1:Int, maxChar2:Int, repetition:Int):Array<ProceduralUnit> {
        var response = new Array<ProceduralUnit>();
		for (rep in 0...repetition) {
			for (c1 in 0...maxChar1) {
				for (c2 in 0...maxChar2) {
                    var pu = new ProceduralUnit();
                    pu.characteristics[0] = c1;
                    pu.characteristics[1] = c2;
                    pu.repeat = rep;
                    response.push(pu);
                }
			}
		}
        random.setStringSeed(seed);
        random.shuffle(response);
        return response;
	}
}

@:stackOnly
class ProceduralUnit {
	// randomly generated characteristics. Often every possibility generated multiple times, but not always.
	public var characteristics = new Array<Int>();
	// which repetition is this one in the full list
	public var repeat = 0;
}
