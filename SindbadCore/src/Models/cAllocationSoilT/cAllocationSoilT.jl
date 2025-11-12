export cAllocationSoilT

abstract type cAllocationSoilT <: LandEcosystem end

purpose(::Type{cAllocationSoilT}) = "Effect of soil temperature on carbon allocation."

includeApproaches(cAllocationSoilT, @__DIR__)

@doc """ 
	$(getModelDocString(cAllocationSoilT))
"""
cAllocationSoilT
