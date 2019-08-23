using Matter

import Matter.Particle, Matter.Vector

position = Vector(0., 0.)
velocity = Vector(0., 0.)
gravity = Vector(0., -10.)
damping = 0.995
mass = 2.

p = Particle(position, velocity, gravity, damping, 1. / mass)

for step in 1:10
    dt = 0.033
    Matter.integrate!(p, dt)
    print(p.position)
end
