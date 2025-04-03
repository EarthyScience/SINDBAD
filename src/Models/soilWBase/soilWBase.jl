export soilWBase

abstract type soilWBase <: LandEcosystem end

purpose(::Type{soilWBase}) = "Distribution of soil hydraulic properties over depth"

includeApproaches(soilWBase, @__DIR__)

@doc """ 
	$(getBaseDocString(soilWBase))
"""
soilWBase
