export soilTexture

abstract type soilTexture <: LandEcosystem end

purpose(::Type{soilTexture}) = "Soil texture (sand,silt,clay, and organic matter fraction)"

includeApproaches(soilTexture, @__DIR__)

@doc """ 
	$(getBaseDocString(soilTexture))
"""
soilTexture
