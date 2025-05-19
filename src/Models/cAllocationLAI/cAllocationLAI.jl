export cAllocationLAI

abstract type cAllocationLAI <: LandEcosystem end

purpose(::Type{cAllocationLAI}) = "Estimates allocation to the leaf pool given light limitation constraints to photosynthesis. Estimation via dynamics in leaf area index (LAI). Dynamic allocation approach."

includeApproaches(cAllocationLAI, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocationLAI))
"""
cAllocationLAI
