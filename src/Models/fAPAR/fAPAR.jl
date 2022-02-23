export fAPAR

abstract type fAPAR <: LandEcosystem end

include("fAPAR_constant.jl")
include("fAPAR_cVegLeaf.jl")
include("fAPAR_forcing.jl")
include("fAPAR_LAI.jl")
include("fAPAR_vegFraction.jl")

@doc """
Fraction of absorbed photosynthetically active radiation

# Approaches:
 - constant: sets the value of fAPAR as a constant
 - cVegLeaf: Compute FAPAR based on carbon pool of the leaves
 - forcing: sets the value of fAPAR from the forcing
 - LAI: calculate fAPAR as an exponential function of LAI
 - vegFraction: calculate fAPAR as a linear function of vegetated fraction 
"""
fAPAR