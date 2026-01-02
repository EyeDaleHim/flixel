package flixel.system.frontEnds;

import flixel.ecs.data.FlxSystemPhase;
import flixel.ecs.systems.FlxComponentSystem;
import flixel.ecs.systems.FlxCollisionSystem;
import flixel.ecs.systems.FlxMotionSystem;

class ECSFrontEnd
{
	var _systems:Array<FlxComponentSystem> = [];

	var _sortOnAdd:Bool = false;
	
	public function new()
	{
		add(new FlxMotionSystem());
		add(new FlxCollisionSystem());
		
		_sortOnAdd = true;
		sort();
	}
	
	/**
	 * Adds a system to the ECS.
	 * Systems are sorted by priority, then by creation order (ID).
	 * @param system The system to add.
	 * @return The added system.
	 */
	public function add<T:FlxComponentSystem>(system:T):T
	{
		_systems.push(system);
		if (_sortOnAdd)
			sort();
		return system;
	}
	
	/**
	 * Retrieves a system of a specific type from the ECS.
	 * @param systemType The class of the system to retrieve.
	 * @return The system of the specified type, or `null` if not found.
	 */
	public function get<T:FlxComponentSystem>(systemType:Class<T>):T
	{
		for (system in _systems)
		{
			if (Std.isOfType(system, systemType))
			{
				return cast system;
			}
		}
		return null;
	}
	
	/**
	 * Removes a system from the ECS.
	 * @param system The system to remove.
	 */
	public function remove(system:FlxComponentSystem):Void
	{
		_systems.remove(system);
	}
	
	/**
	 * Sorts systems based on priority, then by ID.
	 */
	public function sort():Void
	{
		_systems.sort((a, b) ->
		{
			if (a.priority != b.priority)
			{
				return a.priority - b.priority;
			}
			return a.id - b.id;
		});
	}
	
	@:allow(flixel.FlxGame)
	inline function update(phase:FlxSystemPhase, elapsed:Float):Void
	{
		for (system in _systems)
		{
			if (system.active && (system.phase & phase) != 0)
				system.update(phase, elapsed);
		}
	}
	
	public function destroy():Void
	{
		for (system in _systems)
			system.destroy();
			
		_systems = [];
	}
}
