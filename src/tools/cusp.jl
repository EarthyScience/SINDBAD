export update_state_pools
export cusp, usp
export rep_elem, @rep_elem
export add_to_elem, @add_to_elem

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T}) where T<:Number
    sp[:] = sp .+ Δs
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}) where T<:Number
    sp[1] = sp[1] + Δs[1]
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number) where T<:Number
    sp[1] = sp[1] + Δs
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, level::Int) where T<:Number
    sp[level] = sp[level] + Δs[1]
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, level::Int) where T<:Number
    sp[level] = sp[level] + Δs
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, ::Val{:split}) where T<:Number
    sp[:] = sp .+ Δs[1]/size(sp,1)
    return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, split::Symbol) where T<:Number
    return update_state_pools(sp, Δs, Val(split))
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, ::Val{:split}) where T<:Number
    sp[:] = sp .+ Δs/size(sp,1)
    return sp
    #return sp
end

function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, split::Symbol) where T<:Number
    return update_state_pools(sp, Δs, Val(split))
end

@doc """
`update_state_pools(sp, Δs)`

`update_state_pools(sp, Δs, level)`

`update_state_pools(sp, Δs, :split)`

> Level-wise updates of states or pools by a Δsp amount, namely, at a given `level` (matrix entry) or splitted across all entries.

---

!!! abstract "Defaults and options"
	- If `size(sp)=size(Δs)` then the update is done element-wise.
    - If `Δs` is a `Number` or an Array of size 1, the update is done in the first level. 
    - Passing an additional argument specifying the level to perform the update is also possible.
    - If `Δs` is a `Number` or an Array of size 1 and `:split` is used then `Δs` is divided by `size(sp,1)` and the output is added element-wise to sp.
---

"""
update_state_pools

# function cusp(sp, Δsp) # cusp
#     b_sp = Buffer(sp)
#     copyto!(b_sp, sp)
#     b_sp = update_state_pools(b_sp, Δsp)
#     return copy(b_sp)
# end

# function cusp(sp, Δsp, split_level::Union{Symbol, Int})
#     b_sp = Buffer(sp)
#     copyto!(b_sp, sp)
#     b_sp = update_state_pools(b_sp, Δsp, split_level)
#     return copy(b_sp)
# end

function cusp(sp::SubArray, Δsp)
    sp .= sp .+ Δsp
end

function cusp(sp::SubArray, Δsp, sp_zero, split_level::Int)
    sp[split_level] = sp[split_level] .+ Δsp
    return sp
end

function cusp(sp::SubArray, Δsp, sp_zero, split_level::Vector{Int})
    for sp_sl in split_level
        sp[sp_sl] = sp[sp_sl] + Δsp
    end
    return sp
end

function cusp(sp::SubArray, sp_elem, split_level::Int)
    sp[split_level] = sp_elem
    return sp
end

function ups(sp::SubArray, sp_elem, split_level::Vector{Int})
    for sp_sl in split_level
        sp[sp_sl] = sp_elem
    end
    return sp
end

function cusp(sp::Array, Δsp)
    sp .= sp .+ Δsp
end

function cusp(sp::Array, Δsp, sp_zero, split_level::Int)
    sp[split_level] = sp[split_level] .+ Δsp
    return sp
end


function cusp(sp::Array, Δsp, sp_zero, split_level::Vector{Int})
    for sp_sl in split_level
        cusp(sp, Δsp, sp_zero, sp_sl)
    end
    return sp
end

function ups(sp::Array, sp_elem, split_level::Int)
    sp[split_level] = sp_elem
    return sp
end

function ups(sp::Array, sp_elem, split_level::Vector{Int})
    for sp_sl in split_level
        sp=ups(sp, sp_elem, sp_sl)
    end
    return sp
end


function cusp(sp::SVector, Δsp)
    sp = sp .+ Δsp
end

# function cusp(sp::SVector, Δsp, sp_zero::SVector, split_level::Int)
#     sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), split_level)
#     sp = sp .+ sp_zero .* Δsp
#     return sp

# end

# function cusp(sp::SVector, Δsp, sp_zero::SVector, split_level::Int)
#     sp_zero = zeros(SVector{length(Δsp)})
#     sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), split_level)
#     sp = sp .+ sp_zero .* Δsp
#     return sp
# end


