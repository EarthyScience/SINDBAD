export NDWI

abstract type NDWI <: LandEcosystem end

purpose(::Type{NDWI}) = "Normalized Difference Water Index."

includeApproaches(NDWI, @__DIR__)

@doc """ 
	$(getProcessDocstring(NDWI))
"""
NDWI
