package flixel.ecs.systems;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.ecs.components.FlxCollisionComponent;
import flixel.ecs.components.FlxPositionComponent;
import flixel.ecs.components.FlxSizeComponent;
import flixel.ecs.data.FlxSystemPhase;
import flixel.system.collisions.FlxCollisionMatrix;
import flixel.system.collisions.FlxSpatialHash;
import flixel.util.FlxDirectionFlags;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxBaseTilemap;
import flixel.FlxObject.CollisionDragType;

class FlxCollisionSystem extends FlxComponentSystem
{
	public var matrix:FlxCollisionMatrix;
	
	var spatialHash:FlxSpatialHash;
	
	/**
	 * This value dictates the maximum number of pixels two objects have to intersect
	 * before collision stops trying to separate them.
	 * Don't modify this unless your objects are passing through each other.
	 */
	public static var SEPARATE_BIAS:Float = 4;

	public function new()
	{
		super(FlxSystemPhase.PRE_UPDATE);
		
		spatialHash = new FlxSpatialHash(128);
		matrix = new FlxCollisionMatrix();
	}
	
	/**
	 * The declarative update loop for the collision system.
	 * It will automatically check for collisions between objects
	 * that have a `FlxCollisionComponent` based on their layers and masks.
	 * (This is a placeholder implementation).
	 */
	override public function update(phase:FlxSystemPhase, elapsed:Float):Void
	{
		spatialHash.clear();
		var entities = getEntitiesWithMultiple([FlxPositionComponent, FlxSizeComponent, FlxCollisionComponent]);
		
		// Broad-phase
		for (entity in entities)
		{
			final pos = entity.getComponent(FlxPositionComponent);
			final size = entity.getComponent(FlxSizeComponent);
			spatialHash.insert(entity, pos.x, pos.y, size.width, size.height);
			
			final col = entity.getComponent(FlxCollisionComponent);
			col.wasTouching = col.touching;
			col.touching = FlxDirectionFlags.NONE;
		}
		
		// Narrow-phase
		for (entity in entities)
		{
			final col = entity.getComponent(FlxCollisionComponent);
			final pos = entity.getComponent(FlxPositionComponent);
			final size = entity.getComponent(FlxSizeComponent);
			
			var nearbyEntities = spatialHash.getNearby(entity, pos.x, pos.y, size.width, size.height);
			for (otherEntity in nearbyEntities)
			{
				var otherCol = otherEntity.getComponent(FlxCollisionComponent);
				
				if (matrix.shouldCollide(col.collisionLayer, otherCol.collisionLayer))
				{
					// TODO: After all checks, this means they are definitely colliding.
					// We can process their overlap code here, maybe like AABB?

					final obj1:FlxObject = cast entity;
					final obj2:FlxObject = cast otherEntity;

					separate(obj1, obj2);
				}
			}
		}
	}

	static function allowCollisionDrag(type:CollisionDragType, object1:FlxObject, object2:FlxObject):Bool
	{
		return object2.active && object2.moves && switch (type)
		{
			case NEVER: false;
			case ALWAYS: true;
			case IMMOVABLE: object2.immovable;
			case HEAVIER: object2.immovable || object2.mass > object1.mass;
		}
	}
	
	/**
	 * Internal elper that determines whether either object is a tilemap, determines
	 * which tiles are overlapping and calls the appropriate separator
	 * 
	 * 
	 * 
	 * @param   func         The process you wish to call with both objects, or between tiles,
	 *                       
	 * @param   isCollision  Does nothing, if both objects are immovable
	 * @return  The result of whichever separator was used
	 * @since 5.9.0
	 */
	@:haxe.warning("-WDeprecated")
	static function processCheckTilemap(object1:FlxObject, object2:FlxObject, func:(FlxObject, FlxObject)->Bool,
		?position:FlxPoint, isCollision = true):Bool
	{
		// two immovable objects cannot collide
		if (isCollision && object1.immovable && object2.immovable)
			return false;
		
		// If one of the objects is a tilemap, just pass it off.
		@:privateAccess
		if (object1.flixelType == TILEMAP)
		{
			final tilemap:FlxBaseTilemap<Dynamic> = cast object1;
			// If object1 is a tilemap, check it's tiles against object2, which may also be a tilemap
			function recurseProcess(tile, _)
			{
				// Keep tile as first arg
				return processCheckTilemap(tile, object2, func, position, isCollision);
			}
			return tilemap.overlapsWithCallback(object2, recurseProcess, false, position);
		}
		else if (object2.flixelType == TILEMAP)
		{
			final tilemap:FlxBaseTilemap<Dynamic> = cast object2;
			// If object1 is a tilemap, check it's tiles against object2, which may also be a tilemap
			function recurseProcess(tile, _)
			{
				// Keep tile as second arg
				return processCheckTilemap(object1, tile, func, position, isCollision);
			}
			return tilemap.overlapsWithCallback(object1, recurseProcess, false, position);
		}
		
		return func(object1, object2);
	}
	
