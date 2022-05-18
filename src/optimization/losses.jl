export loss

"""
loss(y::Matrix, ŷ::Matrix)
"""
function loss(y::Matrix, ŷ::Matrix, ::Val{:mse})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y, ŷ, ::Val{:mse})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:pcor})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return cor(y[idxs], ŷ[idxs])
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:pcor2})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return 1.0 - cor(y[idxs], ŷ[idxs])^2
end

function loss(y::Matrix, ŷ::Matrix, symbs)
    return sum([loss(y, ŷ, Val(s)) for s in symbs])
end

function loss(y::Matrix, ŷ::Matrix, yσ, ::Val{:nse})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return 1 .- (1 .- sum(abs2.(y[idxs] .- mean(ŷ[idxs])))/(sum(abs2.(y[idxs] .- mean(y[idxs]))./yσ)))
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:nse})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return 1 .- (1 .- sum(abs2.(y[idxs] .- mean(ŷ[idxs]))) / (sum(abs2.(y[idxs] .- mean(y[idxs])))))
end

function loss(y, ŷ, ::Val{:nmae1r})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

function loss(y, ŷ, ::Val{:mefinv})
    idxs = (.!isnan.(y)) .& (.!isnan.(ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end