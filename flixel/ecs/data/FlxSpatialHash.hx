package flixel.ecs.data;

import haxe.ds.Vector;

class FlxSpatialHash
{
	public var cellSize:Int;
	public var tableSize:Int;
	
	var heads:Vector<Int>;
	var next:Vector<Int>;
	var contents:Vector<FlxBasic>;
	var lastQueryIds:Vector<Int>;
	
	var currentQueryId:Int = 0;
	var count:Int = 0;
	var capacity:Int;
	
	public function new(cellSize:Int = 64, initialCapacity:Int = 1000)
	{
		this.cellSize = cellSize;
		this.capacity = initialCapacity;
		this.tableSize = 2048; // Power of two
		
		heads = new Vector(tableSize);
		next = new Vector(capacity);
		contents = new Vector(capacity);
		lastQueryIds = new Vector(capacity);
		
		clear();
	}
	
	/**
	 * Resizes the flat arrays when capacity is reached.
	 */
	function resize(newCapacity:Int)
	{
		var oldNext = next;
		var oldContents = contents;
		var oldQueryIds = lastQueryIds;
		
		next = new Vector(newCapacity);
		contents = new Vector(newCapacity);
		lastQueryIds = new Vector(newCapacity);
		
		// Copy old data to new vectors
		for (i in 0...capacity)
		{
			next[i] = oldNext[i];
			contents[i] = oldContents[i];
			lastQueryIds[i] = oldQueryIds[i];
		}
		
		capacity = newCapacity;
	}
	
	public function clear()
	{
		for (i in 0...tableSize)
			heads[i] = -1;
		count = 0;
	}
	
	inline function getHash(ix:Int, iy:Int):Int
	{
		// Spatial hash prime constants
		var h = (ix * 73856093) ^ (iy * 19349663);
		return h & (tableSize - 1);
	}
	
	public function insert(entity:FlxBasic, x:Float, y:Float, width:Float, height:Float)
	{
		// 1. Check if we need more room
		if (count >= capacity)
		{
			resize(capacity * 2);
		}
		
		var entityIdx = count++;
		contents[entityIdx] = entity;
		lastQueryIds[entityIdx] = -1; // Initialize
		
		var startX = Std.int(x / cellSize);
		var endX = Std.int((x + width) / cellSize);
		var startY = Std.int(y / cellSize);
		var endY = Std.int((y + height) / cellSize);
		
		for (ix in startX...endX + 1)
		{
			for (iy in startY...endY + 1)
			{
				var h = getHash(ix, iy);
				// Link this entity index into the hash bucket
				next[entityIdx] = heads[h];
				heads[h] = entityIdx;
			}
		}
	}
	
	public function getNearby(entity:FlxBasic, x:Float, y:Float, width:Float, height:Float):Array<FlxBasic>
	{
		currentQueryId++;
		var results:Array<FlxBasic> = [];
		
		var startX = Std.int(x / cellSize);
		var endX = Std.int((x + width) / cellSize);
		var startY = Std.int(y / cellSize);
		var endY = Std.int((y + height) / cellSize);
		
		for (ix in startX...endX + 1)
		{
			for (iy in startY...endY + 1)
			{
				var h = getHash(ix, iy);
				var i = heads[h];
				
				while (i != -1)
				{
					// If the entity at this index hasn't been seen in THIS query
					if (contents[i] != entity && lastQueryIds[i] != currentQueryId)
					{
						lastQueryIds[i] = currentQueryId;
						results.push(contents[i]);
					}
					i = next[i];
				}
			}
		}
		return results;
	}
}
