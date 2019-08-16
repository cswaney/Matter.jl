"""Vector geometry."""

# TODO: overload aritmetic operators to handle Vector

mutable struct Vector
    x
    y
end

Vector() = Vector(0.0, 0.0)

magnitude(v::Vector) = sqrt(v.x * v.x + v.y * v.y)

norm(v::Vector) = v.x * v.x + v.y * v.y

function rotate!(v::Vector, angle)
    # TODO
    # x = v.x * cos(angle) - v.y * sin(angle)
    # y = v.x * sin(angle) + v.y * cos(angle)
    # v.x = x
    # v.y = y
end

function rotate!(v::Vector, angle, point)
    # TODO
end

function normalize!(v::Vector)
    m = magnitude(v)
    if m == 0
        v.x = 0.0
        v.y = 0.0
    else
        v.x /= m
        v.y /= m
    end
end

dot(vA::Vector, vB::Vector) = vA.x * vB.x + vA.y * vB.y

cross(vA::Vector, vB::Vector) = vA.x * vB.y - vA.y * vB.x

function cross(vA::Vector, vB::Vector, vC::Vector)
    # TODO
end

add(vA::Vector, vB::Vector) = Vector(vA.x + vB.x, vA.y + vB.y)
sub(vA::Vector, vB::Vector) = Vector(vA.x - vB.x, vA.y - vB.y)
mult(vA::Vector, scalar) = Vector(vA.x * scalar, vA.y * scalar)
div(vA::Vector, vB::Vector) = Vector(vA.x / scalar, vA.y / scalar)

function add!(vA::Vector, vB::Vector)
    vA.x += vB.x
    vA.y += vB.y
end

function sub!(vA::Vector, vB::Vector)
    vA.x -= vB.x
    vA.y -= vB.y
end

function mult!(vA::Vector, scalar)
    vA.x *= scalar
    vA.y *= scalar
end

function div!(vA::Vector, vB::Vector)
    vA.x /= scalar
    vA.y /= scalar
end

neg(v::Vector) = mult(v, -1)

function angle(v::Vector)
    # TODO
end

function perp(v::Vector, opposite::Bool = False)
    if opposite
        return Vector(v.y, -v.x)
    else
        return Vector(-v.y, v.x)
    end
end
