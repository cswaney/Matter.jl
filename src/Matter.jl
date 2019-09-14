module Matter

include("./geometry/vector.jl")
include("./geometry/vertex.jl")
export Vector, add!, sub!, mult!, div!, magnitude, normalize!, dot, det, cross, rotate!
export Vertex, Contact, vertices, center, mean, area, inertia, translate!, rotate!

end # module
