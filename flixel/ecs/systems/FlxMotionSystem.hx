package flixel.ecs.systems;

import flixel.ecs.components.FlxMotionComponent;
import flixel.ecs.data.FlxSystemPhase;
import flixel.math.FlxVelocity;

class FlxMotionSystem extends FlxComponentSystem
{
    public function new()
    {
        super(FlxSystemPhase.PRE_UPDATE);
    }

    override public function update(phase:FlxSystemPhase, elapsed:Float):Void
    {
        for (motion in getComponentsOfType(FlxMotionComponent))
        {
            var entity = cast(motion.parent, FlxObject);

            if (entity.moves)
            {
                var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(motion.angularVelocity, motion.angularAcceleration, motion.angularDrag, motion.maxAngular, elapsed) - motion.angularVelocity);
                motion.angularVelocity += velocityDelta;
                entity.angle += motion.angularVelocity * elapsed;
                motion.angularVelocity += velocityDelta;

                velocityDelta = 0.5 * (FlxVelocity.computeVelocity(motion.velocity.x, motion.acceleration.x, motion.drag.x, motion.maxVelocity.x, elapsed) - motion.velocity.x);
                motion.velocity.x += velocityDelta;
                var delta = motion.velocity.x * elapsed;
                motion.velocity.x += velocityDelta;
                entity.x += delta;

                velocityDelta = 0.5 * (FlxVelocity.computeVelocity(motion.velocity.y, motion.acceleration.y, motion.drag.y, motion.maxVelocity.y, elapsed) - motion.velocity.y);
                motion.velocity.y += velocityDelta;
                delta = motion.velocity.y * elapsed;
                motion.velocity.y += velocityDelta;
                entity.y += delta;
            }
        }
        
    }
    
}