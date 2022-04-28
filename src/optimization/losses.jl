abstract type metric end
struct mse <: metric end
struct cor <: metric end

#loss(y, yh, ::Val{:mse}) = 124
#loss(y, yh, ::Val{:mse}) = 124


"""
loss(y::Matrix, ŷ::Matrix)
"""
function loss(y::Matrix, ŷ::Matrix, ::Val{:mse})
    return mean(skipmissing(abs2.(y .- ŷ)))
end

function loss(y::Matrix, ŷ::Matrix, ::Val{:cor})
    return cor(skipmissing(abs2.(y .- ŷ)))
end