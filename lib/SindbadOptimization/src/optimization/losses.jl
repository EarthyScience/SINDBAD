export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::mse)

mean squared error

``mse = {|y - ŷ|}^2``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::mse)
    return mean(abs2.(y .- ŷ))
end

"""
    loss(y, yσ, ŷ, ::nmae1r)

Relative normalized model absolute error

``nmae1r = \\frac{(|y - ŷ|)}{one(eltype(ŷ)) + y}``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y, yσ, ŷ, ::nmae1r)
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    nmae1r = abs(μ_ŷ - μ_y) / (one(eltype(ŷ)) + μ_y)
    return nmae1r
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor)
    return corspearman(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor2)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor2)
    scor = loss(y, yσ, ŷ, scor())
    return scor * scor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor2inv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::scor2inv)
    scor2inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, scor2())
    return scor2inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor)
    return cor(y, ŷ)
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor2)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor2)
    pcor = loss(y, yσ, ŷ, pcor())
    return pcor * pcor
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor2inv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::pcor2inv)
    pcor2inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, pcor2())
    return pcor2inv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseσ)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseσ)
    nse =
        one(eltype(ŷ)) .-
        sum(abs2.((y .- ŷ) ./ yσ)) /
        sum(abs2.((y .- mean(y)) ./ yσ))
    return nse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseσinv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseσinv)
    nseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, nseσ())
    return nseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseσ)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseσ)
    nse_v = loss(y, yσ, ŷ, :nseσ())
    nnse = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - nse_v)
    return nnse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseσinv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseσinv)
    nnseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, nnseσ())
    return nnseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nse)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nse)
    nse = one(eltype(ŷ)) .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return nse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseinv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nseinv)
    nseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, nse())
    return nseinv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnse)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- ::nnse: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnse)
    nse_v = loss(y, yσ, ŷ, nse())
    nnse = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - nse_v)
    return nnse
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseinv)

DOCSTRING

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: DESCRIPTION
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::nnseinv)
    nnseinv = one(eltype(ŷ)) - loss(y, yσ, ŷ, nnse())
    return nnseinv
end
