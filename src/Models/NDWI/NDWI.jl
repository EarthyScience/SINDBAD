export NDWI

abstract type NDWI <: LandEcosystem end

purpose(::Type{NDWI}) = "Normalized difference water index"

includeApproaches(NDWI, @__DIR__)

@doc """ 
	$(getModelDocString(NDWI))
"""
NDWI
