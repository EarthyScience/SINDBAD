export NIRv

abstract type NIRv <: LandEcosystem end

include("NIRv_constant.jl")
include("NIRv_forcing.jl")

@doc """
Near-infrared reflectance of terrestrial vegetation

# Approaches:
 - constant: sets the value of NIRv as a constant
 - forcing: sets the value of land.states.NIRv from the forcing in every time step
"""
NIRv
