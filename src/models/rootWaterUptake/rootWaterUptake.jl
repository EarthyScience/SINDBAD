export rootWaterUptake

abstract type rootWaterUptake <: LandEcosystem end

include("rootWaterUptake_proportion.jl")
include("rootWaterUptake_topBottom.jl")

@doc """
Root water uptake (extract water from soil)

# Approaches:
 - proportion: rootUptake from each soil layer proportional to the relative plant water availability in the layer
 - topBottom: rootUptake from each of the soil layer from top to bottom using all water in each layer
"""
rootWaterUptake