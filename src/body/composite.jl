mutable struct Composite
    bodies
    constraints
    composites
end

Composite() = Composite([], [], [])

# TODO
function set_modified!(composite, is_modified::Bool, update_parent::Bool, update_children::Bool) end

function add!(composite::Composite, object)
    before_add!(composite, object)
    if object.type == "body"
        if object.parent != object
            @warn "Composite.add: skipped adding compound body part (you must add its parent instead)"
        end
        add_body!(composite, object)
    elseif object.type == "constraint"
        add_constraint!(composite, object)
    elseif object.type == "composite"
        add_composite!(composite, object)
    end
    after_add!(composite, object)
end

function remove!(composite, object)
    before_remove!(composite, object)
    if object.type == "body"
        remove_body!(composite, object)
    elseif object.type == "constraint"
        remove_constraint!(composite, object)
    elseif object.type == "composite"
        remove_composite!(composite, object)
    end
    after_remove!(composite, object)
end

function add_composite!(composite, new_composite)
    push!(composite.composites, new_composite)
    new_composite.parent = composite
    set_modified!(composite, true, true, false)
end

function remove_composite!(composite, old_composite)
    index = findall(c -> c.id == old_composite.id, composite.composites)
    deleteat!(composite.composites, index)
    set_modified(composite, true, true, false)
end

function add_body!(composite::Composite, body)
    push!(composite.bodies, body)
    set_modified!(composite, true, true, false)
end

function remove_body!(composite, body)
    index = findall(b -> b.id == body.id, composite.bodies)
    deleteat!(composite.bodies, index)
    set_modified!(composite, true, true, false)
end

function add_constraint!(composite::Composite, constraint)
    push!(composite.constraints, constraint)
    set_modified!(composite, true, true, false)
end

function remove_constraint!(composite, constraint)
    index = findall(c -> c.id == constraint.id, composite.constraints)
    deleteat!(composite.constraints, index)
    set_modified!(composite, true, true, false)
end

function translate!(composite::Composite, translation::Vector)
    for body in composite.bodies
        translate!(body, translation)
    end
    set_modified!(composite, true, true, false)
end

function rotate!(composite::Composite, rotation)
    for body in composite.bodies
        rotate!(body, rotation)
    end
end
