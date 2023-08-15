export addToElem, @add_to_elem, addToEachElem, addVec
export clampZeroOne
export cumSum!
export flagUpper, flagLower
export getFrac
export getSindbadModels
export getVarField
export getVarFull
export getVariableInfo
export getVarName
export getZix
export maxZero, maxOne, minZero, minOne
export offDiag, offDiagUpper, offDiagLower
export @pack_land, @unpack_land, @unpack_forcing
export repElem, @rep_elem, repVec, @rep_vec
export setComponents
export setComponentFromMainPool, setMainFromComponentPool
export showParamsOfAModel
export showParamsOfAllModels
export SindbadParameters
export totalS

struct BoundFields <: DocStringExtensions.Abbreviation
    types::Bool
end

macro add_to_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    indx = rhsa[2]
    hp_pool = rhsa[3]
    outCode = [
        Expr(:(=),
            tar,
            Expr(:call,
                addToElem,
                tar,
                lhs,
                esc(Expr(:., :(helpers.pools.zeros), hp_pool)),
                # esc(:(land.wCycleBase.z_zero)),
                esc(indx)))
    ]
    return Expr(:block, outCode...)
end

"""
    addToElem(v::SVector, Δv, v_zero, ind::Int)



# Arguments:
- `v`: DESCRIPTION
- `Δv`: DESCRIPTION
- `v_zero`: DESCRIPTION
- `ind`: DESCRIPTION
"""
function addToElem(v::SVector, Δv, v_zero, ind::Int)
    n_0 = zero(first(v_zero))
    n_1 = one(first(v_zero))
    v_zero = v_zero .* n_0
    v_zero = Base.setindex(v_zero, n_1, ind)
    v = v .+ v_zero .* Δv
    return v
end

"""
    addToElem(v::AbstractVector, Δv, _, _, ind::Int)



# Arguments:
- `v`: DESCRIPTION
- `Δv`: DESCRIPTION
- `_`: unused argument
- `_`: unused argument
- `ind`: DESCRIPTION
"""
function addToElem(v::AbstractVector, Δv, _, ind::Int)
    v[ind] = v[ind] + Δv
    return v
end

"""
    addToEachElem(v::SVector, Δv::Real)


"""
function addToEachElem(v::SVector, Δv::Real)
    v = v .+ Δv
    return v
end

"""
    addToEachElem(v::AbstractVector, Δv::Real)


"""
function addToEachElem(v::AbstractVector, Δv::Real)
    v .= v .+ Δv
    return v
end

"""
    addVec(v::SVector, Δv::SVector)


"""
function addVec(v::SVector, Δv::SVector)
    v = v + Δv
    return v
end

"""
    addVec(v::AbstractVector, Δv::AbstractVector)


"""
function addVec(v::AbstractVector, Δv::AbstractVector)
    v .= v .+ Δv
    return v
end


"""
    clampZeroOne(num)

returns max(min(num, 1), 0)
"""
function clampZeroOne(num)
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
    getZix(dat::SubArray)

returns the indices of a view for a subArray
"""
function getZix(dat::SubArray)
    return Tuple(first(parentindices(dat)))
end


"""
    getZix(dat::SubArray, zixhelpersPool)

returns the indices of a view for a subArray
"""
function getZix(dat::SubArray, zixhelpersPool)
    return Tuple(first(parentindices(dat)))
end

"""
    getZix(dat::Array, zixhelpersPool)

returns the indices of a view for an array
"""
function getZix(dat::Array, zixhelpersPool)
    return zixhelpersPool
end


"""
    getZix(dat::SVector, zixhelpersPool)

returns the indices of a view for a subArray
"""
function getZix(dat::SVector, zixhelpersPool)
    return zixhelpersPool
end


"""
    maxZero(num)

returns max(num, 0)
"""
function maxZero(num)
    return max(num, zero(num))
end


"""
    maxOne(num)

returns max(num, 1)
"""
function maxOne(num)
    return max(num, one(num))
end


"""
    minZero(num)

returns min(num, 0)
"""
function minZero(num)
    return min(num, zero(num))
end


"""
    minOne(num)

returns min(num, 1)
"""
function minOne(num)
    return min(num, one(num))
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


macro rep_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    indx = rhsa[2]
    hp_pool = rhsa[3]
    outCode = [
        Expr(:(=),
            tar,
            Expr(:call,
                repElem,
                tar,
                lhs,
                esc(Expr(:., :(helpers.pools.zeros), hp_pool)),
                esc(Expr(:., :(helpers.pools.ones), hp_pool)),
                esc(indx)))
    ]
    return Expr(:block, outCode...)
end

"""
    repElem(v::AbstractVector, v_elem, _, _, ind::Int)



# Arguments:
- `v`: DESCRIPTION
- `v_elem`: DESCRIPTION
- `_`: unused argument
- `_`: unused argument
- `ind`: DESCRIPTION
"""
function repElem(v::AbstractVector, v_elem, _, _, ind::Int)
    v[ind] = v_elem
    return v
end

"""
    repElem(v::SVector, v_elem, v_zero, v_one, ind::Int)



# Arguments:
- `v`: DESCRIPTION
- `v_elem`: DESCRIPTION
- `v_zero`: DESCRIPTION
- `v_one`: DESCRIPTION
- `ind`: DESCRIPTION
"""
function repElem(v::SVector, v_elem, v_zero, v_one, ind::Int)
    n_0 = zero(first(v_zero))
    n_1 = one(first(v_zero))
    v_zero = v_zero .* n_0
    v_zero = Base.setindex(v_zero, n_1, ind)
    v_one = v_one .* n_0 .+ n_1
    v_one = Base.setindex(v_one, n_0, ind)
    v = v .* v_one .+ v_zero .* v_elem
    # v = Base.setindex(v, v_elem, vlit_level)
    return v
end

macro rep_vec(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = esc(outparams.args[3])
    outCode = [Expr(:(=), lhs, Expr(:call, repVec, lhs, rhs))]
    return Expr(:block, outCode...)
end

"""
    repVec(v::AbstractVector, v_new)


"""
function repVec(v::AbstractVector, v_new)
    v .= v_new
    return v
end

"""
    repVec(v::SVector, v_new)


"""
function repVec(v::SVector, v_new)
    n_0 = zero(first(v))
    v = v .* n_0 + v_new
    return v
end

"""
    setComponents(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})



# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function setComponents(
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
    setComponentFromMainPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

- sets the component pools value using the values for the main pool
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json


# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
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
    setMainFromComponentPool(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

- sets the main pool from the values of the component pools
- name are generated using the components in helpers so that the model formulations are not specific for poolnames and are dependent on model structure.json

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: helper NT with necessary objects for model run and type consistencies
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
    showParamsOfAllModels(models)

shows the current parameters of all given models
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
    totalS(s, sΔ)

return total storage amount given the storage and the current delta storage without creating an allocation for a temporary array
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