function cusp(sp::SVector, Δsp, sp_zero, 𝟘, split_level::Int)
    sp_zero = sp_zero .* 𝟘
    sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), split_level)
    sp = sp .+ sp_zero .* Δsp
    return sp
end

# v1 = zeros(SVector{length(ΔsnowW)})
#     v1 = Base.setindex(v1,one(Float64),1)
#     ΔsnowW = ΔsnowW .+ v1.*snow



function cusp(sp::SVector, Δsp, sp_zero, split_level::Vector{Int})
    for sp_sl in split_level
        sp = cusp(sp, Δsp, sp_zero, sp_sl)
    end
    return sp
end

function ups(sp::SVector, sp_elem, sp_zero, sp_one, 𝟘, 𝟙, split_level::Int)
    sp_zero = sp_zero .* 𝟘
    sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), split_level)
    sp_one = sp_one .* 𝟘 .+ 𝟙
    sp_one = Base.setindex(sp_one, zero(eltype(sp_one)), split_level)
    sp = sp .* sp_one .+ sp_zero .* sp_elem
    # sp = Base.setindex(sp, sp_elem, split_level)
    return sp
end

function ups(sp::SVector, sp_elem, split_level::Vector{Int})
    for sp_sl in split_level
        sp = ups(sp, sp_elem, sp_sl)
    end
    return sp
end

macro rep_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    hp_pool = QuoteNode(rhsa[2])
    indx = rhsa[3]
    outCode = [Expr(:(=), tar, Expr(:call, :rep_elem, tar, lhs, esc(Expr(:., :(helpers.pools.zeros), hp_pool)), esc(Expr(:., :(helpers.pools.ones), hp_pool)), esc(:(helpers.numbers.𝟘)), esc(:(helpers.numbers.𝟙)), esc(indx)))]
    # outCode = [Expr(:(=), tar, Expr(:call, :rep_elem, tar, lhs, Expr(:., :(helpers.pools.zeros), hp_pool), Expr(:., :(helpers.pools.ones), hp_pool), :(helpers.numbers.𝟘), :(helpers.numbers.𝟙), indx))]
    return Expr(:block, outCode...)
end

function rep_elem(sp::SVector, sp_elem, sp_zero, sp_one, 𝟘, 𝟙, ind::Int)
    sp_zero = sp_zero .* 𝟘
    sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), ind)
    sp_one = sp_one .* 𝟘 .+ 𝟙
    sp_one = Base.setindex(sp_one, zero(eltype(sp_one)), ind)
    sp = sp .* sp_one .+ sp_zero .* sp_elem
    # sp = Base.setindex(sp, sp_elem, split_level)
    return sp
end

macro add_to_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = outparams.args[2]
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    hp_pool = QuoteNode(rhsa[2])
    indx = rhsa[3]
    # outCode = [Expr(:(=), tar, Expr(:call, :add_to_elem, tar, lhs, Expr(:., :(helpers.pools.zeros), hp_pool), :(helpers.numbers.𝟘), indx))]
    outCode = [Expr(:(=), tar, Expr(:call, :add_to_elem, tar, lhs, esc(Expr(:., :(helpers.pools.zeros), hp_pool)), esc(:(helpers.numbers.𝟘)), esc(indx)))]
    return Expr(:block, outCode...)
end

function add_to_elem(sp::SVector, Δsp, sp_zero, 𝟘, ind::Int)
    sp_zero = sp_zero .* 𝟘
    sp_zero = Base.setindex(sp_zero, one(eltype(sp_zero)), ind)
    sp = sp .+ sp_zero .* Δsp
    return sp
end


@doc """
`cusp(sp, Δsp)`

`cusp(sp, Δsp, split_level)`

> Convenient function to apply `update_state_pools` compatible with Zygote, namely, backpropagation.

---

!!! abstract "Defaults and options"
    - If `split_level` is not used then defaults for `update_state_pools` with the two arguments `sp, Δsp` are applied.
    - `split_level`: Can be either the symbol `:split` or a Int number for a specific level.
---

"""
cusp