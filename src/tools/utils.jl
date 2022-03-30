function tuple2table(dTuple; colNames=nothing)
    tpNames = propertynames(dTuple)
    tpValues = values(dTuple)
    dNames = [Symbol(tpNames[i]) for i in 1:length(tpNames)]
    dValues = [[tpValues[i]] for i in 1:length(tpNames)]
    if isnothing(colNames)
        dTable = Table((; zip(dNames, dValues)...)) 
    else
        dTable = Table(@eval $(colNames)[1]=dNames, @eval $(colNames)[2]=dValues)
    end
    return dTable
end

"""
dict2tuple(d::Dict)
covert nested dictionary to named Tuple
"""
function dict2tuple(d::Dict)
    for k in keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v in d[k]]
        elseif d[k] isa Dict
            d[k] = dict2tuple(d[k])
        end
    end
    dTuple = NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
    return dTuple
end

"""
typenarrow!(d::Dict)
covert nested dictionary to named Tuple
"""
function typenarrow!(d::Dict)
    for k in keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v in d[k]]
        elseif d[k] isa Dict
            d[k] = typenarrow!(d[k])
        end
    end
    dTuple = NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
    return dTuple
end

function setTupleSubfield(out, fieldname = :fluxes, vals = (:a, 1))
    return @eval (; $out..., $fieldname = (; $out.$fieldname...,$(vals[1]) = $vals[2]))
end


function setTupleField(out, vals = (:a, 1))
    return @eval (; $out..., $(vals[1]) = $vals[2])
end