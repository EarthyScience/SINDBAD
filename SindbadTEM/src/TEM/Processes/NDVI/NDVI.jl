export NDVI

abstract type NDVI <: LandEcosystem end

purpose(::Type{NDVI}) = "Normalized Difference Vegetation Index."

includeApproaches(NDVI, @__DIR__)

@doc """ 
	$(getProcessDocstring(NDVI))
"""
NDVI
