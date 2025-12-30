package flixel.ecs.data;

enum abstract FlxSystemPhase(Int) from Int to Int
{
    /**
     *  Logic that runs before the state update
     */
    var PRE_UPDATE = 0x10;
    
    /*
     * Logic that runs after the state update
     */
    var POST_UPDATE = 0x01;

}