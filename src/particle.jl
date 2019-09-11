import Matter.Vector

mutable struct Particle
    position::Vector
    velocity::Vector
    acceleration::Vector
    force::Vector
    damping
    inverse_mass
end

function update_position!(p::Particle, dt)
    p.position += p.velocity * dt
    return p
end

function update_velocity!(p::Particle, dt)
    p.velocity += p.acceleration * dt
    p.velocity *= p.damping ^ dt
    return p
end

function update_acceleration!(p::Particle)
    """Update particle acceleration by applying new forces."""
    p.acceleration += p.force * p.inverse_mass
    return p
end

function add_force!(p::Particle, force::Vector)
    p.force += force
    return p
end

function reset_force!(p::Particle)
    p.force = Vector()
    return p
end

function integrate!(p::Particle, dt)
    @assert dt > 0.0 "Integration requires positive timestep (dt > 0.0)"
    update_acceleration!(p)
    update_position!(p, dt)
    update_velocity!(p, dt)
    reset_force!(p)
    return p
end
