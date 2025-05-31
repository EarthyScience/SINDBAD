export cAllocationLAI

abstract type cAllocationLAI <: LandEcosystem end

purpose(::Type{cAllocationLAI}) = "Estimates allocation to the leaf pool given light limitation constraints to photosynthesis, using LAI dynamics."

includeApproaches(cAllocationLAI, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocationLAI))
"""
cAllocationLAI
