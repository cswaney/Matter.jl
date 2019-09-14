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

function vertices(vectors, body)
    vertices = Array{Vertex,1}()
    for (index, vector) in enumerate(vectors)
        vertex = Vertex(vector, index, body)
        contact = Contact(vertex)
        vertex.contact = contact
        push!(vertices, vertex)
    end
    return vertices
end

"""
    center(vertices::Array{Vertex,1})

Compute the first moment ("center of mass") of the vertices.
"""
function center(vertices::Array{Vertex,1})
    A = area(vertices)
    M = Vector(0., 0.)
    for index in eachindex(vertices)
        vector = vertices[index].vector
        next_vector = vertices[index % length(vertices) + 1].vector
        cross_product = det(vector, next_vector)
        M += (vector + next_vector) * cross_product
    end
    return M / 6. / A
end

"""
    mean(vertices::Array{Vertex,1})

Compute the average position of the vertices.
"""
function mean(vertices::Array{Vertex,1})
    average = Vector(0., 0.)
    for vertex in vertices
        average += vertex.vector
    end
    return average / length(vertices)
end

"""
    area(vertices::Array{Vertex,1})

Compute the area bound by the convex hull of the vertices.
"""
function area(vertices::Array{Vertex,1})
    A = 0.
    prev_vector = vertices[end].vector
    for index in eachindex(vertices)
        vector = vertices[index].vector
        A += det(prev_vector, vector)
        prev_vector = vector
    end
    return A / 2.
end

"""
    inertia(vertices::Array{Vertex,1})

Compute the second moment ("moment of inertia") of the vertices.
"""
function inertia(vertices::Array{Vertex,1}, mass)
    numerator = 0.
    denominator = 0.
    for index in eachindex(vertices)
        vector = vertices[index].vector
        next_vector = vertices[index % length(vertices) + 1].vector
        cross_product = det(next_vector, vector)
        numerator += abs(cross_product) * (dot(next_vector, next_vector) + dot(next_vector, vector) + dot(vector, vector))
        denominator += cross_product
    end
    return mass / 6 * numerator / denominator
end

"""
    translate!(vertices::Array{Vertex,1}, translation::Vector)

Move vertices by translation.
"""
function translate!(vertices::Array{Vertex,1}, translation::Vector)
    for index in eachindex(vertices)
        vertices[index].vector += translation
    end
end

"""
    rotate!(vertices::Array{Vertex,1}, angle::Vector, point::Vector)

Rotate vertices by angle about a point.
"""
function rotate!(vertices::Array{Vertex,1}, angle, point::Vector)
    angle == 0. && return
    for index in eachindex(vertices)
        rotate!(vertices[index].vector, angle, point)
    end
end

"""
    contains(vertices::Array{Vertex,1}, point::Vector)

Check if a point is inside `vertices`.
"""
function contains(vertices::Array{Vertex,1}, point::Vector)
    for index in eachindex(vertices)
        vector = vertices[index].vector
        next_vector = vertices[index % length(vertices) + 1].vector
        if det(point - vector, next_vector - vector) > 0
            return false
        end
    end
    return true
end
