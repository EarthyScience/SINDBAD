"""
loss(y::Matrix, ŷ::Matrix)
"""
function loss(y::Matrix, ŷ::Matrix, ::Val{:mse})
    return mean(skipmissing(abs2.(y .- ŷ)))
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:cor})
    return cor(skipmissing(abs2.(y .- ŷ)))
end

