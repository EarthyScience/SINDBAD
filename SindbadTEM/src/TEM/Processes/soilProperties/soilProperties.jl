export soilProperties

abstract type soilProperties <: LandEcosystem end

purpose(::Type{soilProperties}) = "Soil hydraulic properties."

includeApproaches(soilProperties, @__DIR__)

@doc """ 
	$(getProcessDocstring(soilProperties))
"""
soilProperties
