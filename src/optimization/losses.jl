"""
loss(y::Matrix, ŷ::Matrix)
"""
function loss(y::Matrix, ŷ::Matrix, ::Val{:mse})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:cor})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return cor(y[idxs], ŷ[idxs])
end

function loss(y::Matrix, ŷ::Matrix, symbs)
    return sum([loss(y, ŷ, Val(s)) for s in symbs])
end
