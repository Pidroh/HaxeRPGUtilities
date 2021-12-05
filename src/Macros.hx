import haxe.macro.Context;

class MyMacro {
	public static macro function GetPlatform() : haxe.macro.Expr.ExprOf<String> {
        return macro $v{Context.definedValue("platform")};
    }
}
