export soilTexture

abstract type soilTexture <: LandEcosystem end

include("soilTexture_constant.jl")
include("soilTexture_forcing.jl")

@doc """
Soil texture (sand,silt,clay, and organic matter fraction)

# Approaches:
 - constant: sets the soil texture properties as constant
 - forcing: sets the soil texture properties from input
"""
soilTexture
