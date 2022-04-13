export waterBalance
"""
Calculate the water balance

# Approaches:
 - simple: check the water balance in every time step
"""
abstract type waterBalance <: LandEcosystem end
include("waterBalance_simple.jl")
