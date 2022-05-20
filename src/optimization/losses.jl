export loss

"""
loss(y::T, ŷ::T, yσ::T, ::Val{:mse}) where T <:DenseArray
"""
function loss(y::T, ŷ::T, yσ::T, ::Val{:mse}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:nmae1r}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y, ŷ, ::Val{:mse})
    idxs = (.!isnan.(y .* ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:pcor}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return cor(y[idxs], ŷ[idxs])
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:pcor2}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return cor(y[idxs], ŷ[idxs])^2
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:pcor2inv}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return 1.0 - cor(y[idxs], ŷ[idxs])^2
end

function loss(y::T, ŷ::T, yσ::T, symbs::Tuple) where T <:DenseArray
    return sum([loss(y, ŷ, yσ, Val(s)) for s in symbs])
end

nse(y, ŷ, yσ) = 1 .- sum(abs2.((y .- mean(ŷ) ./ yσ))) / (sum(abs2.(y .- mean(y)) ./ yσ))

function loss(y::T, ŷ::T, yσ::T, ::Val{:nseinv}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return 1 .- nse(y[idxs], ŷ[idxs], yσ[idxs])
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:nse}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return nse(y[idxs], ŷ[idxs], yσ[idxs])
end

function loss(y::T, ŷ::T, yσ::T, ::Val{:nnse}) where T <:DenseArray
    idxs = (.!isnan.(y .* ŷ))
    return 1 .- (1 ./ (2 .- nse(y[idxs], ŷ[idxs], yσ[idxs])))
end
