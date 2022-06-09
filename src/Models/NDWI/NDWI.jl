export NDWI

abstract type NDWI <: LandEcosystem end

include("NDWI_constant.jl")
include("NDWI_forcing.jl")

@doc """
Normalized difference water index

# Approaches:
 - constant: sets the value of NDWI as a constant
 - forcing: sets the value of land.states.NDWI from the forcing in every time step
"""
NDWI