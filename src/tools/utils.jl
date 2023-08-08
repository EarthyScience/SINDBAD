export clamp01
export cumSum!
export dictToNamedTuple
export flagUpper, flagLower
export getBool
export getFrac
export getSindbadModels
export getZix
export max0, max1, min0, min1
export nanMax, nanMean, nanMin, nanSum
export nonUnique
export noStackTrace
export offDiag, offDiagUpper, offDiagLower
export @pack_land, @unpack_land, @unpack_forcing
export removeEmptyTupleFields
export returnIt
export setComponentFromMainPool, setMainFromComponentPool
export setLogLevel
export setTupleField, setTupleSubfield
export showParamsOfAModel
export showParamsOfAllModels
export SindbadParameters
export tcPrint
export totalS
export valToSymbol

struct BoundFields <: DocStringExtensions.Abbreviation
    types::Bool
end


"""
    collectColorForTypes(d; c_olor = true)

utility function to collect colors for all types from nested namedtuples
"""
function collectColorForTypes(d; c_olor=true)
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
    clamp01(num)

returns max(min(num, 1), 0)
"""
function clamp01(num)
    return clamp(num, zero(num), one(num))
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
    DocStringExtensions.format(abbrv::BoundFields, buf, doc)

DOCSTRING

# Arguments:
- `abbrv`: DESCRIPTION
- `buf`: DESCRIPTION
- `doc`: DESCRIPTION
"""
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

"""
    dictToNamedTuple(d::AbstractDict)

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
    getBool(var::Bool)

DOCSTRING
"""
function getBool(var::Bool)
    return var
end

"""
    getBool(var)

DOCSTRING
"""
function getBool(var)
    return valToSymbol(var)
end

"""
    getFrac(num, den)

return either a ratio or numerator depending on whether denomitor is a zero
"""
function getFrac(num, den)
    if !iszero(den)
        rat = num / den
    else
        rat = num
    end
    return rat
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
    getZix(dat::SubArray)

returns the indices of a view for a subArray
"""
function getZix(dat::SubArray)
    return first(parentindices(dat))
end

"""
getZix(dat::SubArray)
returns the indices of a view for a subArray
"""

"""
    getZix(dat::SubArray, zixhelpersPool)

DOCSTRING
"""
function getZix(dat::SubArray, zixhelpersPool)
    return first(parentindices(dat))
end

"""
getZix(dat::Array)
returns the indices of a view for a subArray
"""

"""
    getZix(dat::Array, zixhelpersPool)

DOCSTRING
"""
function getZix(dat::Array, zixhelpersPool)
    return zixhelpersPool
end

"""
getZix(dat::SVector)
returns the indices of a view for a subArray
"""

"""
    getZix(dat::SVector, zixhelpersPool)

DOCSTRING
"""
function getZix(dat::SVector, zixhelpersPool)
    return zixhelpersPool
end



"""
max0(num)
returns max(num, 0)
"""

"""
    max0(num)

DOCSTRING
"""
function max0(num)
    return max(num, zero(num))
end


"""
max1(num)
returns max(num, 1)
"""

"""
    max1(num)

DOCSTRING
"""
function max1(num)
    return max(num, one(num))
end


"""
min0(num)
returns min(num, 0)
"""

"""
    min0(num)

DOCSTRING
"""
function min0(num)
    return min(num, zero(num))
end


"""
min1(num)
returns min(num, 1)
"""

"""
    min1(num)

DOCSTRING
"""
function min1(num)
    return min(num, one(num))
end



"""
    nanMax(dat) = maximum(filter(!isnan, dat))

Calculate the maximum of an array while skipping nan
"""
nanMax(dat) = maximum(filter(!isnan, dat))

"""
    nanMean(dat) = mean(filter(!isnan, dat))

Calculate the mean of an array while skipping nan
"""
nanMean(dat) = mean(filter(!isnan, dat))

"""
    nanMin(dat) = minimum(filter(!isnan, dat))

