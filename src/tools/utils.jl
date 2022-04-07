export PARAMFIELDS
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

struct BoundFields <: DocStringExtensions.Abbreviation
types::Bool
end
const PARAMFIELDS = BoundFields(false)

function DocStringExtensions.format(abbrv::BoundFields, buf, doc)
    local docs = get(doc.data, :fields, Dict())
    local binding = doc.data[:binding]
    local object = Docs.resolve(binding)
    local fields = isabstracttype(object) ? Symbol[] : fieldnames(object)
    if !isempty(fields)

        println(buf)
        for field in fields
            println(buf, describe(object, field))
            if abbrv.types
                println(buf, "  - `", field, "::", fieldtype(object, field), "`")
            else
                println(buf, "  - `", field, "=",
                bounds(object, field),"`")
            end
            println(buf)
            if haskey(docs, field) && isa(docs[field], AbstractString)
                println(buf)
                println(docs[field])
                for line in split(docs[field], ": ")
                    println(buf, isempty(line) ? "" : "    ", rstrip(line))
                end
            end
            println(buf)
        end
        println(buf)
    end
    return nothing
end
