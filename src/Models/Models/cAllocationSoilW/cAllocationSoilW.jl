export cAllocationSoilW

abstract type cAllocationSoilW <: LandEcosystem end

include("cAllocationSoilW_Friedlingstein1999.jl")
include("cAllocationSoilW_gpp.jl")
include("cAllocationSoilW_gppGSI.jl")
include("cAllocationSoilW_none.jl")

@doc """
Effect of soil moisture on carbon allocation

# Approaches:
 - Friedlingstein1999: partial moisture effect on decomposition/mineralization based on Friedlingstein1999
 - gpp: moisture effect on allocation = the same as gpp
 - gppGSI: moisture effect on allocation from same for GPP based on GSI approach
 - none: sets the moisture effect on allocation to one (no effect)
"""
cAllocationSoilW