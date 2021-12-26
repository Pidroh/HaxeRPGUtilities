import RPGData.ActorSheet;
import RPGData.Equipment;
import BasicProcedural.ProceduralUnitRepeated;

class EnemyAreaInformation {
	public var sheet:ActorSheet;
	public var level:Int;
	public var nEnemies:Int;
	public var equipment:Array<Equipment> = new Array<Equipment>();
	public var sheetId:Int;
	public var equipId:Int;
	public var tags = new Array<String>();

	public function new() {}
}

class EnemyAreaFromProceduralUnitRepetition {
	public var units:Array<ProceduralUnitRepeated>;
	public var enemySheets = new Array<ActorSheet>();
	public var equipments = new Array<Equipment>();

	public var aux:EnemyAreaInformation = new EnemyAreaInformation();

	public function GetProceduralUnitRepeated(area:Int):ProceduralUnitRepeated {
		area = area % units.length;
		var u = units[area];
		return u;
	}

	public function GetEnemyAreaInformation(area:Int):EnemyAreaInformation {
		/*
			if(units.length <= area){
				aux.level = 0;
				aux.nEnemies = -1;
				aux.sheet = enemySheets[0];
				return aux;
			}
		 */
		var areaOrig = area;
		area = area % units.length;
		var u = units[area];
		var char = u.proceduralUnit.characteristics[0];
		var enemyId = char;
		var es = enemySheets[enemyId];
		var extraEquip:Equipment = null;

		// if enemy sheet is null, will choose a random enemy sheet
		if (es == null) {
			enemyId = u.randomExtra[0] % enemySheets.length;
			es = enemySheets[enemyId];
		}
		var nEnemies = -1;
		var levelBonus = 0;
		if (u.position == u.total - 1) {
			nEnemies = 1;
			levelBonus = 1;
			var hpMultiplier = 400;
			extraEquip = {
				seen: 0,
				requiredAttributes: null,
				type: 1,
				attributes: null,
				attributeMultiplier: ["LifeMax" => hpMultiplier]
			}
            extraEquip.attributes = new Map<String, Int>();

			if (areaOrig > 8) {
				levelBonus = 3;
			}
			if (areaOrig > 15) {
				levelBonus = 5;
				nEnemies = u.randomExtra[1] % 3 + 1;
			}
			if (areaOrig > 20)
				levelBonus = 15;
			if (areaOrig > 30)
				levelBonus = 25;
			if (areaOrig > 40)
				levelBonus = 30;
			if (areaOrig > 50)
				levelBonus = 40;
		}

		aux.sheet = es;
		aux.nEnemies = nEnemies;
		aux.level = levelBonus;
        aux.equipment.resize(0);
		if (equipments[char] != null || extraEquip != null) {
			if (equipments[char] != null) {
				aux.equipment.push(equipments[char]);
			}
            if (extraEquip != null){
                aux.equipment.push(extraEquip);
            }
		}

		aux.sheetId = enemyId;
		aux.equipId = char;
		return aux;
	}

	public function new() {}
}