	/**
	 * Separates 2 overlapping objects. If an object is a tilemap,
	 * it will separate it from any tiles that overlap it.
	 * 
	 * @return  Whether the objects were overlapping and were separated
	 */
	public static function separate(object1:FlxObject, object2:FlxObject):Bool
	{
		final separatedX = separateX(object1, object2);
		final separatedY = separateY(object1, object2);
		return separatedX || separatedY;
		
		/*
		 * Note: can't do the following, FlxTilemapExt works better when you separate all
		 * tiles in the x and then all tiles the y, rather than iterating all overlapping
		 * tiles and separating the x and y on each of them. If we find a way around this
		 * if would be more efficient to do the following
		 */
		// function helper(object1, object2)
		// {
		// 	final separatedX = separateXHelper(object1, object2);
		// 	final separatedY = separateYHelper(object1, object2);
		// 	return separatedX || separatedY;
		// }
		// return processCheckTilemap(object1, object2, helper);
	}
	
	/**
	 * Separates 2 overlapping objects along the X-axis. if an object is a tilemap,
	 * it will separate it from any tiles that overlap it.
	 * 
	 * @return  Whether the objects were overlapping and were separated along the X-axis
	 */
	public static function separateX(object1:FlxObject, object2:FlxObject):Bool
	{
		return processCheckTilemap(object1, object2, separateXHelper);
	}
	
	/**
	 * Separates 2 overlapping objects along the Y-axis. if an object is a tilemap,
	 * it will separate it from any tiles that overlap it.
	 * 
	 * @return  Whether the objects were overlapping and were separated along the Y-axis
	 */
	public static function separateY(object1:FlxObject, object2:FlxObject):Bool
	{
		return processCheckTilemap(object1, object2, separateYHelper);
	}
	
