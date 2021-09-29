
#pragma warning disable 109, 114, 219, 429, 168, 162
public class ResourceLogic : global::haxe.lang.HxObject {
	
	public ResourceLogic(global::haxe.lang.EmptyObject empty) {
	}
	
	
	public ResourceLogic() {
		global::ResourceLogic.__hx_ctor__ResourceLogic(this);
	}
	
	
	protected static void __hx_ctor__ResourceLogic(global::ResourceLogic __hx_this) {
	}
	
	
	public static void recalculateScalingResource(int @base, object res) {
		if (( ((int) (global::haxe.lang.Runtime.getField_f(res, "lastUsedBaseAttribute", 1717792280, true)) ) != @base )) {
			double data1 = global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(res, "scaling", 1695182407, true), "data1", 1418202823, true);
			int calculated = ((int) (( global::System.Math.Pow(((double) (data1) ), ((double) (@base) )) + ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(res, "scaling", 1695182407, true), "initial", 1268715652, true)) ) )) );
			calculated -= ( ((int) (calculated) ) % ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(res, "scaling", 1695182407, true), "minimumIncrement", 1154676353, true)) ) );
			int __temp_expr1 = ((int) (global::haxe.lang.Runtime.setField_f(res, "calculatedMax", 873224454, ((double) (calculated) ))) );
			int __temp_expr2 = ((int) (global::haxe.lang.Runtime.setField_f(res, "lastUsedBaseAttribute", 1717792280, ((double) (@base) ))) );
		}
		
	}
	
	
	public static object getExponentialResource(double expBase, int minimumIncrement, int initial) {
		unchecked {
			object res = null;
			{
				object __temp_odecl1 = new global::haxe.lang.DynamicObject(new int[]{1292432058}, new object[]{global::ScalingType.exponential}, new int[]{1154676353, 1268715652, 1418202823}, new double[]{((double) (minimumIncrement) ), ((double) (initial) ), expBase});
				res = new global::haxe.lang.DynamicObject(new int[]{1695182407}, new object[]{__temp_odecl1}, new int[]{834174833, 873224454, 1717792280}, new double[]{((double) (0) ), ((double) (0) ), ((double) (0) )});
			}
			
			global::ResourceLogic.recalculateScalingResource(1, res);
			return res;
		}
	}
	
	
}



#pragma warning disable 109, 114, 219, 429, 168, 162
public class AttributeLogic : global::haxe.lang.HxObject {
	
	public AttributeLogic(global::haxe.lang.EmptyObject empty) {
	}
	
	
	public AttributeLogic() {
		global::AttributeLogic.__hx_ctor__AttributeLogic(this);
	}
	
	
	protected static void __hx_ctor__AttributeLogic(global::AttributeLogic __hx_this) {
	}
	
	
	public static void AddOld(global::haxe.ds.StringMap<int> attributes, global::haxe.ds.StringMap<double> attributeAddition, int quantityOfAddition) {
		global::haxe.IMap<string, int> map = attributes;
		global::haxe.IMap<string, int> _g_map = map;
		object _g_keys = map.keys();
		while (global::haxe.lang.Runtime.toBool(global::haxe.lang.Runtime.callField(_g_keys, "hasNext", 407283053, null))) {
			string key = global::haxe.lang.Runtime.toString(global::haxe.lang.Runtime.callField(_g_keys, "next", 1224901875, null));
			int _g1_value = (_g_map.@get(key)).@value;
			string _g1_key = key;
			string key1 = _g1_key;
			int @value = _g1_value;
			{
				string _g = key1;
				global::haxe.ds.StringMap<int> _g1 = attributes;
				{
					int v = ( (_g1.@get(_g)).@value + ((int) (( (attributeAddition.@get(key1)).@value * quantityOfAddition )) ) );
					_g1.@set(_g, v);
				}
				
			}
			
		}
		
	}
	
	
	public static void Add(global::haxe.ds.StringMap<int> attributes, global::haxe.ds.StringMap<double> attributeAddition, int quantityOfAddition, global::haxe.ds.StringMap<int> result) {
		global::haxe.IMap<string, double> map = attributeAddition;
		global::haxe.IMap<string, double> _g_map = map;
		object _g_keys = map.keys();
		while (global::haxe.lang.Runtime.toBool(global::haxe.lang.Runtime.callField(_g_keys, "hasNext", 407283053, null))) {
			string key = global::haxe.lang.Runtime.toString(global::haxe.lang.Runtime.callField(_g_keys, "next", 1224901875, null));
			double _g1_value = (_g_map.@get(key)).@value;
			string _g1_key = key;
			string key1 = _g1_key;
			double @value = _g1_value;
			{
				int v = ( (attributes.@get(key1)).@value + ((int) (( @value * quantityOfAddition )) ) );
				result.@set(key1, v);
			}
			
		}
		
	}
	
	
}



#pragma warning disable 109, 114, 219, 429, 168, 162
public class ScalingType : global::haxe.lang.Enum {
	
	protected ScalingType(int index) : base(index) {
	}
	
	
	public static readonly global::ScalingType exponential = new global::ScalingType_exponential();
	
}



#pragma warning disable 109, 114, 219, 429, 168, 162
public sealed class ScalingType_exponential : global::ScalingType {
	
	public ScalingType_exponential() : base(0) {
	}
	
	
	public override string getTag() {
		return "exponential";
	}
	
	
}


