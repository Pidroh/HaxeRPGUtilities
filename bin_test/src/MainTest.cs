
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
			
		}
	}
	
	
}


