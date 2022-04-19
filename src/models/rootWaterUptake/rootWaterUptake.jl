export rootWaterUptake

abstract type rootWaterUptake <: LandEcosystem end

include("rootWaterUptake_proportion.jl")
include("rootWaterUptake_topBottom.jl")

@doc """
Root water uptake (extract water from soil)

# Approaches:
 - proportion: calculates the rootUptake from each of the soil layer proportional to the root fraction
 - topBottom: calculates the rootUptake from each of the soil layer from top to bottom
"""
rootWaterUptake