export transpiration

abstract type transpiration <: LandEcosystem end

include("transpiration_coupled.jl")
include("transpiration_demandSupply.jl")
include("transpiration_none.jl")

@doc """
If coupled, computed from gpp and aoe from wue

# Approaches:
 - coupled: calculate the actual transpiration as function of gpp & WUE
 - demandSupply: calculate the actual transpiration as the minimum of the supply & demand
 - none: sets the actual transpiration to zero
"""
transpiration
