export evapotranspiration
"""
Calculate the evapotranspiration as a sum of components

# Approaches:
 - sum: calculates evapotranspiration as a sum of all potential components
"""
abstract type evapotranspiration <: LandEcosystem end
include("evapotranspiration_sum.jl")
