export ambientCO2
"""
Set/get ambient co2 concentration

# Approaches:
 - constant: sets the value of ambCO2 as a constant
 - forcing: sets the value of land.states.ambCO2 from the forcing in every time step
"""
abstract type ambientCO2 <: LandEcosystem end
include("ambientCO2_constant.jl")
include("ambientCO2_forcing.jl")
