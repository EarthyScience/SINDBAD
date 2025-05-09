export metric

@doc """

    metric(y::AbstractArray, yσ::AbstractArray, ŷ::AbstractArray, <: PerfMetric)

calculate the performance/loss metric for given observation and model simulation data stream

# Arguments:
  - `y`: observation data
  - `yσ`: observational uncertainty data
  - `ŷ`: model simulation data
    
# Returns:
- `metric`: The calculated metric value

$(methodsOf(PerfMetric))
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
    NSE_v = metric(y, yσ, ŷ, NSEσ())
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
