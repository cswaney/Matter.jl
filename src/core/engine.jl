mutable struct Engine
    position_iterations
    velocity_iterations
    constraint_iterations
    timestep
    timestamp
    world
end

function Engine()
    position_iterations = 6
    velocity_iterations = 4
    constraint_iterations = 2
    world = World()
    return Engine(
        position_iterations,
        velocity_iterations,
        constraint_iterations,
        1,
        0,
        world)
end

# TODO
function update!(engine, dt)

    world = engine.world
    broadphase = engine.broadphase

    # update timestamp
    engine.timestamp += dt * engine.timestep

    # apply gravity to all bodies in world
    apply!(world.bodies, world.gravity)

    # ...


    # narrowphase pass
    collisions = detect!(broadphase, broadphase_pairs, engine)
    update!(engine.pairs, collisions, engine.timestamp)
    remove_old!(engine.pairs, engine.timestamp)

    # ...



    clear_forces!(engine.bodies)
end

function _clear_forces!(bodies)
    for body in bodies
        body.force = Vector(0., 0.)
        body.torque = 0.
    end
end

function _update!(bodies, dt)
    for body in bodies
        update!(body, dt)
    end
end
