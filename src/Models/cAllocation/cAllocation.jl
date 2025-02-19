export cAllocation

abstract type cAllocation <: LandEcosystem end

include("cAllocation_fixed.jl")
include("cAllocation_Friedlingstein1999.jl")
include("cAllocation_GSI.jl")
include("cAllocation_none.jl")

@doc """
Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step). Net carbon fixation reduces growth respiratory costs (RA_G) from the gross primary productivity (GPP). For some dynamic approaches, allocation is a function of several factors changing in space and time.

# Approaches:
 - fixed: computes a fixed fraction of carbon that is allocated to the different plant organs. The allocation is fixed in time according to the input parameters.
 - Friedlingstein1999: computes the fraction of carbon that is allocated to the different plant organs following the scheme of Friedlingstein et al 1999. Dynamic in time. Check cAlloc_Friedlingstein1999 for details.
 - GSI: compute the fraction of carbon that is allocated to the different plant organs according to temperature, water & radiation stressors computed from the GSI approach. Allocation is dynamic in time.
 - none: sets the carbon allocation to zero (nothing is allocated to vegetation carbon pools).
"""
cAllocation
