
#pragma warning disable 109, 114, 219, 429, 168, 162
public class IntIterator : global::haxe.lang.HxObject {
	
	public IntIterator(global::haxe.lang.EmptyObject empty) {
	}
	
	
	public IntIterator(int min, int max) {
		global::IntIterator.__hx_ctor__IntIterator(this, min, max);
	}
	
	
	protected static void __hx_ctor__IntIterator(global::IntIterator __hx_this, int min, int max) {
		__hx_this.min = min;
		__hx_this.max = max;
	}
	
	
	public int min;
	
	public int max;
	
	public bool hasNext() {
		return ( this.min < this.max );
	}
	
	
	public int next() {
		return this.min++;
	}
	
	
	public override double __hx_setField_f(string field, int hash, double @value, bool handleProperties) {
		unchecked {
			switch (hash) {
				case 5442212:
				{
					this.max = ((int) (@value) );
					return @value;
				}
				
				
				case 5443986:
				{
					this.min = ((int) (@value) );
					return @value;
				}
				
				
				default:
				{
					return base.__hx_setField_f(field, hash, @value, handleProperties);
				}
				
			}
			
		}
	}
	
	
	public override object __hx_setField(string field, int hash, object @value, bool handleProperties) {
		unchecked {
			switch (hash) {
				case 5442212:
				{
					this.max = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				case 5443986:
				{
					this.min = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				default:
				{
					return base.__hx_setField(field, hash, @value, handleProperties);
				}
				
			}
			
		}
	}
	
	
	public override object __hx_getField(string field, int hash, bool throwErrors, bool isCheck, bool handleProperties) {
		unchecked {
			switch (hash) {
				case 1224901875:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "next", 1224901875)) );
				}
				
				
				case 407283053:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "hasNext", 407283053)) );
				}
				
				
				case 5442212:
				{
					return this.max;
				}
				
				
				case 5443986:
				{
					return this.min;
				}
				
				
				default:
				{
					return base.__hx_getField(field, hash, throwErrors, isCheck, handleProperties);
				}
				
			}
			
		}
	}
	
	
	public override double __hx_getField_f(string field, int hash, bool throwErrors, bool handleProperties) {
		unchecked {
			switch (hash) {
				case 5442212:
				{
					return ((double) (this.max) );
				}
				
				
				case 5443986:
				{
					return ((double) (this.min) );
				}
				
				
				default:
				{
					return base.__hx_getField_f(field, hash, throwErrors, handleProperties);
				}
				
			}
			
		}
	}
	
	
	public override object __hx_invokeField(string field, int hash, object[] dynargs) {
		unchecked {
			switch (hash) {
				case 1224901875:
				{
					return this.next();
				}
				
				
				case 407283053:
				{
					return this.hasNext();
				}
				
				
				default:
				{
					return base.__hx_invokeField(field, hash, dynargs);
				}
				
			}
			
		}
	}
	
	
	public override void __hx_getFields(global::Array<string> baseArr) {
		baseArr.push("max");
		baseArr.push("min");
		base.__hx_getFields(baseArr);
	}
	
	
}


