export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)

mean squared error

``MSE = {|y - ŷ|}^2``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)
    return mean(abs2.(y .- ŷ))
end

"""
    loss(y, yσ, ŷ, ::NMAE1R)

Relative normalized model absolute error

``NMAE1R = \\frac{(|y - ŷ|)}{one(eltype(ŷ)) + y}``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y, yσ, ŷ, ::NMAE1R)
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    NMAE1R = abs(μ_ŷ - μ_y) / (one(eltype(ŷ)) + μ_y)
    return NMAE1R
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)
    return corspearman(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)
    Scor = loss(y, yσ, ŷ, Scor())
    return Scor * Scor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)
    Scor2Inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Scor2())
    return Scor2Inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)
    return cor(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)
    Pcor = loss(y, yσ, ŷ, Pcor())
    return Pcor * Pcor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)
    Pcor2Inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Pcor2())
    return Pcor2Inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσ)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσ)
    NSE =
        one(eltype(ŷ)) .-
        sum(abs2.((y .- ŷ) ./ yσ)) /
        sum(abs2.((y .- mean(y)) ./ yσ))
    return NSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσInv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσInv)
    NSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NSEσ())
    return NSEInv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)
    NSE_v = loss(y, yσ, ŷ, :NSEσ())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)
    NNSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NNSEσ())
    return NNSEInv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)
    NSE = one(eltype(ŷ)) .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return NSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)
    NSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NSE())
    return NSEInv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- ::NNSE: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)
    NSE_v = loss(y, yσ, ŷ, NSE())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)
    NNSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NNSE())
    return NNSEInv
end
