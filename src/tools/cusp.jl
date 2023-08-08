export addToElem, @add_to_elem, addToEachElem, addVec
export repElem, @rep_elem, repVec, @rep_vec
export setComponents

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

DOCSTRING

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

DOCSTRING

# Arguments:
- `v`: DESCRIPTION
- `Δv`: DESCRIPTION
- `_`: unused argument
- `_`: unused argument
- `ind`: DESCRIPTION
"""
function addToElem(v::AbstractVector, Δv, _, _, ind::Int)
    v[ind] = v[ind] + Δv
    return v
end

"""
    addToEachElem(v::SVector, Δv::Real)

DOCSTRING
"""
function addToEachElem(v::SVector, Δv::Real)
    v = v .+ Δv
    return v
end

"""
    addToEachElem(v::AbstractVector, Δv::Real)

DOCSTRING
"""
function addToEachElem(v::AbstractVector, Δv::Real)
    v .= v .+ Δv
    return v
end

"""
    addVec(v::SVector, Δv::SVector)

DOCSTRING
"""
function addVec(v::SVector, Δv::SVector)
    v = v + Δv
    return v
end

"""
    addVec(v::AbstractVector, Δv::AbstractVector)

DOCSTRING
"""
function addVec(v::AbstractVector, Δv::AbstractVector)
    v .= v .+ Δv
    return v
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

DOCSTRING

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

DOCSTRING

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

DOCSTRING
"""
function repVec(v::AbstractVector, v_new)
    v .= v_new
    return v
end

"""
    repVec(v::SVector, v_new)

DOCSTRING
"""
function repVec(v::SVector, v_new)
    n_0 = zero(first(v))
    v = v .* n_0 + v_new
    return v
end

"""
    setComponents(land, helpers, Val{s_main}, Val{s_comps}, Val{zix})

DOCSTRING

# Arguments:
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `helpers`: DESCRIPTION
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