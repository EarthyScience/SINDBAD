export gppDemand

abstract type gppDemand <: LandEcosystem end

include("gppDemand_min.jl")
include("gppDemand_mult.jl")
include("gppDemand_none.jl")

@doc """
Combine effects as multiplicative or minimum

# Approaches:
 - min: compute the demand GPP as minimum of all stress scalars [most limited]
 - mult: compute the demand GPP as multipicative stress scalars
 - none: sets the scalar for demand GPP to ones & demand GPP to zeros
"""
gppDemand