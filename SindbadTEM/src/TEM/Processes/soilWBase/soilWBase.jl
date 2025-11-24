export soilWBase

abstract type soilWBase <: LandEcosystem end

purpose(::Type{soilWBase}) = "Base soil hydraulic properties over soil layers."

includeApproaches(soilWBase, @__DIR__)

@doc """ 
	$(getProcessDocstring(soilWBase))
"""
soilWBase
