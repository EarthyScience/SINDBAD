export soilWFlow

abstract type soilWFlow <: LandEcosystem end

include("soilWFlow_simple.jl")

@doc """
Calculate the water flow in the soil layers

# Approaches:
 - simple: an algebraic sum of percolation/drainage and capillary flow among soil layers
"""
soilWFlow