export cAllocationNutrients

abstract type cAllocationNutrients <: LandEcosystem end

purpose(::Type{cAllocationNutrients}) = "(pseudo)effect of nutrients on carbon allocation"

includeApproaches(cAllocationNutrients, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocationNutrients))
"""
cAllocationNutrients
