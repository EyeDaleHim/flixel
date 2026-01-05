package flixel.ecs.components;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;

/**
 * Stores all the data required for a `FlxSprite` to be drawn, but only the color aspects.
 * This includes things like `alpha`, `color`, and `blend`.
 */
class FlxColorComponent extends FlxComponent
{
	/**
	 * Set alpha to a number between `0` and `1` to change the opacity of the sprite. Calling
	 * `setColorTransform` will also change this value
	 * 
	 * **NOTE:** This value is automatically clamped to 0 <= a <= 1
	 * @see https://snippets.haxeflixel.com/sprites/alpha/
	 */
	public var alpha(default, set):Float = 1.0;
	
	/**
	 * Blending modes, just like Photoshop or whatever, e.g. "multiply", "screen", etc.
	 */
	public var blend:BlendMode;
	
	/**
	 * Multiplies this sprite's image by the given red, green and blue components, alpha is ignored.
	 * To change the opacity use `alpha`. Calling `setColorTransform` will also change this value.
	 * @see https://snippets.haxeflixel.com/sprites/color/
	 */
	public var color(default, set):FlxColor = FlxColor.WHITE;
	
	/**
	 * The color effects of this sprite, changes to `color` or `alpha` will be reflected here
	 */
	public var colorTransform(default, null) = new ColorTransform();
	
	public function new(alpha:Float = 1.0, color:FlxColor = FlxColor.WHITE)
	{
		super();
		
		this.alpha = alpha;
		this.color = color;
	}
	
	/**
	 * Sets the sprite's color transformation with control over color offsets.
	 * With `FlxG.renderTile`, offsets are only supported on OpenFL Next version 3.6.0 or higher.
	 *
	 * @param   redMultiplier     The value for the red multiplier, in the range from `0` to `1`.
	 * @param   greenMultiplier   The value for the green multiplier, in the range from `0` to `1`.
	 * @param   blueMultiplier    The value for the blue multiplier, in the range from `0` to `1`.
	 * @param   alphaMultiplier   The value for the alpha transparency multiplier, in the range from `0` to `1`.
	 * @param   redOffset         The offset value for the red color channel, in the range from `-255` to `255`.
	 * @param   greenOffset       The offset value for the green color channel, in the range from `-255` to `255`.
	 * @param   blueOffset        The offset for the blue color channel value, in the range from `-255` to `255`.
	 * @param   alphaOffset       The offset for alpha transparency channel value, in the range from `-255` to `255`.
	 */
	public function setColorTransform(redMultiplier = 1.0, greenMultiplier = 1.0, blueMultiplier = 1.0, alphaMultiplier = 1.0,
			redOffset = 0.0, greenOffset = 0.0, blueOffset = 0.0, alphaOffset = 0.0):Void
	{
		alphaMultiplier = FlxMath.bound(alphaMultiplier, 0, 1);
		@:bypassAccessor color = FlxColor.fromRGBFloat(redMultiplier, greenMultiplier, blueMultiplier, 1.0);
		@:bypassAccessor alpha = alphaMultiplier;
		
		colorTransform.setMultipliers(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier);
		colorTransform.setOffsets(redOffset, greenOffset, blueOffset, alphaOffset);
	}
	
	public function updateColorTransform():Void
	{
		colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, alpha);
	}
	
	/**
	 * Whether this sprite has a color transform, menaing any of the following: less than full
	 * `alpha`, a `color` tint, or a `colorTransform` whos values are not the default.
	 */
	public function hasColorTransform()
	{
		return alpha != 1 || color.rgb != 0xffffff || colorTransform.hasRGBAOffsets();
	}
	
	function set_alpha(value:Float):Float
	{
		value = FlxMath.bound(value, 0, 1);
		if (alpha == value)
			return value;
			
		alpha = value;
		updateColorTransform();
		return alpha;
	}
	
	function set_color(value:FlxColor):FlxColor
	{
		if (color == value)
			return value;
			
		color = value;
		updateColorTransform();
		return color;
	}
}
