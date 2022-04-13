export LAI
"""
Leaf area index

# Approaches:
 - constant: sets the value of LAI as a constant
 - cVegLeaf: sets the value of land.states.LAI from the carbon in the leaves of the previous time step
 - forcing: sets the value of land.states.LAI from the forcing in every time step
"""
abstract type LAI <: LandEcosystem end
include("LAI_constant.jl")
include("LAI_cVegLeaf.jl")
include("LAI_forcing.jl")
