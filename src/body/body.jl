mutable struct Body
    vertices

    position
    velocity

    angle  # orientation
    angular_velocity

    force
    torque

    restitution
    friction

    mass
    inertia
end

"""
    translate!(body::Body, translation::Vector)

Translate a body by a given vector without imparting velocity.
"""
function translate!(body::Body, translation::Vector)
    body.position += translation
end

"""
    rotate!(body::Body, rotation)

Rotate a body by a given angle without imparting angular velocity.
"""
function rotate!(body::Body, rotation)
    body.angle += rotation
end


"""
    update!(body::Body, dt)

Update the position, velocity, angle, and angular velocity of the body.
"""
function update!(body::Body, dt)

    # update velocity
    body.velocity.x += (body.force.x / body.mass) * dt
    body.velocity.y += (body.force.y / body.mass) * dt

    # TODO: add friction/drag

    # update position
    body.position.x += body.velocity.x
    body.position.y += body.velocity.y

    # update angular velocity
    body.angular_velocity += (body.torque / body.inertia) * dt

    # TODO: add friction/drag

    # update angle
    body.angle += body.angular_velocity

    # update vertices
    translate!(body.vertices, body.velocity)
    rotate!(body.vertices, body.angular_velocity)
end

"""
    apply_force!(body::Body, force, position)

Apply a force to a body at a given position.
"""
function apply_force!(b::Body, force, position)
    body.force += force
    offset = position - body.position
    body.torque += offset × force  # "cross product" = "determinant"
end
