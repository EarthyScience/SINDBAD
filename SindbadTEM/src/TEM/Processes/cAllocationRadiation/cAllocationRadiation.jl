export cAllocationRadiation

abstract type cAllocationRadiation <: LandEcosystem end

purpose(::Type{cAllocationRadiation}) = "Effect of radiation on carbon allocation."

includeApproaches(cAllocationRadiation, @__DIR__)

@doc """ 
	$(getProcessDocstring(cAllocationRadiation))
"""
cAllocationRadiation
