package flixel.ecs.components;

/**
 * A component representing a 2D position.
 */
class FlxPositionComponent extends FlxComponent
{
    public var x:Float;
    public var y:Float;

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
}