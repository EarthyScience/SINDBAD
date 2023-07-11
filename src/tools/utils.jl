export PARAMFIELDS, @unpack_land, @pack_land, @unpack_forcing
export getzix, setTupleField, setTupleSubfield, applyUnitConversion
export offDiag, offDiagUpper, offDiagLower, cumSum!
export flagUpper, flagLower
export nonUnique
export noStackTrace
export dictToNamedTuple
export getSindbadModels
export addS
export tcprint
export set_component_from_main_pool, set_main_from_component_pool
export clamp_01
export min_0, max_0, min_1, max_1
export valToSymbol
export getFrac

"""
    noStackTrace()

Modifies Base.show to reduce the size of error stacktrace of sindbad
"""
function noStackTrace()
    eval(:(Base.show(io::IO, nt::Type{<:NamedTuple}) = print(io, "NT")))
    eval(:(Base.show(io::IO, nt::Type{<:Tuple}) = print(io, "T")))
    return eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = print(io, "NT")))
end

"""
    getSindbadModels()

helper function to return a table of sindbad model and approaches
"""
function getSindbadModels()
    approaches = []

    for _md ∈ sindbad_models.model
        push!(approaches, join(subtypes(getfield(Sindbad.Models, _md)), ", "))
    end
    model_approaches = Table((; model=[sindbad_models.model...], approaches=[approaches...]))
    return model_approaches
end

"""
    nonUnique(x::AbstractArray{T}) where T

returns a vector of duplicates in the input vector
"""
function nonUnique(x::AbstractArray{T}) where {T}
    xs = sort(x)
    duplicatedvector = T[]
    for i ∈ eachindex(xs)
        if i > 1
            if (
                isequal(xs[i], xs[i-1]) &&
                (length(duplicatedvector) == 0 || !isequal(duplicatedvector[end], xs[i]))
            )
                push!(duplicatedvector, xs[i])
            end
        end
    end
    return duplicatedvector
end

"""
    applyUnitConversion(data_in, conversion, isadditive=false)

Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag
"""
function applyUnitConversion(data_in, conversion, isadditive=false)
    if isadditive
        data_out = data_in + conversion
    else
        data_out = data_in * conversion
    end
    return data_out
end

"""
    dictToNamedTuple(d::DataStructures.OrderedDict)

covert nested dictionary to NamedTuple
"""
function dictToNamedTuple(d::AbstractDict)
    for k ∈ keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v ∈ d[k]]
        elseif d[k] isa DataStructures.OrderedDict
            d[k] = dictToNamedTuple(d[k])
        end
    end
    dTuple = NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
    return dTuple
end

function setTupleSubfield(out, fieldname, vals)
    return (; out..., fieldname => (; getfield(out, fieldname)..., first(vals) => last(vals)))
end

setTupleField(out, vals) = (; out..., first(vals) => last(vals))

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
        for field ∈ fields
            if abbrv.types
                println(buf, "  - `", field, "::", fieldtype(object, field), "`")
            else
                bnds = [nothing, nothing]
                try
                    bnds = collect(bounds(object, field))
                catch
                    bnds = [nothing, nothing]
                end
                println(buf,
                    "  - `",
                    field,
                    " = ",
                    getfield(getfield(Sindbad.Models, Symbol(object))(), field),
                    ", ",
                    bnds,
                    ", (",
                    units(object, field),
                    ")",
                    "` => " * describe(object, field))
            end
            if haskey(docs, field) && isa(docs[field], AbstractString)
                println(buf)
                println(docs[field])
                for line ∈ split(docs[field], ": ")
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
        return Expr(:(=), esc(rn), Expr(:(.), esc(rhs), QuoteNode(s)))
    end
    return Expr(:block, lines...)
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

