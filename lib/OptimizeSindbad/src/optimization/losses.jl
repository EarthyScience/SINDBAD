export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})

mean squared error

``mse = {|y - ŷ|}^2``
"""

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:mse})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:mse})
    return mean(abs2.(y .- ŷ))
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})

Relative normalized model absolute error

``nmae1r = \\frac{(|y - ŷ|)}{one(eltype(ŷ)) + y}``
"""

"""
    loss(y, yσ, ŷ, nothing::Val{:nmae1r})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y, yσ, ŷ, ::Val{:nmae1r})
    nmae1r = abs(y - ŷ) / (oftype(ŷ, one(eltype(ŷ))) + y)
    return nmae1r
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})

Relative normalized model absolute error

``nmae1r = \\frac{mean(|y - ŷ|)}{one(eltype(ŷ)) + mean(y)}``
"""

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nmae1r})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nmae1r})
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    nmae1r = abs(μ_ŷ - μ_y) / (one(eltype(ŷ)) + μ_y)
    return nmae1r
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:scor})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:scor})
    return corspearman(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:scor2})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:scor2})
    scor = loss(y, yσ, ŷ, Val(:scor))
    return scor * scor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:scor2inv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:scor2inv})
    scor2inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:scor2))
    return scor2inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:pcor})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor})
    return cor(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:pcor2})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2})
    pcor = loss(y, yσ, ŷ, Val(:pcor))
    return pcor * pcor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:pcor2inv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:pcor2inv})
    pcor2inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:pcor2))
    return pcor2inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nseσ})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseσ})
    nse =
        one(eltype(ŷ)) .-
        sum(abs2.((y .- ŷ) ./ yσ)) /
        sum(abs2.((y .- mean(y)) ./ yσ))
    return nse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nseσinv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseσinv})
    nseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:nseσ))
    return nseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nnseσ})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseσ})
    nse_v = loss(y, yσ, ŷ, Val(:nseσ))
    nnse = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - nse_v)
    return nnse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nnseσinv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseσinv})
    nnseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:nnseσ))
    return nnseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nse})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nse})
    nse = one(eltype(ŷ)) .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return nse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nseinv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nseinv})
    nseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:nse))
    return nseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nnse})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnse})
    nse_v = loss(y, yσ, ŷ, Val(:nse))
    nnse = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - nse_v)
    return nnse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, nothing::Val{:nnseinv})

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Val{:nnseinv})
    nnseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Val(:nnse))
    return nnseinv
end
