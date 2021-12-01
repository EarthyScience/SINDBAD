function updateState(p::AbstractParam, newVal) # updateStateVariable
    # check if units are the same and update if possible.
    return @set p.val = newVal
end

"""
Forcing(val = missing; units = "", bounds = nothing)
"""
function Forcing(val = missing; units = "", bounds = nothing)
    return Param(val, units = units, bounds = bounds, forcing = true)
end

"""
addForcing!(o, data)
"""
function addForcing!(o, data)
    names = fieldnames(typeof(o))
    for name in names
        p = getfield(o, name)
        if :forcing in keys(p)
            @set! p.val = data[!, name]
            setproperty!(o, name, p)
        end
    end
    return nothing
end

"""
getForcingVars(o)
"""
function getForcingVars(o)
    names = fieldnames(typeof(o))
    forcingVars = []
    for name in names
        p = getfield(o, name)
        if :forcing in keys(p)
            push!(forcingVars, name)
        end
    end
    return forcingVars
end
