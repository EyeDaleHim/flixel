package flixel.ecs.systems;

import flixel.FlxBasic;
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
	
	public function getEntitiesWithSingular<T:FlxComponent>(componentType:Class<T>, ?list:FlxGroup):Array<FlxBasic>
	{
		list ??= FlxG.state;
		var entities:Array<FlxBasic> = [];
		for (entity in list.members)
		{
			if (entity.hasComponent(componentType))
			{
				entities.push(entity);
			}
		}
		return entities;
	}
	
	/**
	 * Retrieves a list of entities that possess all the specified component types.
	 *
	 * This method iterates through the entities in the provided `list` (or `FlxG.state` if `list` is null)
	 * and checks if each entity has all the component types specified in `componentTypes`.
	 *
	 * @param   componentTypes  An array of `Class` objects representing the component types to query for.
	 * @param   all             If all entities must have ALL specified components. Otherwise, entities must have 
	 * 							AT LEAST ONE specified component.
	 * @param   list            The `FlxGroup` to search within. Defaults to `FlxG.state`.
	 * @return  An `Array` of `FlxBasic` entities that match the query.
	 */
	public function getEntitiesWithMultiple(componentTypes:Array<Class<FlxComponent>>, ?all:Bool = false, ?list:FlxGroup):Array<FlxBasic>
	{
		list ??= FlxG.state;
		var entities:Array<FlxBasic> = [];
		for (entity in list.members)
		{
			if (all)
			{
				var hasAllComponents:Bool = true;
				for (componentType in componentTypes)
				{
					if (!entity.hasComponent(componentType))
					{
						hasAllComponents = false;
						break;
					}
				}
				if (hasAllComponents)
					entities.push(entity);
			}
			else
			{
				for (componentType in componentTypes)
				{
					if (entity.hasComponent(componentType))
					{
						entities.push(entity);
						break;
					}
				}
			}
		}
		return entities;
	}
	
	public function update(phase:FlxSystemPhase, elapsed:Float):Void {}
	
	public function destroy():Void {}
}
