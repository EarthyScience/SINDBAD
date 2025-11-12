export EVI

abstract type EVI <: LandEcosystem end

purpose(::Type{EVI}) = "Enhanced Vegetation Index"

includeApproaches(EVI, @__DIR__)

@doc """ 
	$(getModelDocString(EVI))
"""
EVI
