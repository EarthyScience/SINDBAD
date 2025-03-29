export NDVI

abstract type NDVI <: LandEcosystem end

purpose(::Type{NDVI}) = "Normalized difference vegetation index"

includeApproaches(NDVI, @__DIR__)

@doc """ 
	$(getBaseDocString(NDVI))
"""
NDVI
