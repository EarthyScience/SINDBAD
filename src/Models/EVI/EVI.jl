export EVI

abstract type EVI <: LandEcosystem end

purpose(::Type{EVI}) = "Enhanced vegetation index"

includeApproaches(EVI, @__DIR__)

@doc """ 
	$(getModelDocString(EVI))
"""
EVI
