export getPools
"""
Get the amount of water at the beginning of timestep

# Approaches:
 - simple: gets the amount of water available for the current time step
"""
abstract type getPools <: LandEcosystem end
include("getPools_simple.jl")