Calculate the minimum of an array while skipping nan
"""
nanMin(dat) = minimum(filter(!isnan, dat))


"""
    nanSum(dat) = sum(filter(!isnan, dat))

Calculate the sum of an array while skipping nan
"""
nanSum(dat) = sum(filter(!isnan, dat))



"""
    nonUnique(x::AbstractArray{T}) where T

returns a vector of duplicates in the input vector
"""

"""
    nonUnique(x::AbstractArray{T})

DOCSTRING
"""
function nonUnique(x::AbstractArray{T}) where {T}
    xs = sort(x)
    duplicatedvector = T[]
    for i ∈ eachindex(xs)[2:end]
        if (
            isequal(xs[i], xs[i-1]) &&
            (length(duplicatedvector) == 0 || !isequal(duplicatedvector[end], xs[i]))
        )
            push!(duplicatedvector, xs[i])
        end
    end
    return duplicatedvector
end


"""
    noStackTrace()

Modifies Base.show to reduce the size of error stacktrace of sindbad
"""

"""
    noStackTrace()

DOCSTRING
"""
function noStackTrace()
    eval(:(Base.show(io::IO, nt::Type{<:NamedTuple}) = print(io, "NT")))
    eval(:(Base.show(io::IO, nt::Type{<:Tuple}) = print(io, "T")))
    return eval(:(Base.show(io::IO, nt::Type{<:NTuple}) = print(io, "NT")))
end


"""
    offDiag(A::AbstractMatrix)

returns a vector comprising of off diagonal elements of a matrix
"""
function offDiag(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] ≠ ι[2]]]
end

"""
    offDiagLower(A::AbstractMatrix)

returns a vector comprising of below diagonal elements of a matrix
"""
function offDiagLower(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] > ι[2]]]
end

"""
    offDiagUpper(A::AbstractMatrix)

returns a vector comprising of above diagonal elements of a matrix
"""
function offDiagUpper(A::AbstractMatrix)
    @view A[[ι for ι ∈ CartesianIndices(A) if ι[1] < ι[2]]]
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

"""
    processPackLand(ex)

DOCSTRING
"""
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

"""
    processUnpackForcing(ex)

DOCSTRING
"""
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

"""
    processUnpackLand(ex)

DOCSTRING
"""
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


"""
removeEmptyTupleFields(tpl)
"""

"""
    removeEmptyTupleFields(tpl::NamedTuple)

DOCSTRING
"""
function removeEmptyTupleFields(tpl::NamedTuple)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end

"""
    returnIt(dat) = dat

return the input as is
"""

"""
    returnIt(dat)

DOCSTRING
"""
function returnIt(dat)
    return dat
end



"""
    setComponentFromMainPool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the component pools value using the values for the main pool
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""

"""
    setComponentFromMainPool(land, helpers, nothing::Val{s_main}, nothing::Val{s_comps}, nothing::Val{zix})

DOCSTRING

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
@generated function setComponentFromMainPool(
    # function setComponentFromMainPool(
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
                    :(land.wCycleBase.z_zero),
                    :(land.wCycleBase.o_one),
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
    setLogLevel()

DOCSTRING
"""
function setLogLevel()
    logger = ConsoleLogger(stderr, Logging.Info)
    global_logger(logger)
end

"""
    setLogLevel(log_level)

DOCSTRING
"""
function setLogLevel(log_level)
    logger = ConsoleLogger(stderr, Logging.Info)
    if log_level == :debug
        logger = ConsoleLogger(stderr, Logging.Debug)
    elseif log_level == :warn
        logger = ConsoleLogger(stderr, Logging.Warn)
    elseif log_level == :error
        logger = ConsoleLogger(stderr, Logging.Error)
    end
    global_logger(logger)
end


"""
    setMainFromComponentPool(land, helpers, helpers.pools.vals.self.TWS, helpers.pools.vals.all_components.TWS, helpers.pools.vals.zix.TWS)
- sets the main pool from the values of the component pools
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json
"""

