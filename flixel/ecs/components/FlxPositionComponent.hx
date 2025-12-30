package flixel.ecs.components;

/**
 * A component representing a 2D position.
 */
class FlxPositionComponent extends FlxComponent
{
    /**
     * The horizontal position of this object, in 2D space, starting from the left.
     */
    public var x:Float;

    /**
     * The vertical position of this object, in 2D space, starting from the top.
     */

    public var y:Float;

    /**
     * The last horizontal position of this object, in 2D space, from the previous frame.
     */
    public var lastX:Null<Float>;

    /**
     * The last vertical position of this object, in 2D space, from the previous frame.
     */
    public var lastY:Null<Float>;

    public function new(x:Float = 0, y:Float = 0)
    {
        super();

        this.x = x;
        this.y = y;
    }
    
    public inline function set(x:Float, y:Float):Void
    {
        this.x = x;
        this.y = y;
    }

    public inline function setLast(x:Float, y:Float):Void
    {
        lastX = x;
        lastY = y;
    }
}