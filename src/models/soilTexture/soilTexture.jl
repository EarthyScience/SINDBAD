export soilTexture

abstract type soilTexture <: LandEcosystem end

include("soilTexture_fixed.jl")
include("soilTexture_forcing.jl")

@doc """
Soil texture (sand,silt,clay, and organic matter fraction)

# Approaches:
 - fixed: sets the soil texture properties as constant
 - forcing: sets the soil texture properties from input
"""
soilTexture