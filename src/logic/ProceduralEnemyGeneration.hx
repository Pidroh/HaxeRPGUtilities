import RPGData.ActorSheet;
import RPGData.Equipment;
import BasicProcedural.ProceduralUnitRepeated;


class EnemyAreaInformation{
    public var sheet : ActorSheet;
    public var level : Int;
    public var nEnemies : Int;
    public var equipment : Equipment;
    public function new(){}
}

class EnemyAreaFromProceduralUnitRepetition{
    public var units : Array<ProceduralUnitRepeated>;
    public var enemySheets = new Array<ActorSheet>();
    public var equipments = new Array<Equipment>();

    public var aux : EnemyAreaInformation = new EnemyAreaInformation();
    public function GetProceduralUnitRepeated(area:Int) : ProceduralUnitRepeated{
        area = area % units.length;
        var u = units[area];
        return u;
    }
    public function GetEnemyAreaInformation(area : Int) : EnemyAreaInformation{
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
        var es = enemySheets[char];

        // if enemy sheet is null, will choose a random enemy sheet
        if(es == null){
            es = enemySheets[u.randomExtra[0] % enemySheets.length];
        }
        var nEnemies = -1;
        var levelBonus = 0;
        if(u.position == u.total-1){
            nEnemies = 3;
            levelBonus = 5;
            if(areaOrig > 15)
                levelBonus = 10;
            if(areaOrig > 30)
                levelBonus = 15;
        }
        aux.sheet = es;
        aux.nEnemies = nEnemies;
        aux.level = levelBonus;
        aux.equipment = equipments[char];
        return aux;
    }

    public function new(){}

}