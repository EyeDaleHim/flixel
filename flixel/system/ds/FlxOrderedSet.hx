package flixel.system.ds;

/**
 *	A set is a list of unique values.  Value equality is determined using `==`.
 *
 *	See thx.core.
 */
abstract FlxOrderedSet<T>(Map<T, Bool>)
{
	/**
		Creates a FlxOrderedSet of Strings with optional initial values.
	**/
	public static function createString(?it:Iterable<String>)
	{
		var map = new Map<String, Bool>();
		var set = new FlxOrderedSet<String>(map);
		if (null != it)
			set.pushMany(it);
		return set;
	}

	/**
		Creates a FlxOrderedSet of Ints with optional initial values.
	**/
	public static function createInt(?it:Iterable<Int>)
	{
		var map = new Map<Int, Bool>();
		var set = new FlxOrderedSet<Int>(map);
		if (null != it)
			set.pushMany(it);
		return set;
	}

	/**
		Creates a FlxOrderedSet of anonymous objects with optional initial values.
	**/
	public static function createObject<T:{}>(?it:Iterable<T>)
	{
		var map = new Map<T, Bool>();
		var set = new FlxOrderedSet<T>(map);
		if (null != it)
			set.pushMany(it);
		return set;
	}

	/**
		Creates a FlxOrderedSet of EnumValue, with optional initial values.
	**/
	public static function createEnum<T:EnumValue>(?arr:Iterable<T>)
	{
		var map = new Map<T, Bool>();
		var set = new FlxOrderedSet<T>(map);
		if (null != arr)
			set.pushMany(arr);
		return set;
	}
	
	public var length(get, never):Int;
	
	inline function new(map:Map<T, Bool>)
		this = map;
		
	/**
		`add` pushes a value into `FlxOrderedSet` if the value was not already present.

		It returns a boolean value indicating if `FlxOrderedSet` was changed by the operation or not.
	**/
	public function add(v:T):Bool
		return if (this.exists(v)) false; else
		{
			this.set(v, true);
			true;
		}
	/**
		`copy` creates a new `FlxOrderedSet` with copied elements.
	**/
	public function copy():FlxOrderedSet<T>
	{
		var inst = empty();
		for (k in this.keys())
			inst.push(k);
		return inst;
	}
	
	/**
		Creates an empty copy of the current set.
	**/
	public function empty():FlxOrderedSet<T>
	{
		var inst:Map<T, Bool> = Type.createInstance(Type.getClass(this), []);
		return new FlxOrderedSet(inst);
	}
	
	/**
		`difference` creates a new `FlxOrderedSet` with elements from the first set excluding the elements
		from the second.
	**/
	@:op(A - B) public inline function difference(set:FlxOrderedSet<T>):FlxOrderedSet<T>
	{
		var result = copy();
		for (item in set)
			result.remove(item);
		return result;
	}

	public function filter(predicate:T->Bool):FlxOrderedSet<T>
		return reduce(function(acc:FlxOrderedSet<T>, v:T)
		{
			if (predicate(v))
				acc.add(v);
			return acc;
		}, empty());
		
	public function map<TOut>(f:T->TOut):Array<TOut>
		return reduce(function(acc:Array<TOut>, v:T)
		{
			acc.push(f(v));
			return acc;
		}, []);
		
	/**
		`exists` returns `true` if it contains an element that is equals to `v`.
	**/
	public inline function exists(v:T):Bool
		return this.exists(v);
		
	public inline function remove(v:T):Bool
		return this.remove(v);
		
	/**
		`intersection` returns a FlxOrderedSet with elements that are presents in both sets
	**/
	public inline function intersection(set:FlxOrderedSet<T>):FlxOrderedSet<T>
	{
		var result = empty();
		for (item in iterator())
			if (set.exists(item))
				result.push(item);
		return result;
	}

	/**
		Like `add` but doesn't notify if the addition was successful or not.
	**/
	public inline function push(v:T):Void
		this.set(v, true);
		
	/**
		Pushes many values to the set
	**/
	public function pushMany(values:Iterable<T>):Void
		for (value in values)
			push(value);
			
	public function reduce<TOut>(handler:TOut->T->TOut, acc:TOut):TOut
	{
		for (v in iterator())
		{
			acc = handler(acc, v);
		}
		return acc;
	}

	/**
		Iterates the values of the FlxOrderedSet.
	**/
	public function iterator()
		return this.keys();
		
	/**
		Union creates a new FlxOrderedSet with elements from both sets.
	**/
	@:op(A + B) public inline function union(set:FlxOrderedSet<T>):FlxOrderedSet<T>
	{
		var newset = copy();
		newset.pushMany(set);
		return newset;
	}

	/**
		Converts a `FlxOrderedSet<T>` into `Array<T>`. The returned array is a copy of the internal
		array used by `FlxOrderedSet`. This ensures that the set is not affected by unsafe operations
		that might happen on the returned array.
	**/
	@:to public function toArray():Array<T>
	{
		var arr:Array<T> = [];
		for (k in this.keys())
			arr.push(k);
		return arr;
	}

	/**
		Converts `FlxOrderedSet` into `String`. To differentiate from normal `Array`s the output string
		uses curly braces `{}` instead of square brackets `[]`.
	**/
	@:to public function toString():String
		return "{" + toArray().join(", ") + "}";
		
	function get_length()
	{
		var l = 0;
		for (i in this)
			++l;
		return l;
	}
}