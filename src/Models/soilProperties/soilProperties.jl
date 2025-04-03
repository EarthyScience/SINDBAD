export soilProperties

abstract type soilProperties <: LandEcosystem end

purpose(::Type{soilProperties}) = "Soil properties (hydraulic properties)"

includeApproaches(soilProperties, @__DIR__)

@doc """ 
	$(getBaseDocString(soilProperties))
"""
soilProperties
