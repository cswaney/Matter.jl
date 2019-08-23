mutable struct Body
    id  # nextid()
    type  # Body
    label::String  # "Body"
    parts  # []
    plugin  # {}
    angle  # 0.0
    vertices::Array{Vertices,1}
    position  # (x = 0.0, y = 0.0)
    force  # (x = 0.0, y = 0.0)
    torque  # 0.0
    position_impulse  # (x = 0.0, y = 0.0)
    constraint_impulse  # (x = 0.0, y = 0.0)
    total_contacts::Int  # 0
    speed  # 0.0
    angular_speed  # 0.0
    velocity  # (x = 0.0, y = 0.0)
    angular_velocity  # 0.0
    is_sensor::Bool  # false
    is_sleeping::Bool  # false
    motion  # 0.0
    sleep_threshold  # 60.0
    density  # 0.001
    restitution  # 0.0
    friction  # 0.1
    friction_static  # 0.5
    friction_air  # 0.01
    collision_filter  # (category = 0x0001, mask = 0xFFFFFFFF, group = 0)
    slop  # 0.05
    time_scale  # 1.0
    render
    events
    bounds
    chamfer
    circle_radius
    position_prev
    angle_prev
    parent
    axes
    area
    mass
    inertia
    original
end

function next_group(b::Body, is_noncolliding)
    if is_noncolliding
        nng = b.next_noncolliding_group
        b.next_noncolliding_group -= 1
        return nng
    else
        ncg = b.next_colliding_group
        b.next_colliding_group += 1
        return ncg
    end
end

function next_category(b::Body)
    b.next_category <<= 1
    return b.next_category
end

# setters
function set_static!(b::Body, is_static)
    for i, part in enumerate(b.parts)
        part.is_static = is_static
        if is_static
            part.original = (
                restitution=part.restitution,
                friction=part.friction,
                mass=part.mass,
                inertia=part.inertia,
                density=part.density,
                inverse_mass=part.inverse_mass,
                inverse_inertia=part.inverse_inertia
            )
            part.restitution = 0.0
            part.friction = 1.0
            part.mass = part.inertia = part.density = Inf
            part.inverse_mass = part.inverse_inertia = 0.0
            part.position_prev = part.position
            part.angle_prev = part.angle
            part.angular_velocity = 0.0
            part.speed = 0.0
            part.angular_speed = 0.0
            part.motion = 0.0
        elseif ~(part.original == nothing)
            part.restitution = part.original.restitution;
            part.friction = part.original.friction;
            part.mass = part.original.mass;
            part.inertia = part.original.inertia;
            part.density = part.original.density;
            part.inverse_mass = part.original.inverse_mass;
            part.inverse_inertia = part.original.inverse_inertia;
            part.original = nothing;
        end
    end
end

function set_mass!(b::Body, mass)
    moment = b.inertia / (b.mass / 6.)
    b.inertia = moment * (mass / 6.)
    b.inverse_inertia = 1. / b.inertia
    b.mass = mass
    b.inverse_mass = 1. / b.mass
    b.density = b.mass / b.area
end

function set_density!(b::Body, density)
    b.set_mass!(body, density * b.area)
    b.density = density
end

function set_inertia!(b::Body, inertia)
    b.inertia = inertia
    b.inverse_inertia = 1. / b.inertia
end

function set_vertices!(b::Body, vertices)

    # update body vertices
    if vertices[0].b === b
        b.vertices = vertices
    else
        b.vertices = Vertices(vertices, b)
    end

    # update body properties
    b.axes = Axes(b.vertices)
    b.area = area(b.vertices)
    set_mass!(b, b.density * b.area)

    # re-orient vertices around center of mass at origin (0, 0)
    c = center(b.vertices)
    translate!(b.vertices, c, -1)

    # update inertia while vertices are at origin (0, 0)
    b.set_inertia!(b, b.inertia_scale * inertia(b.vertices, b.mass))

    # update geometry
    translate!(b.vertices, b.position)
    update!(b.bounds, b.vertices, b.velocity)
end

function set_parts!(b::Body, parts, auto_hull = true)

    # add parts to body, ensuring first part is the parent body
    for i, part in enumerate(parts)
        if part !== b
            part.parent = b
            push!(b.parts, part)
        end
    end

    b.parts.length == 1 && return

    # find the convex hull of parts
    if auto_hull
        vertices = []
        for i, part in enumerate(parts)
            append!(vertices, part.vertices)
        end
        sort!(vertices)
        hull = hull(vertices)
        hull_center = center(hull)
        set_vertices!(b, hull)
        translate!(b.vertices, hull_center)
    end

    # sum the properties
    total = total_properties(b)
    b.area = total.area
    b.parent = b
    b.position = total.center
    b.position_prev = total.center
    set_mass!(b, total.mass)
    set_inertia!(b, total.inertia)
    set_position!(b, total.center)
end

function set_center!(b::Body, center, relative)
    if ~relative
        b.position_prev = (
            x = center.x - b.position.x + b.position_prev.x,
            y = center.y - b.position.y + b.position_prev.y
        )
        b.position = (
            x = center.x,
            y = center.y
        )
    else
        b.position_prev = (
            x = b.position_prev.x + center.x,
            y = b.position_prev.y + center.y
        )
        b.position = )
            x = b.position.x + center.x,
            y = b.position.y + center.y
        )
    end
end

function set_position!(b::Body, position)
    delta = position - b.position
    b.position_prev += delta
    for part in b.parts
        part.position += delta
        translate!(part.vertices, delta)
        update!(part.bounds, part.vertices, b.velocity)
    end
end

function set_angle!(b::Body, angle)
    delta = angle - b.angle
    b.angle_prev += delta
    for i, part in enumerate(b.parts)
        part.angle += delta
        rotate!(part.vertices, delta, b.position)
        rotate!(part.axes, delta)
        update!(part.bounds, part.vertices, b.velocity)
        if i > 0
            rotate_about!(part.position, delta, b.position, part.position)
        end
    end
end

function set_velocity!(b::Body, velocity)
    b.position_prev = b.position - velocity
    b.velocity = velocity
    b.speed = magnitude(b.velocity)
end

function set_angular_velocity!(b::Body, velocity)
    b.angle_prev = b.angle - velocity
    b.angular_velocity = velocity
    b.angular_speed = abs(b.angular_velocity)
end

translate!(b::body, tranlation) = set_position!(b, body.position + translation)

rotate!(b::Body, rotation) = set_angle!(b, b.angle + rotation)

function rotate!(b::Body, rotation, point)
    dx = b.position.x - point.x
    dy = b.position.y - point.y
    x = point.x + (dx * cos(rotation) - dy * sin(rotation))
    y = point.y + (dx * sin(rotation) + dy * cos(rotation))
    set_position!(b, [x, y])
    set_angle!(b, b.anlge + rotation)
end

# TODO
function scale!(b::Body, scale, point)
    @error "Not Implemented"
end

# TODO
function update!(b::Body, dt, ts, correction)
    @error "Not Implemented"
end

# TODO
function apply_force!(b::Body, force, position)
    @error "Not Implemented"
end

function total_properties(b::Body)

    # initialize aggregate properties
    properties = Dict(
        :mass => 0.0,
        :area => 0.0,
        :inertia => 0.0,
        :center => [0., 0.]
    )

    for part in b.parts
        mass = isinf(part.mass) ? 1 : part.mass
        properties[:mass] += mass
        properties[:area] += part.area
        properties[:inertia] += part.inertia
        properties[:center] += part.position * mass
    end

    properties.center /= properties.mass
    return properties
end
