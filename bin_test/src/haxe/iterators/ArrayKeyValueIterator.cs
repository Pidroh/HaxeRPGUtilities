
#pragma warning disable 109, 114, 219, 429, 168, 162
namespace haxe.iterators {
	public class ArrayKeyValueIterator<T> : global::haxe.lang.HxObject, global::haxe.iterators.ArrayKeyValueIterator {
		
		public ArrayKeyValueIterator(global::haxe.lang.EmptyObject empty) {
		}
		
		
		public ArrayKeyValueIterator(global::Array<T> array) {
			global::haxe.iterators.ArrayKeyValueIterator<object>.__hx_ctor_haxe_iterators_ArrayKeyValueIterator<T>(((global::haxe.iterators.ArrayKeyValueIterator<T>) (this) ), ((global::Array<T>) (array) ));
		}
		
		
		protected static void __hx_ctor_haxe_iterators_ArrayKeyValueIterator<T_c>(global::haxe.iterators.ArrayKeyValueIterator<T_c> __hx_this, global::Array<T_c> array) {
			__hx_this.array = array;
		}
		
		
		public static object __hx_cast<T_c_c>(global::haxe.iterators.ArrayKeyValueIterator me) {
			return ( (( me != null )) ? (me.haxe_iterators_ArrayKeyValueIterator_cast<T_c_c>()) : default(object) );
		}
		
		
		public virtual object haxe_iterators_ArrayKeyValueIterator_cast<T_c>() {
			if (global::haxe.lang.Runtime.eq(typeof(T), typeof(T_c))) {
				return this;
			}
			
			global::haxe.iterators.ArrayKeyValueIterator<T_c> new_me = new global::haxe.iterators.ArrayKeyValueIterator<T_c>(((global::haxe.lang.EmptyObject) (global::haxe.lang.EmptyObject.EMPTY) ));
			global::Array<string> fields = global::Reflect.fields(this);
			int i = 0;
			while (( i < fields.length )) {
				string field = fields[i++];
				global::Reflect.setField(new_me, field, global::Reflect.field(this, field));
			}
			
			return new_me;
		}
		
		
		public global::Array<T> array;
		
		public override object __hx_setField(string field, int hash, object @value, bool handleProperties) {
			unchecked {
				switch (hash) {
					case 630156697:
					{
						this.array = ((global::Array<T>) (global::Array<object>.__hx_cast<T>(((global::Array) (@value) ))) );
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
					case 630156697:
					{
						return this.array;
					}
					
					
					default:
					{
						return base.__hx_getField(field, hash, throwErrors, isCheck, handleProperties);
					}
					
				}
				
			}
		}
		
		
		public override void __hx_getFields(global::Array<string> baseArr) {
			baseArr.push("array");
			base.__hx_getFields(baseArr);
		}
		
		
	}
}



#pragma warning disable 109, 114, 219, 429, 168, 162
namespace haxe.iterators {
	[global::haxe.lang.GenericInterface(typeof(global::haxe.iterators.ArrayKeyValueIterator<object>))]
	public interface ArrayKeyValueIterator : global::haxe.lang.IHxObject, global::haxe.lang.IGenericObject {
		
		object haxe_iterators_ArrayKeyValueIterator_cast<T_c>();
		
	}
}


