export fAPAR
"""
Fraction of absorbed photosynthetically active radiation

# Approaches:
 - constant: sets the value of fAPAR as a constant
 - cVegLeaf: Compute FAPAR based on carbon pool of the leave; SLA; kLAI
 - forcing: sets the value of land.states.fAPAR from the forcing in every time step
 - LAI: 
 - VegFrac: 
"""
abstract type fAPAR <: LandEcosystem end
include("fAPAR_constant.jl")
include("fAPAR_cVegLeaf.jl")
include("fAPAR_forcing.jl")
include("fAPAR_LAI.jl")
include("fAPAR_VegFrac.jl")
