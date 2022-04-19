export cTau

abstract type cTau <: LandEcosystem end

include("cTau_none.jl")
include("cTau_simple.jl")

@doc """
Combine effects of different factors on decomposition rates

# Approaches:
 - none: set the actual τ to ones
 - simple: combine all the effects that change the turnover rates [k]
"""
cTau