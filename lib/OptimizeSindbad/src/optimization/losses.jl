export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})

mean squared error

``mse = {|y - ŷ|}^2``
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})
    return mean(abs2.(y .- ŷ))
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})

Relative normalized model absolute error

``nmae1r = \\frac{(|y - ŷ|)}{1.0 + y}``
"""
function loss(y, yσ, ŷ, ::Val{:nmae1r})
    nmae1r = abs(y - ŷ) / (typeof(ŷ)(1.0) + y)
    return nmae1r
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})

Relative normalized model absolute error

``nmae1r = \\frac{mean(|y - ŷ|)}{1.0 + mean(y)}``
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    nmae1r = abs(μ_ŷ - μ_y) / (eltype(ŷ)(1.0) + μ_y)
    return nmae1r
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor})
    return cor(y, ŷ)
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2})
    pcor2 = loss(y, yσ, ŷ, Val(:pcor))^2.0
    return pcor2
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2inv})
    pcor2inv = 1.0 - loss(y, yσ, ŷ, Val(:pcor2))
    return pcor2inv
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseσ})
    nse =
        1.0 .-
        sum(abs2.((y .- ŷ) ./ yσ)) /
        sum(abs2.((y .- mean(y)) ./ yσ))
    return nse
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseσinv})
    nseinv = 1.0 - loss(y, yσ, ŷ, Val(:nseσ))
    return nseinv
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseσ})
    nse_v = loss(y, yσ, ŷ, Val(:nseσ))
    nnse = 1.0 / (2.0 - nse_v)
    return nnse
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseσinv})
    nnseinv = 1.0 - loss(y, yσ, ŷ, Val(:nnseσ))
    return nnseinv
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nse})
    nse = 1.0 .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return nse
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseinv})
    nseinv = 1.0 - loss(y, yσ, ŷ, Val(:nse))
    return nseinv
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnse})
    nse_v = loss(y, yσ, ŷ, Val(:nse))
    nnse = 1.0 / (2.0 - nse_v)
    return nnse
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseinv})
    nnseinv = 1.0 - loss(y, yσ, ŷ, Val(:nnse))
    return nnseinv
end
