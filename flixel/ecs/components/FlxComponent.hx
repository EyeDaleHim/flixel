package flixel.ecs.components;

import flixel.FlxBasic;
import flixel.util.FlxDestroyUtil;

/**
 * A logic/data unit that can be attached to any FlxBasic.
 */
@:allow(flixel.FlxBasic)
class FlxComponent implements IFlxDestroyable
{
    /**
     * The parent object this component is attached to.
     */
    public var parent(default, null):FlxBasic;

    public function new() {}

    /**
     * Internal lifecycle hook for attachment logic.
     */
    @:allow(flixel.FlxBasic)
    function setParent(basic:FlxBasic):Void
    {
        parent = basic;
        onAdd();
    }

    /**
     * Override to initialize logic when added to an entity.
     */
    public function onAdd():Void {}

    /**
     * Override to cleanup logic when removed from an entity.
     */
    public function onRemove():Void {}

    public function destroy():Void
    {
        onRemove();
        parent = null;
    }
}