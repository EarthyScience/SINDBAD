export capillaryFlow
"""
Flux of water from lower to upper soil layers (upward soil moisture movement)

# Approaches:
 - VanDijk2010: computes the upward water flow in the soil layers
"""
abstract type capillaryFlow <: LandEcosystem end
include("capillaryFlow_VanDijk2010.jl")
