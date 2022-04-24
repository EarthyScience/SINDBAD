export cAllocationLAI

abstract type cAllocationLAI <: LandEcosystem end

include("cAllocationLAI_Friedlingstein1999.jl")
include("cAllocationLAI_none.jl")

@doc """
Effect of LAI on carbon allocation

# Approaches:
 - Friedlingstein1999: LAI effect on allocation based on light limitation from Friedlingstein1999
 - none: sets the LAI effect on allocation to one (no effect)
"""
cAllocationLAI