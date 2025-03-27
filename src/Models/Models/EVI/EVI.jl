export EVI

abstract type EVI <: LandEcosystem end

include("EVI_constant.jl")
include("EVI_forcing.jl")

@doc """
Enhanced vegetation index

# Approaches:
 - constant: sets the value of EVI as a constant
 - forcing: sets the value of land.states.EVI from the forcing in every time step
"""
EVI