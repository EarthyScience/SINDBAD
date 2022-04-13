export cAllocationSoilW
"""
Effect of soil moisture on carbon allocation

# Approaches:
 - Friedlingstein1999: Compute partial computation for the moisture effect on decomposition/mineralization
 - gpp: set the moisture effect on C allocation to the same as gpp from GSI approach.
 - gppGSI: compute the moisture effect on C allocation computed from GSI approach.
 - none: 
"""
abstract type cAllocationSoilW <: LandEcosystem end
include("cAllocationSoilW_Friedlingstein1999.jl")
include("cAllocationSoilW_gpp.jl")
include("cAllocationSoilW_gppGSI.jl")
include("cAllocationSoilW_none.jl")
