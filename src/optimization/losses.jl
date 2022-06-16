export loss

"""
loss(y::T, yσ::T, ŷ::T, ::Val{:mse}) where T <:DenseArray
"""
function loss(y::T, yσ::T, ŷ::T, ::Val{:mse}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nmae1r}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    nmae1r = mean(abs.(y[idxs]-ŷ[idxs])) / (1.0 + mean(y[idxs]))
    return nmae1r
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:pcor}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return cor(y[idxs], ŷ[idxs])
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:pcor2}) where T <:DenseArray
    pcor2 = loss(y, yσ, ŷ, Val(:pcor)) ^ 2.0
    return pcor2
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:pcor2inv}) where T <:DenseArray
    pcor2inv = 1.0 - loss(y, yσ, ŷ, Val(:pcor2)) 
    return pcor2inv
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nse}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    # nse = 1.0 .- sum(abs2.((y[idxs] .- ŷ[idxs]))) / sum(abs2.((y[idxs] .- mean(y[idxs]))))
    nse = 1.0 .- sum(abs2.((y[idxs] .- ŷ[idxs]) ./ yσ[idxs])) / sum(abs2.((y[idxs] .- mean(y[idxs])) ./ yσ[idxs]))
    return nse
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nseinv}) where T <:DenseArray
    nseinv = 1.0 - loss(y, yσ, ŷ, Val(:nse))
    return nseinv
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nnse}) where T <:DenseArray
    nse_v = loss(y, yσ, ŷ, Val(:nse))
    nnse = 1.0 / (2.0 - nse_v)
    return nnse
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nnseinv}) where T <:DenseArray
    nnseinv = 1.0 - loss(y, yσ, ŷ, Val(:nnse))
    return nnseinv
end
