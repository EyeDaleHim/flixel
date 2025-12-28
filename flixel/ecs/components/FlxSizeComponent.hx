package flixel.ecs.components;

/**
 * A component representing a 2D rectangle.
 */
class FlxSizeComponent extends FlxComponent
{
    public var width:Float;
    public var height:Float;

    public function new(width:Float = 0, height:Float = 0)
    {
        super();
        this.width = width;
        this.height = height;
    }
    
    public inline function set(width:Float, height:Float):Void
    {
        this.width = width;
        this.height = height;
    }
}