"""Vector geometry."""

mutable struct Vector
    x
    y
end

Vector() = Vector(0.0, 0.0)

import Base.+, Base.-, Base.*, Base./, Base.==
add(a::Vector, b::Vector) = Vector(a.x + b.x, a.y + b.y)
sub(a::Vector, b::Vector) = Vector(a.x - b.x, a.y - b.y)
mult(a::Vector, scalar) = Vector(a.x * scalar, a.y * scalar)
div(a::Vector, scalar) = Vector(a.x / scalar, a.y / scalar)
neg(v::Vector) = mult(v, -1)
(+)(a::Vector, b::Vector) = add(a, b)
(-)(a::Vector, b::Vector) = sub(a, b)
(*)(a::Vector, scalar) = mult(a, scalar)
(/)(a::Vector, scalar) = div(a, scalar)
(-)(v::Vector) = neg(v)
function (==)(a::Vector, b::Vector)
    a.x == b.x && a.y == b.y && return true
    return false
end

function add!(a::Vector, b::Vector)
    a.x += b.x
    a.y += b.y
    return a
end

function sub!(a::Vector, b::Vector)
    a.x -= b.x
    a.y -= b.y
    return a
end

function mult!(v::Vector, scalar)
    v.x *= scalar
    v.y *= scalar
    return v
end

function div!(v::Vector, scalar)
    v.x /= scalar
    v.y /= scalar
    return v
end

magnitude(v::Vector) = sqrt(v.x * v.x + v.y * v.y)

function normalize!(v::Vector)
    m = magnitude(v)
    if m == 0
        v.x = 0.0
        v.y = 0.0
    else
        v.x /= m
        v.y /= m
    end
    return v
end

dot(a::Vector, b::Vector) = a.x * b.x + a.y * b.y
det(a::Vector, b::Vector) = a.x * b.y - a.y * b.x
cross(v::Vector) = Vector(-v.x, v.y)

function rotate!(v::Vector, angle)
    angle == 0. && return
    dx = v.x
    dy = v.y
    v.x = dx * cos(angle) - dy * sin(angle)
    v.y = dx * sin(angle) + dy * cos(angle)
    return v
end

function rotate!(v::Vector, angle, point)
    angle == 0. && return
    dx = v.x - point.x
    dy = v.y - point.y
    v.x = point.x + (dx * cos(angle) - dy * sin(angle))
    v.y = point.y + (dx * sin(angle) + dy * cos(angle))
    return v
end
