
#pragma warning disable 109, 114, 219, 429, 168, 162
public class BattleManager : global::haxe.lang.HxObject {
	
	public BattleManager(global::haxe.lang.EmptyObject empty) {
	}
	
	
	public BattleManager() {
		global::BattleManager.__hx_ctor__BattleManager(this);
	}
	
	
	protected static void __hx_ctor__BattleManager(global::BattleManager __hx_this) {
		unchecked {
			__hx_this.timePeriod = 1;
			{
				__hx_this.killedInArea = new global::Array<int>(new int[]{});
				__hx_this.maxArea = 1;
				global::haxe.ds.StringMap<int> _g = new global::haxe.ds.StringMap<int>();
				_g.@set("Attack", 5);
				_g.@set("Life", 20);
				_g.@set("LifeMax", 20);
				global::haxe.ds.StringMap<int> stats = _g;
				{
					object __temp_odecl1 = global::ResourceLogic.getExponentialResource(1.5, 1, 5);
					__hx_this.hero = new global::haxe.lang.DynamicObject(new int[]{26872, 241755125, 981808206, 1408123271, 1819702408}, new object[]{__temp_odecl1, stats, null, null, stats}, new int[]{1919096196}, new double[]{((double) (1) )});
				}
				
				global::haxe.ds.StringMap<int> _g1 = new global::haxe.ds.StringMap<int>();
				_g1.@set("Attack", 2);
				_g1.@set("Life", 6);
				_g1.@set("LifeMax", 6);
				global::haxe.ds.StringMap<int> stats2 = _g1;
				__hx_this.enemy = new global::haxe.lang.DynamicObject(new int[]{26872, 241755125, 981808206, 1408123271, 1819702408}, new object[]{null, stats2, null, null, stats2}, new int[]{1919096196}, new double[]{((double) (1) )});
				__hx_this.timeCount = ((double) (0) );
			}
			
		}
	}
	
	
	public object hero;
	
	public object enemy;
	
	public bool turn;
	
	public double timeCount;
	
	public double timePeriod;
	
	public int battleArea;
	
	public int playerTimesKilled;
	
	public bool dirty;
	
	public global::Array<int> killedInArea;
	
	public int necessaryToKillInArea;
	
	public int maxArea;
	
