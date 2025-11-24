export cAllocationNutrients

abstract type cAllocationNutrients <: LandEcosystem end

purpose(::Type{cAllocationNutrients}) = "Pseudo-effect of nutrients on carbon allocation."

includeApproaches(cAllocationNutrients, @__DIR__)

@doc """ 
	$(getProcessDocstring(cAllocationNutrients))
"""
cAllocationNutrients
