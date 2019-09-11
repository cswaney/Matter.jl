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

# TODO
function rotate!(v::Vector, angle)
    # x = v.x * cos(angle) - v.y * sin(angle)
    # y = v.x * sin(angle) + v.y * cos(angle)
    # v.x = x
    # v.y = y
end

# TODO
function rotate!(v::Vector, angle, point)
end

# TODO
function angle(v::Vector)
end
