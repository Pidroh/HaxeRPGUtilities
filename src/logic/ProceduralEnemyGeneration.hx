import js.html.rtc.IceCandidate;
import RPGData.ActorSheet;
import BasicProcedural.ProceduralUnitRepeated;

class EnemyAreaInformation{
    public var sheet : ActorSheet;
    public var level : Int;
    public var nEnemies : Int;
    public function new(){}
}

class EnemyAreaFromProceduralUnitRepetition{
    public var units : Array<ProceduralUnitRepeated>;
    public var enemySheets = new Array<ActorSheet>();

    public var aux : EnemyAreaInformation = new EnemyAreaInformation();
    public function GetEnemyAreaInformation(area : Int) : EnemyAreaInformation{
        /*
        if(units.length <= area){
            aux.level = 0;
            aux.nEnemies = -1;
            aux.sheet = enemySheets[0];
            return aux;
        }
        */
        area = area % units.length;
        var u = units[area];
        var char = u.proceduralUnit.characteristics[0];
        var es = enemySheets[char];
        var nEnemies = -1;
        var levelBonus = 0;
        if(u.position == u.total-1){
            nEnemies = 1;
            levelBonus = 5;
            if(area > 15)
                levelBonus = 10;
            if(area > 30)
                levelBonus = 15;
        }
        aux.sheet = es;
        aux.nEnemies = nEnemies;
        aux.level = levelBonus;
        return aux;

    }

    public function new(){}

}