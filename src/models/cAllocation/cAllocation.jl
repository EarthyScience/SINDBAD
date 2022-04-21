export cAllocation

abstract type cAllocation <: LandEcosystem end

include("cAllocation_fixed.jl")
include("cAllocation_Friedlingstein1999.jl")
include("cAllocation_GSI.jl")
include("cAllocation_none.jl")

@doc """
Combine the different effects of carbon allocation

# Approaches:
 - fixed: compute the fraction of NPP that is allocated to the different plant organs. In this case; the allocation is fixed in time according to the parameters in These parameters are adjusted according to the TreeFrac fraction (land.states.treeFraction). Allocation to roots is partitioned into fine [cf2Root] & coarse roots (cf2RootCoarse) according to Rf2Rc.
 - Friedlingstein1999: compute the fraction of NPP that is allocated to the different plant organs following the scheme of Friedlingstein et al 1999. Check cAlloc_Friedlingstein1999 for details.
 - GSI: compute the fraction of NPP that is allocated to the different plant organs. In this case; the allocation is dynamic in time according to temperature; water & radiation stressors computed from GSI approach.
 - none: set the allocation to zero
"""
cAllocation