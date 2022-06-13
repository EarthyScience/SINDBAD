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
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
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

nse(y, yσ, ŷ) = 1.0 .- sum(abs2.((y .- mean(ŷ) ./ yσ))) / (sum(abs2.(y .- mean(y)) ./ yσ))

function loss(y::T, yσ::T, ŷ::T, ::Val{:nse}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return nse(y[idxs], yσ[idxs], ŷ[idxs])
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nseinv}) where T <:DenseArray
    nseinv = 1.0 - loss(y, yσ, ŷ, Val(:nse))
    return nseinv
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nnse}) where T <:DenseArray
    idxs = (.!isnan.(y .* yσ .* ŷ))
    nse_v = nse(y[idxs], yσ[idxs], ŷ[idxs])
    nnse = 1.0 / (2.0 - nse_v)
    return nnse
end

function loss(y::T, yσ::T, ŷ::T, ::Val{:nnseinv}) where T <:DenseArray
    nnseinv = 1.0 - loss(y, yσ, ŷ, Val(:nnse))
    return nnseinv
end