function processPackSetIndex(ex::Expr)
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
        #println("symbol")
        lhs = [lhs]
    elseif lhs.head == :tuple
        #println("tuple")
        lhs = lhs.args
    else
        error("processPackLand: could not pack:" * lhs * "=" * rhs)
    end
    if rename === nothing
        rename = lhs
    elseif rename isa Expr && rename.head == :tuple
        rename = rename.args
    end
    lhs, rename, rhs
    bse = esc(:(Base.setindex))
    lines = broadcast(lhs, rename) do s, rn
        depth_field = count(==('.'), string(esc(rhs))) + 1
        if depth_field == 1
            :($(bse)($(esc(rhs)), $(esc(rn)), $(QuoteNode(s))))
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            Expr(:(=),
                esc(top),
                :($(bse)($(esc(top)),
                    $(bse)($(esc(rhs)), $(esc(rn)), $(QuoteNode(s))),
                    $(QuoteNode(field)))))
        end
    end
    return Expr(:block, lines...)
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
        #println("symbol")
        lhs = [lhs]
    elseif lhs.head == :tuple
        #println("tuple")
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
            expr_l = Expr(:(=),
                esc(rhs),
                Expr(:tuple,
                    Expr(:parameters, Expr(:(...), esc(rhs)),
                        Expr(:kw, esc(s), esc(rn)))))
            # expr_l = Expr(:(=), esc(rhs), Expr(:tuple, Expr(:parameters, Expr(:(...), esc(rhs)), Expr(:(=), esc(s), esc(rn)))))
            expr_l
        elseif depth_field == 2
            top = Symbol(split(string(rhs), '.')[1])
            field = Symbol(split(string(rhs), '.')[2])
            tmp = Expr(:(=),
                esc(top),
                Expr(:tuple,
                    Expr(:(...), esc(top)),
                    Expr(:(=),
                        esc(field),
                        (Expr(:tuple,
                            Expr(:parameters, Expr(:(...), esc(rhs)),
                                Expr(:kw, esc(s), esc(rn))))))))
            # tmp = Expr(:(=), esc(top), Expr(:macrocall, Symbol("@set"), :(#= none:1 =#), Expr(:(=), Expr(:ref, Expr(:ref, esc(top), QuoteNode(field)), QuoteNode(s)), esc(rn))))
            tmp
        end
    end
    return Expr(:block, lines...)
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
        return Expr(:(=), esc(rn), Expr(:(.), esc(rhs), QuoteNode(s)))
    end
    return Expr(:block, lines...)
end

macro unpack_forcing(inparams)
    @assert inparams.head == :call || inparams.head == :(=)
    return outputs = processUnpackForcing(inparams)
end

"""
getzix(dat::SubArray)
returns the indices of a view for a subArray
"""
function getzix(dat::SubArray)
    return first(parentindices(dat))
end

"""
getzix(dat::SubArray)
returns the indices of a view for a subArray
"""
function getzix(dat::SubArray, zixhelpersPool)
    return first(parentindices(dat))
end

"""
getzix(dat::Array)
returns the indices of a view for a subArray
"""
function getzix(dat::Array, zixhelpersPool)
    return zixhelpersPool
end

"""
getzix(dat::SVector)
returns the indices of a view for a subArray
"""
function getzix(dat::SVector, zixhelpersPool)
    return zixhelpersPool
end

"""
    cumSum!(i_n::AbstractVector, o_ut::AbstractVector)

fill out the output vector with the cumulative sum of elements from input vector
"""
function cumSum!(i_n::AbstractVector, o_ut::AbstractVector)
    for i ∈ eachindex(i_n)
        o_ut[i] = sum(i_n[1:i])
    end
    return o_ut
end

"""
    offDiag(A::AbstractMatrix)

returns a vector comprising of off diagonal elements of a matrix
"""
function offDiag(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] ≠ ι[2]]]
end

"""
    offDiagUpper(A::AbstractMatrix)

returns a vector comprising of above diagonal elements of a matrix
"""
function offDiagUpper(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] < ι[2]]]
end

