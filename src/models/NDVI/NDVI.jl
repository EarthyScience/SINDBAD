export NDVI
"""
Normalized difference vegetation index

# Approaches:
 - constant: sets the value of NDVI as a constant
 - forcing: sets the value of land.states.NDVI from the forcing in every time step
"""
abstract type NDVI <: LandEcosystem end
include("NDVI_constant.jl")
include("NDVI_forcing.jl")
