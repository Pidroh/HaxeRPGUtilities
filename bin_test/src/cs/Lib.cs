
#pragma warning disable 109, 114, 219, 429, 168, 162
namespace cs {
	public class Lib : global::haxe.lang.HxObject {
		
		public Lib(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public Lib() {
			global::cs.Lib.__hx_ctor_cs_Lib(this);
		}
		
		
		protected static void __hx_ctor_cs_Lib(global::cs.Lib __hx_this) {
		}
		
		
		public static string decimalSeparator;
		
		public static void applyCultureChanges() {
			global::System.Globalization.CultureInfo ci = new global::System.Globalization.CultureInfo(((string) (global::System.Threading.Thread.CurrentThread.CurrentCulture.Name) ), ((bool) (true) ));
			global::cs.Lib.decimalSeparator = ci.NumberFormat.NumberDecimalSeparator;
			ci.NumberFormat.NumberDecimalSeparator = ((string) (".") );
			global::System.Threading.Thread.CurrentThread.CurrentCulture = ((global::System.Globalization.CultureInfo) (ci) );
		}
		
		
	}
}


