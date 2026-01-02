package flixel.system.ds;

import haxe.ds.ObjectMap;

class FlxClassMap
{
	var map:ObjectMap<{}, Dynamic> = new ObjectMap<{}, Dynamic>();
	
	public function new() {}
	
	public function set<T>(cl:Class<T>, instance:T):Void
	{
		map.set(cast cl, instance);
	}
	
	public function get<T>(cl:Class<T>):Null<T>
	{
		return cast map.get(cast cl);
	}

    public function remove<T>(cl:Class<T>):Void
    {
        map.remove(cast cl);
    }

    public function iterator():Iterator<Dynamic>
    {
        return map.iterator();
    }
}
