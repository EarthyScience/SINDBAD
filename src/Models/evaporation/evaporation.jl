export evaporation

abstract type evaporation <: LandEcosystem end

purpose(::Type{evaporation}) = "Soil evaporation"

includeApproaches(evaporation, @__DIR__)

@doc """ 
	$(getBaseDocString(evaporation))
"""
evaporation
