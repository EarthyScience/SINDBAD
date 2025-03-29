export groundWSurfaceWInteraction

abstract type groundWSurfaceWInteraction <: LandEcosystem end

purpose(::Type{groundWSurfaceWInteraction}) = "Water exchange between surface and groundwater"

includeApproaches(groundWSurfaceWInteraction, @__DIR__)

@doc """ 
	$(getBaseDocString(groundWSurfaceWInteraction))
"""
groundWSurfaceWInteraction
