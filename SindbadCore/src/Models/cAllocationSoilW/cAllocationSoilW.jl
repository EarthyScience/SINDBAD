export cAllocationSoilW

abstract type cAllocationSoilW <: LandEcosystem end

purpose(::Type{cAllocationSoilW}) = "Effect of soil moisture on carbon allocation."

includeApproaches(cAllocationSoilW, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocationSoilW))
"""
cAllocationSoilW
