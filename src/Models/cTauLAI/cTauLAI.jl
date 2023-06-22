export cTauLAI

abstract type cTauLAI <: LandEcosystem end

include("cTauLAI_CASA.jl")
include("cTauLAI_none.jl")

@doc """
Calculate litterfall scalars (that affect the changes in the vegetation k)

# Approaches:
 - CASA: calc LAI stressor on τ. Compute the seasonal cycle of litter fall & root litter "fall" based on LAI variations. Necessarily in precomputation mode
 - none: set values to ones
"""
cTauLAI
