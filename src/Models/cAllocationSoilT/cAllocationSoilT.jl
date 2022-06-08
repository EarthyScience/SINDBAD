export cAllocationSoilT

abstract type cAllocationSoilT <: LandEcosystem end

include("cAllocationSoilT_Friedlingstein1999.jl")
include("cAllocationSoilT_gpp.jl")
include("cAllocationSoilT_gppGSI.jl")
include("cAllocationSoilT_none.jl")

@doc """
Effect of soil temperature on carbon allocation

# Approaches:
 - Friedlingstein1999: partial temperature effect on decomposition/mineralization based on Friedlingstein1999
 - gpp: temperature effect on allocation = the same as gpp
 - gppGSI: temperature effect on allocation from same for GPP based on GSI approach
 - none: sets the temperature effect on allocation to one (no effect)
"""
cAllocationSoilT