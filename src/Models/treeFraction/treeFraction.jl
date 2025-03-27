export treeFraction

abstract type treeFraction <: LandEcosystem end

include("treeFraction_constant.jl")
include("treeFraction_forcing.jl")

@doc """
Fractional coverage of trees

# Approaches:
 - constant: sets the value of treeFraction as a constant
 - forcing: sets the value of land.states.treeFraction from the forcing in every time step
"""
treeFraction
