export groundWSoilWInteraction

abstract type groundWSoilWInteraction <: LandEcosystem end

purpose(::Type{groundWSoilWInteraction}) = "Groundwater soil moisture interactions (e.g. capilary flux, water"

includeApproaches(groundWSoilWInteraction, @__DIR__)

@doc """ 
	$(getBaseDocString(groundWSoilWInteraction))
"""
groundWSoilWInteraction
