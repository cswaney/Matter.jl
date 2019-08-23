mutable struct Engine
    position_iterations  # 6,
    velocity_iterations  # 4,
    constraint_iterations  # 2,
    enable_sleeping  # false,
    events
    plugin
    timing
    broadphase
    world
    pairs
    metrics
end

function update!(e::Engine, delta, correction)
    delta = delta || 1000. / 60.
    correction = correction || 1.

    world = e.world
    timing = e.timing
    broadphase = e.broadphase
    broadphase_pairs = []

    timing.timestamp += delta * timing.time_scale

    event = {
        :timestamp => timing.timestamp
    }

    trigger!(e, 'before_update', event)

    all_bodies = get_bodies(world)
    all_contraints = get_constraints(world)

    if engine.enable_sleeping
        update!(all_bodies, timing.time_scale)
    end

    apply_gravity!(all_bodies, world.gravity)
    update!(all_bodies, delta, timing.time_scale, correction, world.bounds)
    presolve!(all_bodies)
    for i in 1:e.constraint_iterations
        solve_all!(all_contraints, timing.time_scale)
    end

    if broadphase.controller
        if world.is_modified
            clear!(broadphase.controller, broadphase)
        end

        update!(broadphase.controller, broadphase, all_bodies, e, world.is_modified)
        broadphase_pairs = broadphase.pairs_list
    else
        broadphase_pairs = all_bodies
    end

    if world.is_modified
        set_modified!(world, false, false, true)
    end

    collisions = detect(broadphase, broadphase_pairs, e)

    pairs = e.pairs
    timestamp = timing.timestamp
    update!(pairs, collisions, timestamp)
    remove_old!(pairs, timestamp)

    if e.enable_sleeping
        after_collisions(pairs.list, timing.time_scale)
    end

    if pairs.collision_start.length > 0
        trigger!(e, 'collision_start', Dict(:pairs => pairs.collision_start))
    end

    presolve_position!(pairs.list)
    for _ in 1:e.position_iterations
        solve_position!(pairs.list, all_bodies, timing.time_scale)
    end
    postsolve_position!(all_bodies)

    presolve!(all_bodies)
    for _ in 1:e.constraint_iterations
        solve!(all_contraints, timing.time_scale)
    end
    postsolve!(all_bodies)

    presolve_velocity!(pairs.list)
    for _ in 1:e.velocity_iterations
        solve_velocity!(pairs,list, timing.time_scale)
    end

    if pairs.collision_active.length > 0
        trigger!(e, 'collision_active', Dict(:pairs => pairs.collision_active))
    end

    if length(pairs.collision_end) > 0
        trigger!(e, 'collision_end', Dict(:pairs => pairs.collision_end))
    end

    clear_forces!(all_bodies)
    trigger!(engine, 'after_update', event)

    return e
end

# TODO
function merge!(eA::Engine, eB::Engine)
    @error "Not Implemented"
end

function clear!(e::Engine)
    world = e.world
    clear!(e.pairs)
    broadphase = e.broadphase
    if broadphase.controller != nothing
        bodies = get_bodies(world)
        clear!(broadphase.controller, broadphase)
        update!(broadphase.controller, bodies, e, true)
    end
end

function clear_forces!(bodies)
    for body in bodies
        body.force.x = 0.0
        body.force.y = 0.0
        body.torque = 0.0
    end
end

function apply_gravity!(bodies, gravity = 0.001)
    gravity.x == 0.0 && gravity.y == 0.0) && return
    gravity.scale == 0.0 && return

    for body in bodies
        body.is_static || body.is_sleeping && continue
        body.force.x += body.mass * gravity.x * gravity.scale
        body.force.y += body.mass * gravity.y * gravity.scale
    end
end

function update!(bodies, delta_time, time_scale, correction, world_bounds)
    for body in bodies
        body.is_static || body.is_sleeping && continue
        update!(body, delta_time, time_scale, correction)
    end
end
