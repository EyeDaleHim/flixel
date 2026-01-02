package flixel.ecs.components;

import flixel.util.FlxDirectionFlags;
import flixel.FlxObject.CollisionDragType;
import flixel.ecs.components.FlxComponent;

class FlxCollisionComponent extends FlxComponent
{
	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts.
	 */
	public var touching:FlxDirectionFlags = FlxDirectionFlags.NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts from the previous game loop step.
	 */
	public var wasTouching:FlxDirectionFlags = FlxDirectionFlags.NONE;

	/**
	 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions.
	 * Useful for things like one-way platforms (e.g. allowCollisions = UP;).
	 */
	public var allowCollisions(default, set) = FlxDirectionFlags.ANY;

	/**
	 * Whether this sprite is dragged along with the horizontal movement of objects it collides with.
	 */
	public var collisionXDrag:CollisionDragType = IMMOVABLE;

	/**
	 * Whether this sprite is dragged along with the vertical movement of objects it collides with.
	 */
	public var collisionYDrag:CollisionDragType = NEVER;

	/**
	 * An ID representing the group(s) this object belongs to.
	 * The `FlxCollisionSystem` will use this to filter collisions.
	 * Defaults to 1.
	 */
	public var collisionLayer:Int = 1;

	public function new()
	{
		super();
	}

	function set_allowCollisions(value:FlxDirectionFlags):FlxDirectionFlags
	{
		return allowCollisions = value;
	}
}