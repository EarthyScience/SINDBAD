export loss

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)

mean squared error

``MSE = {|y - ŷ|}^2``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::MSE`: mean square error
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)
    return mean(abs2.(y .- ŷ))
end

"""
    loss(y, yσ, ŷ, ::NAME1R)

Relative normalized absolute mean error

``NAME1R = \\frac{(|μ_ŷ - μ_y|)}{1 + μ_y}``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NAME1R`: relatively normalized absolute mean error
"""
function loss(y, yσ, ŷ, ::NAME1R)
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    NMAE1R = abs(μ_ŷ - μ_y) / (one(eltype(ŷ)) + μ_y)
    return NMAE1R
end

"""
    loss(y, yσ, ŷ, ::NMAE1R)

Relative normalized mean absolute error

``NMAE1R = \\frac{(mean(|y - ŷ|))}{1 + μ_y}``

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NMAE1R`: relatively normalized mean absolute error
"""
function loss(y, yσ, ŷ, ::NMAE1R)
    μ_y = mean(y)
    NMAE1R = mean(abs.(ŷ - y)) / (one(eltype(ŷ)) + μ_y)
    return NMAE1R
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- ::NNSE: normalized nash sutcliffe efficiency
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)
    NSE_v = loss(y, yσ, ŷ, NSE())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NNSEInv`: inverse of normalized nash sutcliffe efficiency
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)
    NNSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NNSE())
    return NNSEInv
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NNSEσ`: normalized nash sutcliffe efficiency with uncertainty
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)
    NSE_v = loss(y, yσ, ŷ, :NSEσ())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NNSEσInv`: inverse of normalized nash sutcliffe efficiency with uncertainty
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)
    NNSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NNSEσ())
    return NNSEInv
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcor)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NPcor`: normalized Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcor)
    r = cor(y, ŷ)
    one_r = one(r)
    n_r = one_r / (one_r + one_r -r)
    return n_r
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcorInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NPcorInv`: inverse of normalized Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcorInv)
    n_r = loss(y, yσ, ŷ, NPcor())
    return one(n_r) - n_r
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScor)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NScor`: normalized Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScor)
    ρ = corspearman(y, ŷ)
    one_ρ = one(ρ)
    n_ρ = one_ρ / (one_ρ + one_ρ -ρ)
    return n_ρ
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScorInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NScorInv`: inverse of normalized Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScorInv)
    n_ρ = loss(y, yσ, ŷ, NScor())
    return one(n_ρ) - n_ρ
end



"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NSE`: nash sutcliffe efficiency
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)
    NSE = one(eltype(ŷ)) .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return NSE
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NSEInv`: inverse of nash sutcliffe efficiency
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)
    NSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NSE())
    return NSEInv
end



"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσ)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NSEσ`: nash sutcliffe efficiency with uncertainty
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



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::NSEσInv`: inverse of nash sutcliffe efficiency with uncertainty
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσInv)
    NSEInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, NSEσ())
    return NSEInv
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::Pcor`: Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)
    return cor(y[:], ŷ[:])
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::PcorInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::PcorInv`: inverse of Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::PcorInv)
    rInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Pcor())
    return rInv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::Pcor2`: square of Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)
    r = loss(y, yσ, ŷ, Pcor())
    return r * r
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::Pcor2Inv`: inverse of square of Pearson's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)
    r2Inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Pcor2())
    return r2Inv
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)
    return corspearman(y[:], ŷ[:])
end


"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::ScorInv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `::ScorInv`: inverse of Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::ScorInv)
    ρInv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Scor())
    return ρInv
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: square of Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)
    ρ = loss(y, yσ, ŷ, Scor())
    return ρ * ρ
end

"""
    loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)



# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate
- `nothing`: inverse of square of Spearman's correlation
"""
function loss(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)
    ρ2Inv = one(eltype(ŷ)) - loss(y, yσ, ŷ, Scor2())
    return ρ2Inv
end
