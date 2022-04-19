export waterBalance

abstract type waterBalance <: LandEcosystem end

include("waterBalance_simple.jl")

@doc """
Calculate the water balance

# Approaches:
 - simple: check the water balance in every time step
"""
waterBalance