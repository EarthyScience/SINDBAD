export cAllocationLAI
"""
Effect of lai on carbon allocation

# Approaches:
 - Friedlingstein1999: Compute the light limitation [LL] calculation
 - none: set the allocation to ones
"""
abstract type cAllocationLAI <: LandEcosystem end
include("cAllocationLAI_Friedlingstein1999.jl")
include("cAllocationLAI_none.jl")
