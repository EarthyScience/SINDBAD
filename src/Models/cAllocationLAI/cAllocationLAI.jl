export cAllocationLAI

abstract type cAllocationLAI <: LandEcosystem end

include("cAllocationLAI_Friedlingstein1999.jl")
include("cAllocationLAI_none.jl")

@doc """
Estimates allocation to the leaf pool given light limitation constraints to photosynthesis. Estimation via dynamics in leaf area index (LAI). Dynamic allocation approach.

# Approaches:
 - Friedlingstein1999: LAI effect on allocation based on light limitation from Friedlingstein1999
 - none: sets the LAI effect on allocation to one (no effect)
"""
cAllocationLAI
