abstract type Body end

mutable struct Rectangle <: Body
    x
    y
    width
    height
    body
end

function Rectangle(x, y, width, height)

    # create position
    position = Vector(x, y)

    # create vertices
    vertices = vertices_from_list(
        [
            Vector(x, y),
            Vector(x + width, y),
            Vector(x + width, y + height),
            Vector(x, y + height)
        ]
    )

    # return body
    return Body(position, vertices)
end