"""
    offDiagLower(A::AbstractMatrix)

returns a vector comprising of below diagonal elements of a matrix
"""
function offDiagLower(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] > ι[2]]]
end

"""
    flagOffDiag(A::AbstractMatrix)

returns a matrix of same shape as input with 1 for all non diagonal elements
"""
function flagOffDiag(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι ∈ CartesianIndices(A)
        if ι[1] ≠ ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end

"""
    flagUpper(A::AbstractMatrix)

returns a matrix of same shape as input with 1 for all above diagonal elements and 0 elsewhere
"""
function flagUpper(A::AbstractMatrix)
    o_mat = zeros(size(A))
    for ι ∈ CartesianIndices(A)
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
    for ι ∈ CartesianIndices(A)
        if ι[1] > ι[2]
            o_mat[ι] = 1
        end
    end
    return o_mat
end

"""
addS(s, sΔ)
return total storage amount given the storage and the current delta storage without creating an allocation for a temporary array
"""
function addS(s, sΔ)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si] + sΔ[si]
    end
    return sm
end

"""
addS(s)
return total storage amount given the storage without creating an allocation for a temporary array
"""
function addS(s)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si]
    end
    return sm
end

"""
getTypes!(d, all_types)
utility function to collect all types from nested namedtuples
"""
function getTypes!(d, all_types)
    for k ∈ keys(d)
        if d[k] isa NamedTuple
            push!(all_types, typeof(d[k]))
            getTypes!(d[k], all_types)
        else
            push!(all_types, typeof(d[k]))
        end
    end
    return unique(all_types)
end

"""
    collect_color_4_types(d; c_olor=true)
utility function to collect colors for all types from nested namedtuples
"""
function collect_color_4_types(d; c_olor=true)
    all_types = []
    all_types = getTypes!(d, all_types)
    c_types = Dict{DataType,Int}()
    for t ∈ all_types
        if c_olor == true
            c = rand(0:255)
        else
            c = 0
        end
        c_types[t] = c
    end
    return c_types
end

"""
    tcprint(d, df=1; c_olor=true, t_ype=true, istop=true)
- a helper function to navigate the input named tuple and annotate types.
- a random set of colors is chosen per type of the data/field
- a mixed colored output within a feild usually warrants caution on type mismatches
"""
function tcprint(d, df=1; c_olor=true, t_ype=true, istop=true)
    colors_types = collect_color_4_types(d; c_olor=c_olor)
    lc = nothing
    tt = "\t"
    for k ∈ keys(d)
        # lc = colors_types[typeof(d[k])]
        if d[k] isa NamedTuple
            tt = ""
            if t_ype == true
                tp = " = (; "
                # lc = colors_types[typeof(d[k])]
            else
                tp = ""
            end
            if df != 1
                tt = repeat("\t", df)
            end
            print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt) $(k)$(tp)\n")
            tcprint(d[k], df; c_olor=c_olor, t_ype=t_ype, istop=false)
        else
            tt = repeat("\t", df)
            if t_ype == true
                tp = "::$(typeof(d[k]))"
                if tp == "::NT"
                    tp = "::Tuple"
                end

            else
                tt = repeat("\t", df)
                tp = ""
            end
            if typeof(d[k]) <: Float32
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = $(d[k])f0$(tp),\n")
            elseif typeof(d[k]) <: SVector
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = SVector{$(length(d[k]))}($(d[k]))$(tp),\n")
            elseif typeof(d[k]) <: Matrix
                print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt) $(k) = [\n")
                tt_row = repeat(tt[1], length(tt) + 1)
                for _d ∈ eachrow(d[k])
                    d_str = nothing
                    if eltype(_d) == Float32
                        d_str = join(_d, "f0 ") * "f0"
                    else
                        d_str = join(_d, " ")
                    end
                    print(Crayon(; foreground=colors_types[typeof(d[k])]),
                        "$(tt_row) $(d_str);\n")
                end
                print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt_row) ]$(tp),\n")
            else
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = $(d[k])$(tp),\n")
            end
            lc = colors_types[typeof(d[k])]
        end
        # if k == last(keys(d))
        #     print(Crayon(foreground = colors_types[typeof(d[k])]), "$(tt))::NamedTuple,\n")
        # end
        df = 1
    end
    if t_ype == true
        tt = tt * " "
        print(Crayon(; foreground=lc), "$(tt))::NamedTuple,\n")
    else
        print(Crayon(; foreground=lc), "$(tt)),\n")
    end
