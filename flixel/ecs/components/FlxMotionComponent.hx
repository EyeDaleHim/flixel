package flixel.ecs.components;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

class FlxMotionComponent extends FlxComponent
{
    /**
     * The speed of the object in pixels per second.
     */
    public var velocity:FlxPoint;

    /**
     * The rate at which `velocity` will change in pixels per second.
     */
    public var acceleration:FlxPoint;

    /**
     * When `acceleration` is 0, `velocity` will slow by this amount, in pixels per second.
     * When less than or equal to 0, no drag is applied.
     */
    public var drag:FlxPoint;

    /**
     * The maximum `velocity` (or negative `velocity`) this object can have.
     */
    public var maxVelocity:FlxPoint;

    /**
     * The rotational speed of the object in degrees per second.
     */
    public var angularVelocity:Float = 0;

    /**
     * The rate at which `angularVelocity` will change in degrees per second.
     */
    public var angularAcceleration:Float = 0;

    /**
     * When `angularAcceleration` is 0, `angularVelocity` will slow by this amount, in degrees per second.
     * When less than or equal to 0, no drag is applied.
     */
    public var angularDrag:Float = 0;

    /**
     * The maximum `angularVelocity` (or negative `angularVelocity`) this object can have.
     */
    public var maxAngular:Float = 10000;

    /**
     * The elasticity of the object. A value of 1 means that the object will retain 100% of its velocity
     * after a collision, while 0 means it will lose all of it.
     */
    public var elasticity:Float = 0;

    /**
     * How much this object can be pushed around by other objects.
     * A higher mass means it will be harder to push.
     */
    public var mass:Float = 1;

    /**
     * Set to `true` to keep this object from moving when it collides with other objects.
     */
    public var immovable:Bool = false;

    public function new()
    {
        super();

        velocity = FlxPoint.get();
        acceleration = FlxPoint.get();
        drag = FlxPoint.get();
        maxVelocity = FlxPoint.get(10000, 10000);
    }

    override public function destroy()
    {
        velocity = FlxDestroyUtil.put(velocity);
        acceleration = FlxDestroyUtil.put(acceleration);
        drag = FlxDestroyUtil.put(drag);
        maxVelocity = FlxDestroyUtil.put(maxVelocity);

        super.destroy();
        
    }
}