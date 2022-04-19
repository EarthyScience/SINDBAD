export cAllocationSoilT

abstract type cAllocationSoilT <: LandEcosystem end

include("cAllocationSoilT_Friedlingstein1999.jl")
include("cAllocationSoilT_gpp.jl")
include("cAllocationSoilT_gppGSI.jl")
include("cAllocationSoilT_none.jl")

@doc """
Effect of soil temperature on carbon allocation

# Approaches:
 - Friedlingstein1999: Compute partial computation for the temperature effect on decomposition/mineralization
 - gpp: compute the temperature effect on C allocation to the same as gpp.
 - gppGSI: compute the temperature effect on C allocation based on GSI approach.
 - none: 
"""
cAllocationSoilT