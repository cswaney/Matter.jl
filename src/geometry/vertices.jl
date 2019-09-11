mutable struct Vertex
    vector
    index
    body
    internal
    contact
end

Vertex(vector, index, body) = Vertex(vector, index, body, false, nothing)

mutable struct Contact
    vertex
    normal
    tangent
end

Contact(vertex) = Contact(vertex, 0., 0.)

"""
    Vertices

A collection of Vertex objects in clockwise order.
"""
mutable struct Vertices
    vertices
end

function Vertices(vectors, body)
    vertices = []
    for (index, vector) in enumerate(vectors)
        vertex = Vertex(vector, index, body)
        contact = Contact(vertex)
        vertex.contact = contact
        push!(vertices, vertex)
    end
    return Vertices(points)
end

# TODO: make Vertices iterable (iterates through its vertices)

length(vertices::Vertices) = length(vertices.vertices)

"""
    center(vertices::Vertices)

Compute the first moment ("center of mass") of the vertices.
"""
function center(vertices::Vertices)
    A = area(vertices)
    M = Vector(0., 0.)
    for index in eachindex(vertices)
        vertex = vertices[index]
        next_vertex = vertices[index % length(vertices)]
        cross_product = vertex × next_vertex
        M += (vertex + next_vertex) * cross_product
    end
    return M / 6. / A
end

"""
    mean(vertices::Vertices)

Compute the average position of the vertices.
"""
function mean(vertices::Vertices)
    average = Vector(0., 0.)
    for vertex in vertices
        average += vertex
    end
    return average / length(vertices)
end

"""
    area(vertices::Vertices)

Compute the area bound by the convex hull of the vertices.
"""
function area(vertices::Vertices)
    A = 0.
    prev_vertex = vertices[end]
    for index in eachindex(vertices)
        vertex = vertices[index]
        area += prev_vertex × vertex
        prev_vertex = vertex
    end
    return A / 2.
end

"""
    inertia(vertices::Vertices)

Compute the second moment ("moment of inertia") of the vertices.
"""
function inertia(vertices::Vertices)
    numerator = 0.
    denominator = 0.
    for index in eachindex(vertices)
        vertex = vertices[index]
        next_vertex = vertices[index % length(vertices)]
        cross_product = next_vertex × vertex
        numerator += cross_product * (next_vertex ⋅ next_vertex + next_vertex ⋅ vertex + vertex ⋅ vertex)
        denominator += cross_product
    end
    return mass / 6 * numerator / denominator
end

"""
    translate!(vertices::Vertices, translation::Vector)

Move vertices by translation.
"""
function translate!(vertices::Vertices, translation::Vector)
    for index in eachindex(vertices)
        vertices[i].vertex += translation
    end
end

"""
    rotate!(vertices::Vertices, angle::Vector, point::Vector)

Rotate vertices by angle about a point.
"""
function rotate!(vertices::Vertices, angle::Vector, point::Vector)
    for index in eachindex(vertices)
        vertex = vertices[index]
        dx = vertex.x - point.y
        dy = vertex.y - point.y
        vertex.x = dx * cos(angle) - dy * sin(angle)
        vertex.y = dx * sin(angle) + dy * cos(angle)
    end
end

"""
    contains(vertices::Vertices, point::Vector)

Check if a point is inside `vertices`.
"""
function contains(vertices::Vertices, point::Vector)
    for index in eachindex(vertices)
        vertex = vertices[index]
        next_vertex = vertices[index % length(vertices)]
        if (point - vertex) × (next_vertex - vertex) > 0
            return false
        end
    end
    return true
end
