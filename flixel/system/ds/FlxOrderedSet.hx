package flixel.system.ds;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A set data structure that maintains the insertion order of its elements.
 */
class FlxOrderedSet<T> implements IFlxDestroyable
{
	var map:Map<Dynamic, Bool>;
	var list:Array<T>;
	
	public var length(get, null):Int;
	
	public function new()
	{
		map = new Map<Dynamic, Bool>();
		list = [];
	}
	
	/**
	 * Adds an item to the set if it doesn't already exist.
	 * @return True if the item was added, false if it was already present.
	 */
	public function add(item:T):Bool
	{
		if (map.exists(item))
		{
			return false;
		}
		map.set(item, true);
		list.push(item);
		return true;
	}
	
	/**
	 * Removes an item from the set.
	 */
	public function remove(item:T):Bool
	{
		if (!map.exists(item))
		{
			return false;
		}
		map.remove(item);
		list.remove(item);
		return true;
	}
	
	public function exists(item:T):Bool
	{
		return map.exists(item);
	}
	
	public function destroy():Void
	{
		map = new Map<Dynamic, Bool>();
		list = [];
	}
	
	/**
	 * Allows for-in loops over the set in insertion order.
	 */
	public function iterator():Iterator<T>
	{
		return list.iterator();
	}
	
	public function toArray():Array<T>
	{
		return list.copy();
	}

    function get_length():Int
	{
		return list.length;
	}
}
