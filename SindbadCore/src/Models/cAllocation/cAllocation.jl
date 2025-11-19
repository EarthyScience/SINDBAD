export cAllocation

abstract type cAllocation <: LandEcosystem end

purpose(::Type{cAllocation}) = "Allocation fraction of NPP to different vegetation pools."

includeApproaches(cAllocation, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocation))
"""
cAllocation