	/**
	 * Same as `separateX` but assumes both are not immovable and not tilemaps
	 */
	static function separateXHelper(object1:FlxObject, object2:FlxObject):Bool
	{
		final overlap:Float = computeOverlapX(object1, object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			final delta1 = object1.x - object1.last.x;
			final delta2 = object2.x - object2.last.x;
			final vel1 = object1.velocity.x;
			final vel2 = object2.velocity.x;
			
			if (!object1.immovable && !object2.immovable)
			{
				#if FLX_4_LEGACY_COLLISION
				legacySeparateX(object1, object2, overlap);
				#else
				object1.x -= overlap * 0.5;
				object2.x += overlap * 0.5;
				
				final mass1 = object1.mass;
				final mass2 = object2.mass;
				final momentum = mass1 * vel1 + mass2 * vel2;
				object1.velocity.x = (momentum + object1.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
				object2.velocity.x = (momentum + object2.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
				#end
			}
			else if (!object1.immovable)
			{
				object1.x -= overlap;
				object1.velocity.x = vel2 - vel1 * object1.elasticity;
			}
			else if (!object2.immovable)
			{
				object2.x += overlap;
				object2.velocity.x = vel1 - vel2 * object2.elasticity;
			}
			
			// use collisionDrag properties to determine whether one object
			if (allowCollisionDrag(object1.collisionYDrag, object1, object2) && delta1 > delta2)
				object1.y += object2.y - object2.last.y;
			else if (allowCollisionDrag(object2.collisionYDrag, object2, object1) && delta2 > delta1)
				object2.y += object1.y - object1.last.y;
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * Same as `separateY` but assumes both are not immovable and not tilemaps
	 */
	static function separateYHelper(object1:FlxObject, object2:FlxObject):Bool
	{
		final overlap:Float = computeOverlapY(object1, object2);
		// Then adjust their positions and velocities accordingly (if there was any overlap)
		if (overlap != 0)
		{
			final delta1 = object1.y - object1.last.y;
			final delta2 = object2.y - object2.last.y;
			final vel1 = object1.velocity.y;
			final vel2 = object2.velocity.y;
			
			if (!object1.immovable && !object2.immovable)
			{
				#if FLX_4_LEGACY_COLLISION
				legacySeparateY(object1, object2, overlap);
				#else
				object1.y -= overlap / 2;
				object2.y += overlap / 2;
				
				final mass1 = object1.mass;
				final mass2 = object2.mass;
				final momentum = mass1 * vel1 + mass2 * vel2;
				final newVel1 = (momentum + object1.elasticity * mass2 * (vel2 - vel1)) / (mass1 + mass2);
				final newVel2 = (momentum + object2.elasticity * mass1 * (vel1 - vel2)) / (mass1 + mass2);
				object1.velocity.y = newVel1;
				object2.velocity.y = newVel2;
				#end
			}
			else if (!object1.immovable)
			{
				object1.y -= overlap;
				object1.velocity.y = vel2 - vel1 * object1.elasticity;
			}
			else if (!object2.immovable)
			{
				object2.y += overlap;
				object2.velocity.y = vel1 - vel2 * object2.elasticity;
			}
			
			// use collisionDrag properties to determine whether one object
			if (allowCollisionDrag(object1.collisionXDrag, object1, object2) && delta1 > delta2)
				object1.x += object2.x - object2.last.x;
			else if (allowCollisionDrag(object2.collisionXDrag, object2, object1) && delta2 > delta1)
				object2.x += object1.x - object1.last.x;
			
			return true;
		}
		
		return false;
	}
	
	/**
	 * The separateX that existed before HaxeFlixel 5.0, preserved for anyone who
	 * needs to use it in an old project. Does not preserve momentum, avoid if possible
	 */
	static inline function legacySeparateX(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final vel1 = object1.velocity.x;
		final vel2 = object2.velocity.x;
		final mass1 = object1.mass;
		final mass2 = object2.mass;
		object1.x = object1.x - (overlap * 0.5);
		object2.x += overlap * 0.5;
		
		var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
		var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
		final average = (newVel1 + newVel2) * 0.5;
		newVel1 -= average;
		newVel2 -= average;
		object1.velocity.x = average + (newVel1 * object1.elasticity);
		object2.velocity.x = average + (newVel2 * object2.elasticity);
	}
	
	/**
	 * The separateY that existed before HaxeFlixel 5.0, preserved for anyone who
	 * needs to use it in an old project. Does not preserve momentum, avoid if possible
	 */
	static inline function legacySeparateY(object1:FlxObject, object2:FlxObject, overlap:Float)
	{
		final vel1 = object1.velocity.y;
		final vel2 = object2.velocity.y;
		final mass1 = object1.mass;
		final mass2 = object2.mass;
		object1.y = object1.y - (overlap * 0.5);
		object2.y += overlap * 0.5;
		
		var newVel1 = Math.sqrt((vel2 * vel2 * mass2) / mass1) * ((vel2 > 0) ? 1 : -1);
		var newVel2 = Math.sqrt((vel1 * vel1 * mass1) / mass2) * ((vel1 > 0) ? 1 : -1);
		final average = (newVel1 + newVel2) * 0.5;
		newVel1 -= average;
		newVel2 -= average;
		object1.velocity.y = average + (newVel1 * object1.elasticity);
		object2.velocity.y = average + (newVel2 * object2.elasticity);
	}
	
	/**
	 * Checks two objects for overlaps and sets their touching flags, accordingly.
	 * If either object may be a tilemap, this will check the object against individual tiles
	 * 
	 * @return  Whether the objects in fact touched
	 */
	public static function updateTouchingFlags(object1:FlxObject, object2:FlxObject):Bool
	{
		function helper(object1:FlxObject, object2:FlxObject):Bool
		{
			final touchingX:Bool = updateTouchingFlagsXHelper(object1, object2);
			final touchingY:Bool = updateTouchingFlagsYHelper(object1, object2);
			return touchingX || touchingY;
		}
		return processCheckTilemap(object1, object2, helper, false);
	}
	
	/**
	 * Checks two objects for overlaps in the X-axis and sets their touching flags, accordingly.
	 * If either object may be a tilemap, this will check the object against individual tiles
	 * 
	 * @return  Whether the objects are overlapping in the X-axis
	 */
	public static function updateTouchingFlagsX(object1:FlxObject, object2:FlxObject):Bool
	{
		return processCheckTilemap(object1, object2, updateTouchingFlagsXHelper, false);
	}
	
	static function updateTouchingFlagsXHelper(object1:FlxObject, object2:FlxObject):Bool
	{
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapX(object1, object2, false) != 0;
	}
	
	/**
	 * Checks two objects for overlaps in the Y-axis and sets their touching flags, accordingly.
	 * If either object may be a tilemap, this will check the object against individual tiles
	 *
	 * @return  Whether the objects are overlapping in the Y-axis
	 */
	public static function updateTouchingFlagsY(object1:FlxObject, object2:FlxObject):Bool
	{
		return processCheckTilemap(object1, object2, updateTouchingFlagsYHelper, false);
	}
	
	static function updateTouchingFlagsYHelper(object1:FlxObject, object2:FlxObject):Bool
	{
		// Since we are not separating, always return any amount of overlap => false as last parameter
		return computeOverlapY(object1, object2, false) != 0;
	}
	
	/**
	 * Internal function that computes overlap among two objects on the X axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateX` code.
	 */
	public static function computeOverlapX(object1:FlxObject, object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		final delta1:Float = object1.x - object1.last.x;
		final delta2:Float = object2.x - object2.last.x;

		if (delta1 != delta2)
		{
			// Check if the X hulls actually overlap
			final delta1Abs:Float = (delta1 > 0) ? delta1 : -delta1;
			final delta2Abs:Float = (delta2 > 0) ? delta2 : -delta2;

			final rect1 = FlxRect.get(object1.x - (delta1 > 0 ? delta1 : 0), object1.last.y, object1.width + delta1Abs, object1.height);
			final rect2 = FlxRect.get(object2.x - (delta2 > 0 ? delta2 : 0), object2.last.y, object2.width + delta2Abs, object2.height);
			
			if (rect1.overlaps(rect2))
			{
				final maxOverlap:Float = checkMaxOverlap ? (delta1Abs + delta2Abs + SEPARATE_BIAS) : 0;
				
				inline function canCollide(obj:FlxObject, dir:FlxDirectionFlags)
				{
					return obj.allowCollisions.has(dir);
				}
				
				// If they do overlap (and can), figure out by how much and flip the corresponding flags
				if (delta1 > delta2)
				{
					overlap = object1.x + object1.width - object2.x;
					if ((checkMaxOverlap && overlap > maxOverlap)
						|| !canCollide(object1, FlxDirectionFlags.RIGHT)
						|| !canCollide(object2, FlxDirectionFlags.LEFT))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.RIGHT;
						object2.touching |= FlxDirectionFlags.LEFT;
					}
				}
				else if (delta1 < delta2)
				{
					overlap = object1.x - object2.width - object2.x;
					if ((checkMaxOverlap && -overlap > maxOverlap)
						|| !canCollide(object1, FlxDirectionFlags.LEFT)
						|| !canCollide(object2, FlxDirectionFlags.RIGHT))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.LEFT;
						object2.touching |= FlxDirectionFlags.RIGHT;
					}
				}
			}
			
			rect1.put();
			rect2.put();
		}
		
		return overlap;
	}
	
	/**
	 * Internal function that computes overlap among two objects on the Y axis. It also updates the `touching` variable.
	 * `checkMaxOverlap` is used to determine whether we want to exclude (therefore check) overlaps which are
	 * greater than a certain maximum (linked to `SEPARATE_BIAS`). Default is `true`, handy for `separateY` code.
	 */
	public static function computeOverlapY(object1:FlxObject, object2:FlxObject, checkMaxOverlap:Bool = true):Float
	{
		var overlap:Float = 0;
		// First, get the two object deltas
		final delta1:Float = object1.y - object1.last.y;
		final delta2:Float = object2.y - object2.last.y;

		if (delta1 != delta2)
		{
			// Check if the Y hulls actually overlap
			final delta1Abs:Float = (delta1 > 0) ? delta1 : -delta1;
			final delta2Abs:Float = (delta2 > 0) ? delta2 : -delta2;
			
			final rect1 = FlxRect.get(object1.last.x, object1.y - (delta1 > 0 ? delta1 : 0), object1.width, object1.height + delta1Abs);
			final rect2 = FlxRect.get(object2.last.x, object2.y - (delta2 > 0 ? delta2 : 0), object2.width, object2.height + delta2Abs);

			if (rect1.overlaps(rect2))
			{
				final maxOverlap:Float = checkMaxOverlap ? (delta1Abs + delta2Abs + SEPARATE_BIAS) : 0;
				
				inline function canCollide(obj:FlxObject, dir:FlxDirectionFlags)
				{
					return obj.allowCollisions.has(dir);
				}
				
				// If they did overlap (and can), figure out by how much and flip the corresponding flags
				if (delta1 > delta2)
				{
					overlap = object1.y + object1.height - object2.y;
					if ((checkMaxOverlap && (overlap > maxOverlap))
						|| !canCollide(object1, FlxDirectionFlags.DOWN)
						|| !canCollide(object2, FlxDirectionFlags.UP))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.DOWN;
						object2.touching |= FlxDirectionFlags.UP;
					}
				}
				else if (delta1 < delta2)
				{
					overlap = object1.y - object2.height - object2.y;
					if ((checkMaxOverlap && (-overlap > maxOverlap))
						|| !canCollide(object1, FlxDirectionFlags.UP)
						|| !canCollide(object2, FlxDirectionFlags.DOWN))
					{
						overlap = 0;
					}
					else
					{
						object1.touching |= FlxDirectionFlags.UP;
						object2.touching |= FlxDirectionFlags.DOWN;
					}
				}
			}
			
			rect1.put();
			rect2.put();
		}
		
		return overlap;
	}
}
