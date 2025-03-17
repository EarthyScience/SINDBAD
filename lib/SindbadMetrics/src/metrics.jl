export metric

"""
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NAME1R)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NMAE1R)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcor)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcorInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScor)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScorInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσ)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::PcorInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::ScorInv)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)
    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)

Calculate the metric from a given method.

# Arguments:
- `y`: observation data
- `yσ`: observational uncertainty data
- `ŷ`: model simulation data/estimate

## Metrics supported:
- `::MSE`: mean squared error. ``MSE = {|y - ŷ|}^2``
- `::NAME1R`: relatively normalized absolute mean error. ``NAME1R = \\frac{(|μ_ŷ - μ_y|)}{1 + μ_y}``
- `::NMAE1R`: relatively normalized mean absolute error. ``NMAE1R = \\frac{(mean(|y - ŷ|))}{1 + μ_y}``
- `::NNSE`: normalized Nash-Sutcliffe efficiency
- `::NNSEInv`: inverse of normalized Nash-Sutcliffe efficiency
- `::NNSEσ`: normalized Nash-Sutcliffe efficiency with uncertainty
- `::NNSEσInv`: inverse of normalized Nash-Sutcliffe efficiency with uncertainty
- `::NPcor`: normalized Pearson's correlation
- `::NPcorInv`: inverse of normalized Pearson's correlation
- `::NScor`: normalized Spearman's correlation
- `::NScorInv`: inverse of normalized Spearman's correlation
- `::NSE`: Nash-Sutcliffe efficiency
- `::NSEInv`: inverse of Nash-Sutcliffe efficiency
- `::NSEσ`: Nash-Sutcliffe efficiency with uncertainty
- `::NSEσInv`: inverse of Nash-Sutcliffe efficiency with uncertainty
- `::Pcor`: Pearson's correlation
- `::PcorInv`: inverse of Pearson's correlation
- `::Pcor2`: square of Pearson's correlation
- `::Pcor2Inv`: inverse of square of Pearson's correlation
- `::Scor`: Spearman's correlation
- `::ScorInv`: inverse of Spearman's correlation
- `::Scor2`: square of Spearman's correlation
- `::Scor2Inv`: inverse of square of Spearman's correlation
"""
metric

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::MSE)
    return mean(abs2.(y .- ŷ))
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NAME1R)
    μ_y = mean(y)
    μ_ŷ = mean(ŷ)
    NMAE1R = abs(μ_ŷ - μ_y) / (one(eltype(ŷ)) + μ_y)
    return NMAE1R
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NMAE1R)
    μ_y = mean(y)
    NMAE1R = mean(abs.(ŷ - y)) / (one(eltype(ŷ)) + μ_y)
    return NMAE1R
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSE)
    NSE_v = metric(y, yσ, ŷ, NSE())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEInv)
    NNSEInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, NNSE())
    return NNSEInv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσ)
    NSE_v = metric(y, yσ, ŷ, :NSEσ())
    NNSE = one(eltype(ŷ)) / (one(eltype(ŷ)) + one(eltype(ŷ)) - NSE_v)
    return NNSE
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NNSEσInv)
    NNSEInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, NNSEσ())
    return NNSEInv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcor)
    r = cor(y, ŷ)
    one_r = one(r)
    n_r = one_r / (one_r + one_r -r)
    return n_r
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NPcorInv)
    n_r = metric(y, yσ, ŷ, NPcor())
    return one(n_r) - n_r
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScor)
    ρ = corspearman(y, ŷ)
    one_ρ = one(ρ)
    n_ρ = one_ρ / (one_ρ + one_ρ -ρ)
    return n_ρ
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NScorInv)
    n_ρ = metric(y, yσ, ŷ, NScor())
    return one(n_ρ) - n_ρ
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSE)
    NSE = one(eltype(ŷ)) .- sum(abs2.((y .- ŷ))) / sum(abs2.((y .- mean(y))))
    return NSE
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEInv)
    NSEInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, NSE())
    return NSEInv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσ)
    NSE =
        one(eltype(ŷ)) .-
        sum(abs2.((y .- ŷ) ./ yσ)) /
        sum(abs2.((y .- mean(y)) ./ yσ))
    return NSE
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::NSEσInv)
    NSEInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, NSEσ())
    return NSEInv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor)
    return cor(y[:], ŷ[:])
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::PcorInv)
    rInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, Pcor())
    return rInv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2)
    r = metric(y, yσ, ŷ, Pcor())
    return r * r
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Pcor2Inv)
    r2Inv = one(eltype(ŷ)) - metric(y, yσ, ŷ, Pcor2())
    return r2Inv
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor)
    return corspearman(y[:], ŷ[:])
end

function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::ScorInv)
    ρInv = one(eltype(ŷ)) - metric(y, yσ, ŷ, Scor())
    return ρInv
end
function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2)
    ρ = metric(y, yσ, ŷ, Scor())
    return ρ * ρ
end
function metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, ::Scor2Inv)
    ρ2Inv = one(eltype(ŷ)) - metric(y, yσ, ŷ, Scor2())
    return ρ2Inv
end
