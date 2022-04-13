export transpiration
"""
If coupled, computed from gpp and aoe from wue

# Approaches:
 - coupled: calculate the actual transpiration as function of gppAct & WUE
 - demandSupply: calculate the actual transpiration as the minimum of the supply & demand
 - none: sets the actual transpiration to zeros
"""
abstract type transpiration <: LandEcosystem end
include("transpiration_coupled.jl")
include("transpiration_demandSupply.jl")
include("transpiration_none.jl")
