package flixel.ecs.components;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

class FlxTransformComponent extends FlxComponent
{
	/**
	 * The x/y coordinates of the object.
	 */
	public var position:FlxPoint;
	
	/**
	 * The previous x/y coordinates of the object.
	 */
	public var last:FlxPoint;
	
	/**
	 * The width/height of the object.
	 */
	public var size:FlxPoint;
	
	/**
	 * The angle of the object, note that this is only
	 * visual.
	 */
	public var angle:Float = 0;
	
	/**
	 * Whether or not the position of this object should be rounded before any `draw()` or collision checking.
	 */
	public var pixelPerfectPosition:Bool;
	
	/**
	 * Controls how much this object is affected by camera scrolling. `0` = no movement (e.g. a background layer),
	 * `1` = same movement speed as the foreground. Default value is `(1,1)`,
	 * except for UI elements like `FlxButton` where it's `(0,0)`.
	 */
	public var scrollFactor:FlxPoint;

	/**
	 * Change the size of your sprite's graphic.
	 * NOTE: `size` does not get adjusted, use `getFinalSize()` for that.
	 * **WARNING:** With `FlxG.renderBlit`, scaling sprites decreases rendering performance by a factor of about x10!
	 * @see https://snippets.haxeflixel.com/sprites/scale/
	 */
	public var scale:FlxPoint;
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
		super();
		
		weak(x, y, width, height);
		
		pixelPerfectPosition = FlxObject.defaultPixelPerfectPosition;
	}
	
	/**
	 * Only initializes the hitbox variables.
	 */
	public inline function weak(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0):Void
	{
		position = FlxPoint.get(x, y);
		last = FlxPoint.get(x, y);
		size = FlxPoint.get(width, height);
	}
	
	/**
	 * Initializes all the variables that can affect visuals.
	 */
	public inline function strong(scrollX:Float = 1.0, scrollY:Float = 1.0, scaleX:Float = 1.0, scaleY:Float = 1.0):Void 
	{
		scrollFactor = FlxPoint.get(scrollX, scrollY);
		scale = FlxPoint.get(scaleX, scaleY);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		position = FlxDestroyUtil.put(position);
		size = FlxDestroyUtil.put(size);
		scrollFactor = FlxDestroyUtil.put(scrollFactor);
		last = FlxDestroyUtil.put(last);
	}

	public function getFinalSize():FlxPoint
	{
		if (scale == null)
			return size;
		
		return FlxPoint.get(size.x * scale.x, size.y * scale.y);	
	}

	public function getFinalHitbox():FlxRect
	{
		if (scale == null)
			return FlxRect.get(position.x, position.y, size.x, size.y);
		
		return FlxRect.get(position.x, position.y, size.x * scale.x, size.y * scale.y);
	}
	
	public inline function set(x:Float, y:Float):Void
	{
		position.set(x, y);
	}
	
	public inline function setSize(width:Float, height:Float):Void
	{
		size.set(width, height);
	}
	
	public inline function setRect(x:Float, y:Float, width:Float, height:Float):Void
	{
		position.set(x, y);
		size.set(width, height);
	}
}