"""
    setMainFromComponentPool(land, helpers, nothing::Val{s_main}, nothing::Val{s_comps}, nothing::Val{zix})

DOCSTRING

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function setMainFromComponentPool(
    # function setMainFromComponentPool(
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
                    :(land.wCycleBase.z_zero),
                    :(land.wCycleBase.o_one),
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
    setTupleSubfield(out, fieldname, vals)

DOCSTRING

# Arguments:
- `out`: DESCRIPTION
- `fieldname`: DESCRIPTION
- `vals`: DESCRIPTION
"""
function setTupleSubfield(out, fieldname, vals)
    return (; out..., fieldname => (; getfield(out, fieldname)..., first(vals) => last(vals)))
end

setTupleField(out, vals) = (; out..., first(vals) => last(vals))


"""
showParamsOfAllModels(models)
shows the current parameters of all given models
"""

"""
    showParamsOfAllModels(models)

DOCSTRING
"""
function showParamsOfAllModels(models)
    for mn in sort([nameof.(supertype.(typeof.(models)))...])
        showParamsOfAModel(models, mn)
        println("------------------------------------------------------------------")
    end
    return nothing
end


"""
showParamsOfAModel(models, model::Symbol)
shows the current parameters of a given model (Symboll) [NOT APPRAOCH] based on the list of models provided
"""

"""
    showParamsOfAModel(models, model::Symbol)

DOCSTRING
"""
function showParamsOfAModel(models, model::Symbol)
    model_names = Symbol.(supertype.(typeof.(models)))
    approach_names = nameof.(typeof.(models))
    m_index = findall(m -> m == model, model_names)[1]
    mod = models[m_index]
    println("model: $(model_names[m_index])")
    println("approach: $(approach_names[m_index])")
    pnames = fieldnames(typeof(mod))
    if length(pnames) == 0
        println("parameters: none")
    else
        println("parameters:")
        foreach(pnames) do fn
            println("   $fn => $(getproperty(mod, fn))")
        end
    end
    return nothing
end

const SindbadParameters = BoundFields(false)


"""
    tcPrint(d, df=1; c_olor=true, t_ype=true, istop=true)
- a helper function to navigate the input named tuple and annotate types.
- a random set of colors is chosen per type of the data/field
- a mixed colored output within a feild usually warrants caution on type mismatches
"""

"""
    tcPrint(d, df = 1; c_olor = true, t_ype = true, istop = true)

DOCSTRING

# Arguments:
- `d`: DESCRIPTION
- `df`: DESCRIPTION
- `c_olor`: DESCRIPTION
- `t_ype`: DESCRIPTION
- `istop`: DESCRIPTION
"""
function tcPrint(d, df=1; c_olor=true, t_ype=true, istop=true)
    colors_types = collectColorForTypes(d; c_olor=c_olor)
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
            tcPrint(d[k], df; c_olor=c_olor, t_ype=t_ype, istop=false)
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
totalS(s, sΔ)
return total storage amount given the storage and the current delta storage without creating an allocation for a temporary array
"""

"""
    totalS(s, sΔ)

DOCSTRING
"""
function totalS(s, sΔ)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si] + sΔ[si]
    end
    return sm
end

"""
totalS(s)
return total storage amount given the storage without creating an allocation for a temporary array
"""

"""
    totalS(s)

DOCSTRING
"""
function totalS(s)
    sm = zero(eltype(s))
    for si ∈ eachindex(s)
        sm = sm + s[si]
    end
    return sm
end


macro unpack_forcing(inparams)
    @assert inparams.head == :call || inparams.head == :(=)
    return outputs = processUnpackForcing(inparams)
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


"""
    valToSymbol(val)

returns the symbol from which val was created for a type dispatch based on name
"""
function valToSymbol(val)
    return typeof(val).parameters[1]
end
