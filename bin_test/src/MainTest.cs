
#pragma warning disable 109, 114, 219, 429, 168, 162
public class MainTest : global::haxe.lang.HxObject {
	
	public static void Main(){
		global::cs.Boot.init();
		global::MainTest.main();
	}
	public MainTest(global::haxe.lang.EmptyObject empty) {
	}
	
	
	public MainTest() {
		global::MainTest.__hx_ctor__MainTest(this);
	}
	
	
	protected static void __hx_ctor__MainTest(global::MainTest __hx_this) {
	}
	
	
	public static void main() {
		unchecked {
			{
				global::System.Console.WriteLine(((object) ("Hard area death test") ));
				global::BattleManager bm = new global::BattleManager();
				bm.DefaultConfiguration();
				bm.ChangeBattleArea(100);
				{
					int _g = 1;
					while (( _g < 99 )) {
						int i = _g++;
						bm.update(0.9);
					}
					
				}
				
				if (( bm.getPlayerTimesKilled() < 5 )) {
					global::System.Console.WriteLine(((object) ("ERROR: Did not die!") ));
				}
				
			}
			
			{
				global::System.Console.WriteLine(((object) ("Easy area no death") ));
				global::BattleManager bm1 = new global::BattleManager();
				bm1.DefaultConfiguration();
				bm1.ChangeBattleArea(1);
				{
					bm1.update(0.9);
					bm1.update(0.9);
					bm1.update(0.9);
				}
				
				if (( bm1.getPlayerTimesKilled() > 0 )) {
					global::System.Console.WriteLine(((object) ("ERROR: Died") ));
				}
				
			}
			
			{
				global::System.Console.WriteLine(((object) ("Level up Stat Test") ));
				global::haxe.ds.StringMap<int> _g1 = new global::haxe.ds.StringMap<int>();
				_g1.@set("Attack", 5);
				_g1.@set("Life", 20);
				_g1.@set("LifeMax", 20);
				global::haxe.ds.StringMap<int> stats = _g1;
				int hero_level = 1;
				global::haxe.ds.StringMap<int> hero_attributesBase = stats;
				global::Array<int> hero_equipmentSlots = null;
				global::Array<object> hero_equipment = null;
				object hero_xp = global::ResourceLogic.getExponentialResource(1.5, 1, 5);
				global::haxe.ds.StringMap<int> hero_attributesCalculated = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (stats.copy()) )) ))) );
				global::haxe.ds.StringMap<double> _g2 = new global::haxe.ds.StringMap<double>();
				_g2.@set("Attack", ((double) (1) ));
				_g2.@set("LifeMax", ((double) (1) ));
				_g2.@set("Life", ((double) (1) ));
				global::AttributeLogic.Add(hero_attributesBase, _g2, 1, hero_attributesCalculated);
				if (( ! (global::haxe.lang.Runtime.eq((((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (hero_attributesCalculated) )) ))) ).@get("Attack")).toDynamic(), 6)) )) {
					global::System.Console.WriteLine(((object) ("ERROR: Calculated Attack Value Wrong") ));
				}
				
				if (( ! (global::haxe.lang.Runtime.eq((((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (hero_attributesBase) )) ))) ).@get("Attack")).toDynamic(), 5)) )) {
					global::System.Console.WriteLine(((object) ("ERROR: Base Attack Value Modified") ));
				}
				
				global::haxe.ds.StringMap<double> _g3 = new global::haxe.ds.StringMap<double>();
				_g3.@set("Attack", ((double) (1) ));
				_g3.@set("LifeMax", ((double) (1) ));
				_g3.@set("Life", ((double) (1) ));
				global::AttributeLogic.Add(hero_attributesBase, _g3, 5, hero_attributesCalculated);
				if (( ! (global::haxe.lang.Runtime.eq((((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (hero_attributesCalculated) )) ))) ).@get("Attack")).toDynamic(), 10)) )) {
					global::System.Console.WriteLine(((object) ("ERROR: Calculated Attack Value Wrong") ));
				}
				
				if (( ! (global::haxe.lang.Runtime.eq((((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (hero_attributesBase) )) ))) ).@get("Attack")).toDynamic(), 5)) )) {
					global::System.Console.WriteLine(((object) ("ERROR: Base Attack Value Modified") ));
				}
				
			}
			
		}
	}
	
	
}


