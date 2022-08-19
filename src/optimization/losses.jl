export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})
mean squared error

``
mse = {|y - ŷ|}^2
``
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})
    # push!(Sindbad.error_catcher, (; y, yσ, ŷ))
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return mean(abs2.(y[idxs] .- ŷ[idxs]))
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})
Relative normalized model absolute error

``
mse = \\frac{mean(|y - ŷ|)}{1.0 + mean(y)}
``
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r}) 
    idxs = (.!isnan.(y .* yσ .* ŷ))
    nmae1r = mean(abs.(y[idxs]-ŷ[idxs])) / (1.0 + mean(y[idxs]))
    return nmae1r
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor}) 
    idxs = (.!isnan.(y .* yσ .* ŷ))
    return cor(y[idxs], ŷ[idxs])
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2}) 
    pcor2 = loss(y, yσ, ŷ, Val(:pcor)) ^ 2.0
    return pcor2
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2inv}) 
    pcor2inv = 1.0 - loss(y, yσ, ŷ, Val(:pcor2)) 
    return pcor2inv
end

function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseσ}) 
    idxs = (.!isnan.(y .* yσ .* ŷ))
    nse = 1.0 .- sum(abs2.((y[idxs] .- ŷ[idxs]) ./ yσ[idxs])) / sum(abs2.((y[idxs] .- mean(y[idxs])) ./ yσ[idxs]))
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
    idxs = (.!isnan.(y .* ŷ))
    nse = 1.0 .- sum(abs2.((y[idxs] .- ŷ[idxs]))) / sum(abs2.((y[idxs] .- mean(y[idxs]))))
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
