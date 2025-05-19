export cAllocation

abstract type cAllocation <: LandEcosystem end

purpose(::Type{cAllocation}) = "Compute the allocation of C fixed by photosynthesis to the different vegetation pools (fraction of the net carbon fixation received by each vegetation carbon pool on every times step)."

includeApproaches(cAllocation, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocation))
"""
cAllocation
