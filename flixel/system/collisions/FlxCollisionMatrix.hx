package flixel.system.collisions;

import flixel.system.ds.FlxOrderedSet;

class FlxCollisionMatrix
{
	// Maps a Layer ID to a set of Layer IDs it can collide with
	var matrix:Map<Int, FlxOrderedSet<Int>> = new Map();
	
	public function new() {}
	
	/**
	 * Define that objects in Layer A can collide with objects in Layer B.
	 * This is bidirectional by default.
	 */
	public function setCanCollide(layerA:Int, layerB:Int, canCollide:Bool = true):Void
	{
		setEntry(layerA, layerB, canCollide);
		setEntry(layerB, layerA, canCollide);
	}
	
	public function shouldCollide(layerA:Int, layerB:Int):Bool
	{
		if (!matrix.exists(layerA))
			return false;
		return matrix.get(layerA).exists(layerB);
	}
	
	function setEntry(a:Int, b:Int, val:Bool):Void
	{
		if (!matrix.exists(a))
			matrix.set(a, new FlxOrderedSet<Int>());
		if (val)
			matrix.get(a).add(b);
		else
			matrix.get(a).remove(b);
	}
}
