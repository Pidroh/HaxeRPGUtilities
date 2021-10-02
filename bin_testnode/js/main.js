(function ($global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); },$hxEnums = $hxEnums || {},$_;
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var BattleManager = function() {
	this.battleArea = 0;
	this.timePeriod = 1;
	this.killedInArea = [];
	this.maxArea = 0;
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 5;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	var stats = _g;
	this.hero = { level : 1, attributesBase : stats, equipmentSlots : null, equipment : null, xp : ResourceLogic.getExponentialResource(1.5,1,5), attributesCalculated : haxe_ds_StringMap.createCopy(stats.h)};
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 2;
	_g.h["Life"] = 6;
	_g.h["LifeMax"] = 6;
	var stats2 = _g;
	this.enemy = { level : 1, attributesBase : stats2, equipmentSlots : null, equipment : null, xp : null, attributesCalculated : stats2};
	this.timeCount = 0;
};
BattleManager.__name__ = true;
BattleManager.prototype = {
	ChangeBattleArea: function(area) {
		this.battleArea = area;
		this.necessaryToKillInArea = 5 + area;
		var enemyLife = 6 + area * 3;
		var _g = new haxe_ds_StringMap();
		_g.h["Attack"] = 2 + area * 3;
		_g.h["Life"] = enemyLife;
		_g.h["LifeMax"] = enemyLife;
		var stats2 = _g;
		this.enemy = { level : 1 + area, attributesBase : stats2, equipmentSlots : null, equipment : null, xp : null, attributesCalculated : stats2};
		this.dirty = true;
	}
	,advance: function() {
		var event = "";
		if(this.hero.attributesCalculated.h["Life"] <= 0) {
			this.playerTimesKilled++;
			event += "You died\n\n\n";
			var v = this.hero.attributesCalculated.h["LifeMax"];
			this.hero.attributesCalculated.h["Life"] = v;
			var v = this.enemy.attributesCalculated.h["LifeMax"];
			this.enemy.attributesCalculated.h["Life"] = v;
		}
		if(this.enemy.attributesCalculated.h["Life"] <= 0) {
			if(this.killedInArea[this.battleArea] == null) {
				this.killedInArea[this.battleArea] = 0;
			}
			this.killedInArea[this.battleArea]++;
			if(this.killedInArea[this.battleArea] >= this.necessaryToKillInArea) {
				if(this.maxArea == this.battleArea) {
					this.maxArea++;
				}
			}
			this.hero.xp.value += this.enemy.level;
			if(this.hero.xp.value > this.hero.xp.calculatedMax) {
				this.hero.xp.value = 0;
				this.hero.level++;
				var tmp = this.hero.attributesBase;
				var _g = new haxe_ds_StringMap();
				_g.h["Attack"] = 1;
				_g.h["LifeMax"] = 1;
				_g.h["Life"] = 1;
				AttributeLogic.Add(tmp,_g,this.hero.level,this.hero.attributesCalculated);
				ResourceLogic.recalculateScalingResource(this.hero.level,this.hero.xp);
			}
			event += "New enemy";
			event += "\n\n\n";
			var v = this.enemy.attributesCalculated.h["LifeMax"];
			this.enemy.attributesCalculated.h["Life"] = v;
		}
		var output = this.BaseInformationFormattedString();
		output += "\n\n";
		output += event;
		var attacker = this.hero;
		var defender = this.enemy;
		if(this.turn) {
			attacker = this.enemy;
			defender = this.hero;
		}
		var _g = defender.attributesCalculated;
		var v = _g.h["Life"] - attacker.attributesCalculated.h["Attack"];
		_g.h["Life"] = v;
		this.turn = !this.turn;
		return output;
	}
	,BaseInformationFormattedString: function() {
		var level = this.hero.level;
		var xp = this.hero.xp.value;
		var xpmax = this.hero.xp.calculatedMax;
		var baseInfo = this.CharacterBaseInfoFormattedString(this.hero);
		var areaText = "";
		var battleAreaShow = this.battleArea + 1;
		var maxAreaShow = this.maxArea + 1;
		if(this.maxArea > 0) {
			areaText = "Area: " + battleAreaShow + " / " + maxAreaShow;
		}
		var output = "" + areaText + "\r\n\r\n\n\nPlayer \r\n\tlevel: " + level + "\r\n\txp: " + xp + " / " + xpmax + "\r\n" + baseInfo;
		baseInfo = this.CharacterBaseInfoFormattedString(this.enemy);
		output += "\n\n";
		output += "Enemy\r\n" + baseInfo;
		return output;
	}
	,CharacterBaseInfoFormattedString: function(actor) {
		var life = actor.attributesCalculated.h["Life"];
		var lifeM = actor.attributesCalculated.h["LifeMax"];
		var attack = actor.attributesCalculated.h["Attack"];
		return "\t Life: " + life + " / " + lifeM + "\r\n\tAttack: " + attack;
	}
	,update: function(delta) {
		this.timeCount += delta;
		this.canAdvance = this.battleArea < this.maxArea;
		this.canRetreat = this.battleArea > 0;
		if(this.timeCount >= this.timePeriod) {
			this.timeCount = 0;
			return this.advance();
		}
		if(this.dirty) {
			this.dirty = false;
			return this.BaseInformationFormattedString();
		}
		return null;
	}
	,DefaultConfiguration: function() {
	}
	,getPlayerTimesKilled: function() {
		return this.playerTimesKilled;
	}
	,RetreatArea: function() {
		if(this.battleArea > 0) {
			this.ChangeBattleArea(this.battleArea - 1);
		}
	}
	,AdvanceArea: function() {
		this.ChangeBattleArea(this.battleArea + 1);
	}
};
var IntIterator = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIterator.__name__ = true;
IntIterator.prototype = {
	hasNext: function() {
		return this.min < this.max;
	}
	,next: function() {
		return this.min++;
	}
};
var MainTest = function() { };
MainTest.__name__ = true;
MainTest.main = function() {
	process.stdout.write("Hard area death test");
	process.stdout.write("\n");
	var bm = new BattleManager();
	bm.DefaultConfiguration();
	bm.ChangeBattleArea(100);
	var _g = 1;
	while(_g < 99) {
		var i = _g++;
		bm.update(0.9);
	}
	if(bm.getPlayerTimesKilled() < 5) {
		process.stdout.write("ERROR: Did not die!");
		process.stdout.write("\n");
	}
	process.stdout.write("Easy area no death");
	process.stdout.write("\n");
	var bm = new BattleManager();
	bm.DefaultConfiguration();
	bm.ChangeBattleArea(1);
	bm.update(0.9);
	bm.update(0.9);
	bm.update(0.9);
	if(bm.getPlayerTimesKilled() > 0) {
		process.stdout.write("ERROR: Died");
		process.stdout.write("\n");
	}
	process.stdout.write("Level up Stat Test");
	process.stdout.write("\n");
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 5;
	_g.h["Life"] = 20;
	_g.h["LifeMax"] = 20;
	var stats = _g;
	var hero_level = 1;
	var hero_attributesBase = stats;
	var hero_equipmentSlots = null;
	var hero_equipment = null;
	var hero_xp = ResourceLogic.getExponentialResource(1.5,1,5);
	var hero_attributesCalculated = haxe_ds_StringMap.createCopy(stats.h);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,1,hero_attributesCalculated);
	if(hero_attributesCalculated.h["Attack"] != 6) {
		process.stdout.write("ERROR: Calculated Attack Value Wrong");
		process.stdout.write("\n");
	}
	if(hero_attributesBase.h["Attack"] != 5) {
		process.stdout.write("ERROR: Base Attack Value Modified");
		process.stdout.write("\n");
	}
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,1,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,2,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,3,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,4,hero_attributesCalculated);
	var _g = new haxe_ds_StringMap();
	_g.h["Attack"] = 1;
	_g.h["LifeMax"] = 1;
	_g.h["Life"] = 1;
	AttributeLogic.Add(hero_attributesBase,_g,5,hero_attributesCalculated);
	if(hero_attributesCalculated.h["Attack"] != 10) {
		process.stdout.write("ERROR: Calculated Attack Value Wrong");
		process.stdout.write("\n");
	}
	if(hero_attributesBase.h["Attack"] != 5) {
		process.stdout.write("ERROR: Base Attack Value Modified");
		process.stdout.write("\n");
	}
};
Math.__name__ = true;
var ResourceLogic = function() { };
ResourceLogic.__name__ = true;
ResourceLogic.recalculateScalingResource = function(base,res) {
	if(res.lastUsedBaseAttribute != base) {
		var data1 = res.scaling.data1;
		var calculated = Math.pow(data1,base) + res.scaling.initial | 0;
		calculated -= calculated % res.scaling.minimumIncrement;
		res.calculatedMax = calculated;
		res.lastUsedBaseAttribute = base;
	}
};
ResourceLogic.getExponentialResource = function(expBase,minimumIncrement,initial) {
	var res = { scaling : { data1 : expBase, initial : initial, minimumIncrement : minimumIncrement, type : ScalingType.exponential}, value : 0, lastUsedBaseAttribute : 0, calculatedMax : 0};
	ResourceLogic.recalculateScalingResource(1,res);
	return res;
};
var AttributeLogic = function() { };
AttributeLogic.__name__ = true;
AttributeLogic.AddOld = function(attributes,attributeAddition,quantityOfAddition) {
	var h = attributes.h;
	var _g_h = h;
	var _g_keys = Object.keys(h);
	var _g_length = _g_keys.length;
	var _g_current = 0;
	while(_g_current < _g_length) {
		var key = _g_keys[_g_current++];
		var _g1_key = key;
		var _g1_value = _g_h[key];
		var key1 = _g1_key;
		var value = _g1_value;
		var _g = key1;
		var _g1 = attributes;
		var v = _g1.h[_g] + (attributeAddition.h[key1] * quantityOfAddition | 0);
		_g1.h[_g] = v;
	}
};
AttributeLogic.Add = function(attributes,attributeAddition,quantityOfAddition,result) {
	var h = attributeAddition.h;
	var _g_h = h;
	var _g_keys = Object.keys(h);
	var _g_length = _g_keys.length;
	var _g_current = 0;
	while(_g_current < _g_length) {
		var key = _g_keys[_g_current++];
		var _g1_key = key;
		var _g1_value = _g_h[key];
		var key1 = _g1_key;
		var value = _g1_value;
		var v = attributes.h[key1] + (value * quantityOfAddition | 0);
		result.h[key1] = v;
	}
};
var ScalingType = $hxEnums["ScalingType"] = { __ename__:true,__constructs__:null
	,exponential: {_hx_name:"exponential",_hx_index:0,__enum__:"ScalingType",toString:$estr}
};
ScalingType.__constructs__ = [ScalingType.exponential];
var haxe_io_Output = function() { };
haxe_io_Output.__name__ = true;
var _$Sys_FileOutput = function(fd) {
	this.fd = fd;
};
_$Sys_FileOutput.__name__ = true;
_$Sys_FileOutput.__super__ = haxe_io_Output;
_$Sys_FileOutput.prototype = $extend(haxe_io_Output.prototype,{
	writeByte: function(c) {
		js_node_Fs.writeSync(this.fd,String.fromCodePoint(c));
	}
	,writeBytes: function(s,pos,len) {
		var data = s.b;
		return js_node_Fs.writeSync(this.fd,js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length),pos,len);
	}
	,writeString: function(s,encoding) {
		js_node_Fs.writeSync(this.fd,s);
	}
	,flush: function() {
		js_node_Fs.fsyncSync(this.fd);
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
});
var haxe_io_Input = function() { };
haxe_io_Input.__name__ = true;
var _$Sys_FileInput = function(fd) {
	this.fd = fd;
};
_$Sys_FileInput.__name__ = true;
_$Sys_FileInput.__super__ = haxe_io_Input;
_$Sys_FileInput.prototype = $extend(haxe_io_Input.prototype,{
	readByte: function() {
		var buf = js_node_buffer_Buffer.alloc(1);
		try {
			js_node_Fs.readSync(this.fd,buf,0,1,null);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
		return buf[0];
	}
	,readBytes: function(s,pos,len) {
		var data = s.b;
		var buf = js_node_buffer_Buffer.from(data.buffer,data.byteOffset,s.length);
		try {
			return js_node_Fs.readSync(this.fd,buf,pos,len,null);
		} catch( _g ) {
			var e = haxe_Exception.caught(_g).unwrap();
			if(e.code == "EOF") {
				throw haxe_Exception.thrown(new haxe_io_Eof());
			} else {
				throw haxe_Exception.thrown(haxe_io_Error.Custom(e));
			}
		}
	}
	,close: function() {
		js_node_Fs.closeSync(this.fd);
	}
});
var haxe_Exception = function(message,previous,native) {
	Error.call(this,message);
	this.message = message;
	this.__previousException = previous;
	this.__nativeException = native != null ? native : this;
};
haxe_Exception.__name__ = true;
haxe_Exception.caught = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value;
	} else if(((value) instanceof Error)) {
		return new haxe_Exception(value.message,null,value);
	} else {
		return new haxe_ValueException(value,null,value);
	}
};
haxe_Exception.thrown = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value.get_native();
	} else if(((value) instanceof Error)) {
		return value;
	} else {
		var e = new haxe_ValueException(value);
		return e;
	}
};
haxe_Exception.__super__ = Error;
haxe_Exception.prototype = $extend(Error.prototype,{
	unwrap: function() {
		return this.__nativeException;
	}
	,get_native: function() {
		return this.__nativeException;
	}
});
var haxe_ValueException = function(value,previous,native) {
	haxe_Exception.call(this,String(value),previous,native);
	this.value = value;
};
haxe_ValueException.__name__ = true;
haxe_ValueException.__super__ = haxe_Exception;
haxe_ValueException.prototype = $extend(haxe_Exception.prototype,{
	unwrap: function() {
		return this.value;
	}
});
var haxe_ds_StringMap = function() {
	this.h = Object.create(null);
};
haxe_ds_StringMap.__name__ = true;
haxe_ds_StringMap.createCopy = function(h) {
	var copy = new haxe_ds_StringMap();
	for (var key in h) copy.h[key] = h[key];
	return copy;
};
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
haxe_io_Bytes.__name__ = true;
var haxe_io_Encoding = $hxEnums["haxe.io.Encoding"] = { __ename__:true,__constructs__:null
	,UTF8: {_hx_name:"UTF8",_hx_index:0,__enum__:"haxe.io.Encoding",toString:$estr}
	,RawNative: {_hx_name:"RawNative",_hx_index:1,__enum__:"haxe.io.Encoding",toString:$estr}
};
haxe_io_Encoding.__constructs__ = [haxe_io_Encoding.UTF8,haxe_io_Encoding.RawNative];
var haxe_io_Eof = function() {
};
haxe_io_Eof.__name__ = true;
haxe_io_Eof.prototype = {
	toString: function() {
		return "Eof";
	}
};
var haxe_io_Error = $hxEnums["haxe.io.Error"] = { __ename__:true,__constructs__:null
	,Blocked: {_hx_name:"Blocked",_hx_index:0,__enum__:"haxe.io.Error",toString:$estr}
	,Overflow: {_hx_name:"Overflow",_hx_index:1,__enum__:"haxe.io.Error",toString:$estr}
	,OutsideBounds: {_hx_name:"OutsideBounds",_hx_index:2,__enum__:"haxe.io.Error",toString:$estr}
	,Custom: ($_=function(e) { return {_hx_index:3,e:e,__enum__:"haxe.io.Error",toString:$estr}; },$_._hx_name="Custom",$_.__params__ = ["e"],$_)
};
haxe_io_Error.__constructs__ = [haxe_io_Error.Blocked,haxe_io_Error.Overflow,haxe_io_Error.OutsideBounds,haxe_io_Error.Custom];
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.__name__ = true;
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(o.__enum__) {
			var e = $hxEnums[o.__enum__];
			var con = e.__constructs__[o._hx_index];
			var n = con._hx_name;
			if(con.__params__) {
				s = s + "\t";
				return n + "(" + ((function($this) {
					var $r;
					var _g = [];
					{
						var _g1 = 0;
						var _g2 = con.__params__;
						while(true) {
							if(!(_g1 < _g2.length)) {
								break;
							}
							var p = _g2[_g1];
							_g1 = _g1 + 1;
							_g.push(js_Boot.__string_rec(o[p],s));
						}
					}
					$r = _g;
					return $r;
				}(this))).join(",") + ")";
			} else {
				return n;
			}
		}
		if(((o) instanceof Array)) {
			var str = "[";
			s += "\t";
			var _g = 0;
			var _g1 = o.length;
			while(_g < _g1) {
				var i = _g++;
				str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( _g ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		var k = null;
		for( k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) {
			str += ", \n";
		}
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var js_node_Fs = require("fs");
var js_node_KeyValue = {};
js_node_KeyValue.get_key = function(this1) {
	return this1[0];
};
js_node_KeyValue.get_value = function(this1) {
	return this1[1];
};
var js_node_buffer_Buffer = require("buffer").Buffer;
var js_node_stream_WritableNewOptionsAdapter = {};
js_node_stream_WritableNewOptionsAdapter.from = function(options) {
	if(!Object.prototype.hasOwnProperty.call(options,"final")) {
		Object.defineProperty(options,"final",{ get : function() {
			return options.final_;
		}});
	}
	return options;
};
var js_node_url_URLSearchParamsEntry = {};
js_node_url_URLSearchParamsEntry._new = function(name,value) {
	var this1 = [name,value];
	return this1;
};
js_node_url_URLSearchParamsEntry.get_name = function(this1) {
	return this1[0];
};
js_node_url_URLSearchParamsEntry.get_value = function(this1) {
	return this1[1];
};
if( String.fromCodePoint == null ) String.fromCodePoint = function(c) { return c < 0x10000 ? String.fromCharCode(c) : String.fromCharCode((c>>10)+0xD7C0)+String.fromCharCode((c&0x3FF)+0xDC00); }
String.__name__ = true;
Array.__name__ = true;
js_Boot.__toStr = ({ }).toString;
MainTest.main();
})({});