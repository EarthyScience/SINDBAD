export PARAMFIELDS, @unpack_land, @pack_land, @unpack_forcing, getzix, setTupleField, setTupleSubfield, applyUnitConversion, offDiag, offDiagUpper, offDiagLower, flagLower, flagUpper

"""
    applyUnitConversion(data_in, conversion, isadditive=false)
Applies a simple factor to the input array, either additively or multiplicatively depending on isadditive flag
"""
function applyUnitConversion(data_in, conversion, isadditive=false)
    if isadditive
        data_out = data_in .+ conversion
    else
        data_out = data_in .* conversion
    end
    return data_out
end

function tuple2table(dTuple; colNames=nothing)
    tpNames = propertynames(dTuple)
    tpValues = values(dTuple)
    dNames = [Symbol(tpNames[i]) for i in 1:length(tpNames)]
    dValues = [[tpValues[i]] for i in 1:length(tpNames)]
    if isnothing(colNames)
        dTable = Table((; zip(dNames, dValues)...))
    else
        dTable = Table(@eval $(colNames)[1] = dNames, @eval $(colNames)[2] = dValues)
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
typenarrow!(d::DataStructures.OrderedDict)
covert nested dictionary to named Tuple
"""
function typenarrow!(d::DataStructures.OrderedDict)
    for k in keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v in d[k]]
        elseif d[k] isa DataStructures.OrderedDict
            d[k] = typenarrow!(d[k])
        end
    end
    dTuple = NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
    return dTuple
end

#function setTupleSubfield(out, fieldname=:fluxes, vals=(:a, 1))
#    return @eval (; $out..., $fieldname=(; $out.$fieldname..., $(vals[1])=$vals[2]))
#end

#function setTupleField(out, vals=(:a, 1))
#    return @eval (; $out..., $(vals[1])=$vals[2])
#end


function setTupleSubfield(out, fieldname, vals)
    return (;out..., fieldname=>(;getfield(out, fieldname)...,first(vals)=>last(vals)))
end

setTupleField(out, vals) = (;out..., first(vals)=>last(vals))

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
                    bounds(object, field), "`")
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

function processUnpackLand(ex)
    rename, ex = if ex.head == :(=)
        ex.args[1], ex.args[2]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(∈)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processUnpackLand: could not unpack:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lines = broadcast(lhs, rename) do s, rn
        Expr(:(=), esc(rn), Expr(:(.), esc(rhs), QuoteNode(s)))
    end
    Expr(:block, lines...)
end


macro unpack_land(inparams)
    @assert inparams.head == :block || inparams.head == :call || inparams.head == :(=)
    if inparams.head == :block
        outputs = processUnpackLand.(filter(i -> isa(i, Expr), inparams.args))
        outCode = Expr(:block, outputs...)
    else
        outCode = processUnpackLand(inparams)
    end
    return outCode
end

function processPackLand(ex)
    rename, ex = if ex.args[1] == :(=)
        ex.args[2], ex.args[3]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(=>)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processPackLand: could not pack:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lines = broadcast(lhs, rename) do s, rn
        depth_field = length(findall(".", string(esc(rhs)))) + 1
        if depth_field == 1
            expr_l = Expr(:(=), esc(rhs), Expr(:tuple, Expr(:parameters, Expr(:(...), esc(rhs)), Expr(:(=), esc(s), esc(rn)))))
            expr_l
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            expr_l = Expr(:(=), esc(top), Expr(:tuple, Expr(:(...), esc(top)), Expr(:(=), esc(field), (Expr(:tuple, Expr(:parameters, Expr(:(...), esc(rhs)), Expr(:(=), esc(s), esc(rn))))))))
        end
    end
    Expr(:block, lines...)
end

macro pack_land(outparams)
    @assert outparams.head == :block || outparams.head == :call || outparams.head == :(=)
    if outparams.head == :block
        outputs = processPackLand.(filter(i -> isa(i, Expr), outparams.args))
        outCode = Expr(:block, outputs...)
    else
        outCode = processPackLand(outparams)
    end
    return outCode
end


function processUnpackForcing(ex)
    rename, ex = if ex.head == :(=)
        ex.args[1], ex.args[2]
    else
        nothing, ex
    end
    @assert ex.head == :call
    @assert ex.args[1] == :(∈)
    @assert length(ex.args) == 3
    lhs = ex.args[2]
    rhs = ex.args[3]
    if lhs isa Symbol
        lhs = [lhs]
    elseif lhs.head == :tuple
        lhs = lhs.args
    else
        error("processUnpackForcing: could not unpack forcing:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lines = broadcast(lhs, rename) do s, rn
        Expr(:(=), esc(rn), Expr(:(.), esc(rhs), QuoteNode(s)))
    end
    Expr(:block, lines...)
end


macro unpack_forcing(inparams)
    @assert inparams.head == :call || inparams.head == :(=)
    outputs = processUnpackForcing(inparams)
end

"""
    getzix(tpl::NamedTuple, fld::Symbol)
returns the indices of a view in the parent main array
"""
function getzix(tpl::NamedTuple, fld::Symbol)
    dat::SubArray = getfield(tpl, fld)
    getzix = parentindices(dat)[1]
    return getzix
end

function getzix(tpl::NamedTuple, fld::String)
    dat::SubArray = getfield(tpl, Symbol(fld))
    getzix = parentindices(dat)[1]
    return getzix
end

function getzix(dat::SubArray)
    getzix = parentindices(dat)[1]
    return getzix
end


"""
    offDiag(A::AbstractMatrix)
returns a vector comprising of off diagonal elements of a matrix
"""
function offDiag(A::AbstractMatrix)
    [A[ι] for ι in CartesianIndices(A) if ι[1] ≠ ι[2]]
end

"""
    offDiagUpper(A::AbstractMatrix)
returns a vector comprising of above diagonal elements of a matrix
"""
function offDiagUpper(A::AbstractMatrix)
    [A[ι] for ι in CartesianIndices(A) if ι[1] < ι[2]]
end

"""
    offDiagLower(A::AbstractMatrix)
returns a vector comprising of below diagonal elements of a matrix
"""
function offDiagLower(A::AbstractMatrix)
    [A[ι] for ι in CartesianIndices(A) if ι[1] > ι[2]]
end

"""
    flagUpper(A::AbstractMatrix)
returns a matrix of same shape as input with 1 for all above diagonal elements and 0 elsewhere
"""
function flagUpper(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι in CartesianIndices(A)
        if ι[1] < ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end

"""
    flagLower(A::AbstractMatrix)
returns a matrix of same shape as input with 1 for all below diagonal elements and 0 elsewhere
"""
function flagLower(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι in CartesianIndices(A)
        if ι[1] > ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end
