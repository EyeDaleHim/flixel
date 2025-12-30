package flixel.ecs.systems;

import flixel.ecs.components.FlxComponent;
import flixel.ecs.data.FlxSystemPhase;
import flixel.group.FlxGroup;
import flixel.util.FlxDestroyUtil;

/**
 * A System processes entities that have a specific set of components.
 */
class FlxComponentSystem implements IFlxDestroyable
{
	static var idEnumerator:Int = 0;
	
	public var id:Int = idEnumerator++;
	
	/**
	 * The phase this system runs in. It is not necessary to
	 * add checks if your system inherits from `FlxComponentSystem` as 
	 * `FlxG` handles that for you.
	 */
	public var phase:FlxSystemPhase = FlxSystemPhase.PRE_UPDATE;
	
	/**
	 * Priority determines execution order. Lower values run first.
	 */
	public var priority:Int = 0;
	
	public var active:Bool = true;
	
	public function new(phase:FlxSystemPhase = FlxSystemPhase.PRE_UPDATE, priority:Int = 0)
	{
		this.phase = phase;
		this.priority = priority;
	}
	
	public function getComponentsOfType<T:FlxComponent>(componentType:Class<T>, ?list:FlxGroup):Array<T>
	{
		list ??= FlxG.state;
		var components:Array<T> = [];
		for (entity in list.members)
		{
			var component:T = entity.getComponent(componentType);
			if (component != null)
			{
				components.push(component);
			}
		}
		return components;
	}
	
	public function getEntitiesWith<T:FlxComponent>(componentType:Class<T>, ?list:FlxGroup):Array<FlxBasic>
	{
		list ??= FlxG.state;
		var entities:Array<FlxBasic> = [];
		for (entity in list.members)
		{
			if (entity.getComponent(componentType) != null)
			{
				entities.push(entity);
			}
		}
		return entities;
	}
	
	public function update(phase:FlxSystemPhase, elapsed:Float):Void {}
	
	public function destroy():Void {}
}
