function Rectangle(x, y, width, height, options)

    rect = Dict(
        :label => "Rectangle_Body"
        :position => [x, y]
        :vertices => [
            [0., 0.],
            [width, 0.],
            [width, height],
            [0., height]
        ]
    )

    if options[:chamfer] != nothing
        rect[:vertices] = chamfer(
            rect[:vertices],
            options[:chamfer].radius,
            options[:chamfer].q,
            options[:chamfer].q_min,
            options[:chamfer].q_max
        )
        delete!(options, :chamfer)
    end

    merge!(rect, options)
    return Body(rect)
end

function Polygon(x, y, sides, radius, options)
    sides < 3 && return Circle(x, y, radius, options)

    theta = 2 * pi / sides
    path = []
    offset = theta * 0.5

    for i in 1:sides
        angle = offset + (i * theta)
        xx = cos(angle) * radius
        yy = sin(angle) * radius
        push!(path, [xx, yy])
    end

    poly = Dict(
        :label => "Polygon Body",
        :position => [x, y],
        :vertices => path
    )

    if options[:chamfer] != nothing
        poly[:vertices] = chamfer(
            poly[:vertices],
            options[:chamfer].radius,
            options[:chamfer].q,
            options[:chamfer].q_min,
            options[:chamfer].q_max
        )
        delete!(options, :chamfer)
    end

    merge!(poly, options)
    return Body(poly)
end

function Circle(x, y, radius, options, max_sides = 25)
    circ = Dict(
        :label => "Circle Body",
        :radius => radius
    )
    sides = ceil(max(10, min(max_sides, radius)))
    if sides % 2 == 1
        sides +=1
    end
    return Polygon(x, y, sides, radius, merge!(circ, options))
end
