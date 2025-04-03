export cAllocation

abstract type cAllocation <: LandEcosystem end

purpose(::Type{cAllocation}) = "Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step). Net carbon fixation reduces growth respiratory costs (RA_G) from the gross primary productivity (GPP). For some dynamic approaches, allocation is a function of several factors changing in space and time."

includeApproaches(cAllocation, @__DIR__)

@doc """ 
	$(getBaseDocString(cAllocation))
"""
cAllocation