	public virtual void ChangeBattleArea(int area) {
		unchecked {
			this.battleArea = area;
			this.necessaryToKillInArea = ( 5 + area );
			int enemyLife = ( 6 + ( area * 3 ) );
			global::haxe.ds.StringMap<int> _g = new global::haxe.ds.StringMap<int>();
			_g.@set("Attack", ( 2 + ( area * 3 ) ));
			_g.@set("Life", enemyLife);
			_g.@set("LifeMax", enemyLife);
			global::haxe.ds.StringMap<int> stats2 = _g;
			this.enemy = new global::haxe.lang.DynamicObject(new int[]{26872, 241755125, 981808206, 1408123271, 1819702408}, new object[]{null, stats2, null, null, stats2}, new int[]{1919096196}, new double[]{((double) (( 1 + area )) )});
			this.dirty = true;
		}
	}
	
	
	public virtual string advance() {
		unchecked {
			string @event = "";
			if (( (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(this.hero, "attributesCalculated", 241755125, true)) )) ))) ).@get("Life")).@value <= 0 )) {
				this.playerTimesKilled++;
				@event = global::haxe.lang.Runtime.concat(@event, "You died\n\n\n");
				{
					global::haxe.IMap<string, int> this1 = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(this.hero, "attributesCalculated", 241755125, true)) ))) );
					int v = (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(this.hero, "attributesCalculated", 241755125, true)) )) ))) ).@get("LifeMax")).@value;
					((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (this1) ))) ).@set("Life", v);
				}
				
				{
					global::haxe.IMap<string, int> this2 = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(this.enemy, "attributesCalculated", 241755125, true)) ))) );
					int v1 = (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(this.enemy, "attributesCalculated", 241755125, true)) )) ))) ).@get("LifeMax")).@value;
					((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (this2) ))) ).@set("Life", v1);
				}
				
			}
			
			if (( (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(this.enemy, "attributesCalculated", 241755125, true)) )) ))) ).@get("Life")).@value <= 0 )) {
				this.killedInArea[this.battleArea]++;
				if (( this.killedInArea[this.battleArea] >= this.necessaryToKillInArea )) {
					if (( this.maxArea == this.battleArea )) {
						this.maxArea++;
					}
					
				}
				
				{
					object __temp_dynop1 = global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true);
					int __temp_expr1 = ((int) (global::haxe.lang.Runtime.setField_f(__temp_dynop1, "value", 834174833, ((double) (( ((int) (global::haxe.lang.Runtime.getField_f(__temp_dynop1, "value", 834174833, true)) ) + ((int) (global::haxe.lang.Runtime.getField_f(this.enemy, "level", 1919096196, true)) ) )) ))) );
				}
				
				if (( ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true), "value", 834174833, true)) ) > ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true), "calculatedMax", 873224454, true)) ) )) {
					int __temp_expr2 = ((int) (global::haxe.lang.Runtime.setField_f(global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true), "value", 834174833, ((double) (0) ))) );
					{
						object __temp_getvar2 = this.hero;
						int __temp_ret3 = ((int) (global::haxe.lang.Runtime.getField_f(__temp_getvar2, "level", 1919096196, true)) );
						int __temp_expr3 = ((int) (global::haxe.lang.Runtime.setField_f(__temp_getvar2, "level", 1919096196, ((double) (( __temp_ret3 + 1 )) ))) );
						int __temp_expr4 = __temp_ret3;
					}
					
					global::haxe.ds.StringMap<int> tmp = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(this.hero, "attributesBase", 1819702408, true)) ))) );
					global::haxe.ds.StringMap<double> _g = new global::haxe.ds.StringMap<double>();
					_g.@set("Attack", ((double) (1) ));
					_g.@set("LifeMax", ((double) (1) ));
					_g.@set("Life", ((double) (1) ));
					global::AttributeLogic.Add(tmp, _g, ((int) (global::haxe.lang.Runtime.getField_f(this.hero, "level", 1919096196, true)) ), ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(this.hero, "attributesCalculated", 241755125, true)) ))) ));
					global::ResourceLogic.recalculateScalingResource(((int) (global::haxe.lang.Runtime.getField_f(this.hero, "level", 1919096196, true)) ), global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true));
				}
				
				@event = global::haxe.lang.Runtime.concat(@event, "New enemy");
				@event = global::haxe.lang.Runtime.concat(@event, "\n\n\n");
				{
					global::haxe.IMap<string, int> this3 = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(this.enemy, "attributesCalculated", 241755125, true)) ))) );
					int v2 = (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(this.enemy, "attributesCalculated", 241755125, true)) )) ))) ).@get("LifeMax")).@value;
					((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (this3) ))) ).@set("Life", v2);
				}
				
			}
			
			string output = this.BaseInformationFormattedString();
			output = global::haxe.lang.Runtime.concat(output, "\n\n");
			output = global::haxe.lang.Runtime.concat(output, @event);
			object attacker = this.hero;
			object defender = this.enemy;
			if (this.turn) {
				attacker = this.enemy;
				defender = this.hero;
			}
			
			{
				global::haxe.ds.StringMap<int> _g1 = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (global::haxe.lang.Runtime.getField(defender, "attributesCalculated", 241755125, true)) ))) );
				{
					int v3 = ( (_g1.@get("Life")).@value - (((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(attacker, "attributesCalculated", 241755125, true)) )) ))) ).@get("Attack")).@value );
					_g1.@set("Life", v3);
				}
				
			}
			
			this.turn =  ! (this.turn) ;
			return output;
		}
	}
	
	
	public virtual string BaseInformationFormattedString() {
		int level = ((int) (global::haxe.lang.Runtime.getField_f(this.hero, "level", 1919096196, true)) );
		int xp = ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true), "value", 834174833, true)) );
		int xpmax = ((int) (global::haxe.lang.Runtime.getField_f(global::haxe.lang.Runtime.getField(this.hero, "xp", 26872, true), "calculatedMax", 873224454, true)) );
		string baseInfo = this.CharacterBaseInfoFormattedString(this.hero);
		string output = global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat("\n\nPlayer \r\n\tlevel: ", global::haxe.lang.Runtime.toString(level)), "\r\n\txp: "), global::haxe.lang.Runtime.toString(xp)), " / "), global::haxe.lang.Runtime.toString(xpmax)), "\r\n"), baseInfo);
		baseInfo = this.CharacterBaseInfoFormattedString(this.enemy);
		output = global::haxe.lang.Runtime.concat(output, "\n\n");
		output = global::haxe.lang.Runtime.concat(output, global::haxe.lang.Runtime.concat("Enemy\r\n", baseInfo));
		return output;
	}
	
	
	public virtual string CharacterBaseInfoFormattedString(object actor) {
		global::haxe.lang.Null<int> life = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(actor, "attributesCalculated", 241755125, true)) )) ))) ).@get("Life");
		global::haxe.lang.Null<int> lifeM = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(actor, "attributesCalculated", 241755125, true)) )) ))) ).@get("LifeMax");
		global::haxe.lang.Null<int> attack = ((global::haxe.ds.StringMap<int>) (global::haxe.ds.StringMap<object>.__hx_cast<int>(((global::haxe.ds.StringMap) (((global::haxe.IMap<string, int>) (global::haxe.lang.Runtime.getField(actor, "attributesCalculated", 241755125, true)) )) ))) ).@get("Attack");
		return global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat(global::haxe.lang.Runtime.concat("\t Life: ", global::haxe.lang.Runtime.toString((life).toDynamic())), " / "), global::haxe.lang.Runtime.toString((lifeM).toDynamic())), "\r\n\tAttack: "), global::haxe.lang.Runtime.toString((attack).toDynamic()));
	}
	
	
	public virtual string update(double delta) {
		this.timeCount += delta;
		if (( this.timeCount >= this.timePeriod )) {
			this.timeCount = ((double) (0) );
			return this.advance();
		}
		
		if (this.dirty) {
			this.dirty = false;
			return this.BaseInformationFormattedString();
		}
		
		return null;
	}
	
	
	public virtual void DefaultConfiguration() {
	}
	
	
	public virtual int getPlayerTimesKilled() {
		return this.playerTimesKilled;
	}
	
	
	public virtual void RetreatArea() {
		unchecked {
			if (( this.battleArea > 0 )) {
				this.ChangeBattleArea(( this.battleArea - 1 ));
			}
			
		}
	}
	
	
	public virtual void AdvanceArea() {
		unchecked {
			this.ChangeBattleArea(( this.battleArea + 1 ));
		}
	}
	
	
	public override double __hx_setField_f(string field, int hash, double @value, bool handleProperties) {
		unchecked {
			switch (hash) {
				case 1084548177:
				{
					this.maxArea = ((int) (@value) );
					return @value;
				}
				
				
				case 157130970:
				{
					this.necessaryToKillInArea = ((int) (@value) );
					return @value;
				}
				
				
				case 123289090:
				{
					this.playerTimesKilled = ((int) (@value) );
					return @value;
				}
				
				
				case 1306622181:
				{
					this.battleArea = ((int) (@value) );
					return @value;
				}
				
				
				case 1491380462:
				{
					this.timePeriod = ((double) (@value) );
					return @value;
				}
				
				
				case 2136217986:
				{
					this.timeCount = ((double) (@value) );
					return @value;
				}
				
				
				case 1887113800:
				{
					this.enemy = ((object) (@value) );
					return @value;
				}
				
				
				case 1158363130:
				{
					this.hero = ((object) (@value) );
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
				case 1084548177:
				{
					this.maxArea = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				case 157130970:
				{
					this.necessaryToKillInArea = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				case 1949824367:
				{
					this.killedInArea = ((global::Array<int>) (global::Array<object>.__hx_cast<int>(((global::Array) (@value) ))) );
					return @value;
				}
				
				
				case 1506824210:
				{
					this.dirty = global::haxe.lang.Runtime.toBool(@value);
					return @value;
				}
				
				
				case 123289090:
				{
					this.playerTimesKilled = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				case 1306622181:
				{
					this.battleArea = ((int) (global::haxe.lang.Runtime.toInt(@value)) );
					return @value;
				}
				
				
				case 1491380462:
				{
					this.timePeriod = ((double) (global::haxe.lang.Runtime.toDouble(@value)) );
					return @value;
				}
				
				
				case 2136217986:
				{
					this.timeCount = ((double) (global::haxe.lang.Runtime.toDouble(@value)) );
					return @value;
				}
				
				
				case 1292233597:
				{
					this.turn = global::haxe.lang.Runtime.toBool(@value);
					return @value;
				}
				
				
				case 1887113800:
				{
					this.enemy = ((object) (@value) );
					return @value;
				}
				
				
				case 1158363130:
				{
					this.hero = ((object) (@value) );
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
				case 55034127:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "AdvanceArea", 55034127)) );
				}
				
				
				case 1490610260:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "RetreatArea", 1490610260)) );
				}
				
				
				case 785282188:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "getPlayerTimesKilled", 785282188)) );
				}
				
				
				case 1117069141:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "DefaultConfiguration", 1117069141)) );
				}
				
				
				case 117802505:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "update", 117802505)) );
				}
				
				
				case 284451845:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "CharacterBaseInfoFormattedString", 284451845)) );
				}
				
				
				case 1312884082:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "BaseInformationFormattedString", 1312884082)) );
				}
				
				
				case 1863059586:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "advance", 1863059586)) );
				}
				
				
				case 1955468949:
				{
					return ((global::haxe.lang.Function) (new global::haxe.lang.Closure(this, "ChangeBattleArea", 1955468949)) );
				}
				
				
				case 1084548177:
				{
					return this.maxArea;
				}
				
				
				case 157130970:
				{
					return this.necessaryToKillInArea;
				}
				
				
				case 1949824367:
				{
					return this.killedInArea;
				}
				
				
				case 1506824210:
				{
					return this.dirty;
				}
				
				
				case 123289090:
				{
					return this.playerTimesKilled;
				}
				
				
				case 1306622181:
				{
					return this.battleArea;
				}
				
				
				case 1491380462:
				{
					return this.timePeriod;
				}
				
				
				case 2136217986:
				{
					return this.timeCount;
				}
				
				
				case 1292233597:
				{
					return this.turn;
				}
				
				
				case 1887113800:
				{
					return this.enemy;
				}
				
				
				case 1158363130:
				{
					return this.hero;
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
				case 1084548177:
				{
					return ((double) (this.maxArea) );
				}
				
				
				case 157130970:
				{
					return ((double) (this.necessaryToKillInArea) );
				}
				
				
				case 123289090:
				{
					return ((double) (this.playerTimesKilled) );
				}
				
				
				case 1306622181:
				{
					return ((double) (this.battleArea) );
				}
				
				
				case 1491380462:
				{
					return this.timePeriod;
				}
				
				
				case 2136217986:
				{
					return this.timeCount;
				}
				
				
				case 1887113800:
				{
					return ((double) (global::haxe.lang.Runtime.toDouble(this.enemy)) );
				}
				
				
				case 1158363130:
				{
					return ((double) (global::haxe.lang.Runtime.toDouble(this.hero)) );
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
				case 55034127:
				{
					this.AdvanceArea();
					break;
				}
				
				
				case 1490610260:
				{
					this.RetreatArea();
					break;
				}
				
				
				case 785282188:
				{
					return this.getPlayerTimesKilled();
				}
				
				
				case 1117069141:
				{
					this.DefaultConfiguration();
					break;
				}
				
				
				case 117802505:
				{
					return this.update(((double) (global::haxe.lang.Runtime.toDouble(dynargs[0])) ));
				}
				
				
				case 284451845:
				{
					return this.CharacterBaseInfoFormattedString(dynargs[0]);
				}
				
				
				case 1312884082:
				{
					return this.BaseInformationFormattedString();
				}
				
				
				case 1863059586:
				{
					return this.advance();
				}
				
				
				case 1955468949:
				{
					this.ChangeBattleArea(((int) (global::haxe.lang.Runtime.toInt(dynargs[0])) ));
					break;
				}
				
				
				default:
				{
					return base.__hx_invokeField(field, hash, dynargs);
				}
				
			}
			
			return null;
		}
	}
	
	
	public override void __hx_getFields(global::Array<string> baseArr) {
		baseArr.push("maxArea");
		baseArr.push("necessaryToKillInArea");
		baseArr.push("killedInArea");
		baseArr.push("dirty");
		baseArr.push("playerTimesKilled");
		baseArr.push("battleArea");
		baseArr.push("timePeriod");
		baseArr.push("timeCount");
		baseArr.push("turn");
		baseArr.push("enemy");
		baseArr.push("hero");
		base.__hx_getFields(baseArr);
	}
	
	
}