end



"""
    set_component_from_main_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the component pools value using the values for the main pool
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""
@generated function set_component_from_main_pool(
    # function set_component_from_main_pool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    output = quote end
    push!(output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=),
                s_comp,
                Expr(:call,
                    rep_elem,
                    s_comp,
                    Expr(:ref, s_main, ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_comp)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_comp)),
                    :(helpers.numbers.𝟘),
                    :(helpers.numbers.𝟙),
                    c_ix)))

            c_ix += 1
        end
        push!(output.args, Expr(:(=),
            :land,
            Expr(:tuple,
                Expr(:(...), :land),
                Expr(:(=),
                    :pools,
                    (Expr(:tuple,
                        Expr(:parameters, Expr(:(...), :(land.pools)),
                            Expr(:kw, s_comp, s_comp))))))))
    end
    return output
end


"""
    set_main_from_component_pool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the main pool from the values of the component pools
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""
@generated function set_main_from_component_pool(
    # function set_main_from_component_pool(
    land,
    helpers,
    ::Val{s_main},
    ::Val{s_comps},
    ::Val{zix}) where {s_main,s_comps,zix}
    output = quote end
    push!(output.args, Expr(:(=), s_main, Expr(:., :(land.pools), QuoteNode(s_main))))
    foreach(s_comps) do s_comp
        push!(output.args, Expr(:(=), s_comp, Expr(:., :(land.pools), QuoteNode(s_comp))))
        zix_pool = getfield(zix, s_comp)
        c_ix = 1
        foreach(zix_pool) do ix
            push!(output.args, Expr(:(=),
                s_main,
                Expr(:call,
                    rep_elem,
                    s_main,
                    Expr(:ref, s_comp, c_ix),
                    Expr(:., :(helpers.pools.zeros), QuoteNode(s_main)),
                    Expr(:., :(helpers.pools.ones), QuoteNode(s_main)),
                    :(helpers.numbers.𝟘),
                    :(helpers.numbers.𝟙),
                    ix)))
            c_ix += 1
        end
    end
    push!(output.args, Expr(:(=),
        :land,
        Expr(:tuple,
            Expr(:(...), :land),
            Expr(:(=),
                :pools,
                (Expr(:tuple,
                    Expr(:parameters, Expr(:(...), :(land.pools)),
                        Expr(:kw, s_main, s_main))))))))
    return output
end

"""
clamp_01(num)
returns max(min(num, 1), 0)
"""
function clamp_01(num)
    return clamp(num, zero(num), one(num))
end


"""
min_0(num)
returns min(num, 0)
"""
function min_0(num)
    return min(num, zero(num))
end


"""
min_1(num)
returns min(num, 1)
"""
function min_1(num)
    return min(num, one(num))
end


"""
max_0(num)
returns max(num, 0)
"""
function max_0(num)
    return max(num, zero(num))
end


"""
max_1(num)
returns max(num, 1)
"""
function max_1(num)
    return max(num, one(num))
end

"""
valToSymbol(val)
returns the symbol from which val was created for a type dispatch based on name
"""
function valToSymbol(val)
    return typeof(val).parameters[1]
end

"""
getFrac(num, den)
return either a ratio or zero depending on whether denomitor is a zero
"""
function getFrac(num, den)
    if !iszero(den)
        rat = num / den
    else
        rat = zero(num)
    end
    return rat
end
