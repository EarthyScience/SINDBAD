# export update_state_pools
# export cusp, ups
export rep_elem, @rep_elem, rep_vec, @rep_vec
export add_to_elem, @add_to_elem, add_to_each_elem, add_vec

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T}) where T<:Number
#     sp[:] = sp .+ Δs
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}) where T<:Number
#     sp[1] = sp[1] + Δs[1]
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number) where T<:Number
#     sp[1] = sp[1] + Δs
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, level::Int) where T<:Number
#     sp[level] = sp[level] + Δs[1]
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, level::Int) where T<:Number
#     sp[level] = sp[level] + Δs
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, ::Val{:split}) where T<:Number
#     sp[:] = sp .+ Δs[1]/size(sp,1)
#     return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::AbstractArray{T,1}, split::Symbol) where T<:Number
#     return update_state_pools(sp, Δs, Val(split))
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, ::Val{:split}) where T<:Number
#     sp[:] = sp .+ Δs/size(sp,1)
#     return sp
#     #return sp
# end

# function update_state_pools(sp::Union{AbstractArray{T}, Buffer{T, <:AbstractArray{T}}}, Δs::Number, split::Symbol) where T<:Number
#     return update_state_pools(sp, Δs, Val(split))
# end


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

macro rep_elem(outparams::Expr)
    @assert outparams.head == :call || outparams.head == :(=)
    @assert outparams.args[1] == :(=>)
    @assert length(outparams.args) == 3
    lhs = esc(outparams.args[2])
    rhs = outparams.args[3]
    rhsa = rhs.args
    tar = esc(rhsa[1])
    # hp_pool = QuoteNode(rhsa[2])
    indx = rhsa[2]
    hp_pool = rhsa[3]
    outCode = [Expr(:(=), tar, Expr(:call, rep_elem, tar, lhs, esc(Expr(:., :(helpers.pools.zeros), hp_pool)), esc(Expr(:., :(helpers.pools.ones), hp_pool)), esc(:(helpers.numbers.𝟘)), esc(:(helpers.numbers.𝟙)), esc(indx)))]
    # outCode = [Expr(:(=), tar, Expr(:call, :rep_elem, tar, lhs, Expr(:., :(helpers.pools.zeros), hp_pool), Expr(:., :(helpers.pools.ones), hp_pool), :(helpers.numbers.𝟘), :(helpers.numbers.𝟙), indx))]
    return Expr(:block, outCode...)
end

function rep_elem(v::AbstractVector, v_elem, _, _, _, _, ind::Int)
    v[ind] = v_elem
    return v
end

function rep_elem(v::SVector, v_elem, v_zero, v_one, n_𝟘, n_𝟙, ind::Int)
    v_zero = v_zero .* n_𝟘
    v_zero = Base.setindex(v_zero, one(eltype(v_zero)), ind)
    v_one = v_one .* n_𝟘 .+ n_𝟙
    v_one = Base.setindex(v_one, zero(eltype(v_one)), ind)
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
    outCode = [Expr(:(=), lhs, Expr(:call, rep_vec, lhs, rhs, esc(:(helpers.numbers.𝟘))))]
    return Expr(:block, outCode...)
end

function rep_vec(v::AbstractVector, v_new, n_𝟘)
    v .= v_new
    return v
end

function rep_vec(v::SVector, v_new, n_𝟘)
    v = v .* n_𝟘 + v_new
    return v
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
    outCode = [Expr(:(=), tar, Expr(:call, add_to_elem, tar, lhs, esc(Expr(:., :(helpers.pools.zeros), hp_pool)), esc(:(helpers.numbers.𝟘)), esc(indx)))]
    return Expr(:block, outCode...)
end

function add_to_elem(v::SVector, Δv, v_zero, n_𝟘, ind::Int)
    v_zero = v_zero .* n_𝟘
    v_zero = Base.setindex(v_zero, one(eltype(v_zero)), ind)
    v = v .+ v_zero .* Δv
    return v
end

function add_to_elem(v::AbstractVector, Δv, _, _, ind::Int)
    v[ind] = v[ind] + Δv
    return v
end

function add_to_each_elem(v::SVector, Δv::Real)
    v = v .+ Δv
    return v
end

function add_to_each_elem(v::AbstractVector, Δv::Real)
    v .= v .+ Δv
    return v
end

function add_vec(v::SVector, Δv)
    v = v + Δv
    return v
end

function add_vec(v::AbstractVector, Δv)
    v .= v .+ Δv
    return v
end

