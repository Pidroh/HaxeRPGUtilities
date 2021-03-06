import PrototypeItemMaker.RandomExtender;
import PrototypeItemMaker.Range;
import seedyrng.Random;

class Generation {
	static var random = new Random();

	static function GenerateNumber(seed:String, min:Int, max:Int) {}

	public function new(seed:String) {}

	public static function GenerateRepetitions(seed:String, procUnits:Array<ProceduralUnit>, range:Range):Array<ProceduralUnitRepeated> {
		var purs = new Array<ProceduralUnitRepeated>();
		random.setStringSeed(seed);
		for (index => value in procUnits) {
			var repetitions = RandomExtender.Range(random, range);
			for (i in 0...repetitions) {
				var pur = new ProceduralUnitRepeated();
				pur.position = i;
				pur.total = repetitions;
				pur.proceduralUnit = value;
				pur.randomExtra.push(random.randomInt(0, 1000));
				pur.randomExtra.push(random.randomInt(0, 1000));
				pur.randomExtra.push(random.randomInt(0, 1000));
				purs.push(pur);
			}
		}
		return purs;
	}

	// all possibilities: maxChar1 x maxChar2 x repetition
	public static function Generate(seed:String, maxChar1:Int, maxChar2:Int, repetition:Int, response:Array<ProceduralUnit> = null,
			skipCharacteristicsFirstRound:Array<Int> = null):Array<ProceduralUnit> {
		random.setStringSeed(seed);
		if (response == null)
			var response = new Array<ProceduralUnit>();
		var responseAux = new Array<ProceduralUnit>();
		for (rep in 0...repetition) {
			for (c1 in 0...maxChar1) {
				if (skipCharacteristicsFirstRound != null && repetition == 0 && skipCharacteristicsFirstRound.contains(c1)) {
					continue;
				}
				for (c2 in 0...maxChar2) {
					var pu = new ProceduralUnit();
					pu.characteristics[0] = c1;
					pu.characteristics[1] = c2;
					pu.repeat = rep;
					responseAux.push(pu);
				}
			}
			random.shuffle(responseAux);
			for (unit in responseAux) {
				response.push(unit);
			}
			responseAux.resize(0);
		}
		return response;
	}
}

@:stackOnly
class ProceduralUnit {
	// randomly generated characteristics. Often every possibility generated multiple times, but not always.
	public var characteristics = new Array<Int>();
	// which repetition is this one in the full list
	public var repeat = 0;

	public function new() {}
}

@:stackOnly
class ProceduralUnitRepeated {
	// the procedural unit to be repeated
	public var proceduralUnit:ProceduralUnit;
	// the position in the total amount repeated
	public var position = 0;
	// the total amount repeated
	public var total = 0;
	// random numbers to use in data processing
	public var randomExtra = new Array<Int>();

	public function new() {}
}
