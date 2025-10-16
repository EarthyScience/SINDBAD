export NIRv

abstract type NIRv <: LandEcosystem end

purpose(::Type{NIRv}) = "Near-infrared reflectance of terrestrial vegetation."

includeApproaches(NIRv, @__DIR__)

@doc """ 
	$(getModelDocString(NIRv))
"""
NIRv
