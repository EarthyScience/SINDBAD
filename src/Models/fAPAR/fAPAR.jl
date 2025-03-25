export fAPAR

abstract type fAPAR <: LandEcosystem end

include("fAPAR_constant.jl")
include("fAPAR_cVegLeaf.jl")
include("fAPAR_EVI.jl")
include("fAPAR_forcing.jl")
include("fAPAR_LAI.jl")
include("fAPAR_vegFraction.jl")
include("fAPAR_cVegLeafBareFrac.jl")

@doc """
Fraction of absorbed photosynthetically active radiation

# Approaches:
 - constant: sets the value of fAPAR as a constant
 - cVegLeaf: Compute FAPAR based on carbon pool of the leaves
 - EVI: calculates the value of fAPAR as a linear function of EVI
 - forcing: sets the value of fAPAR from the forcing
 - LAI: calculate fAPAR as an exponential function of LAI
 - frac_vegetation: calculate fAPAR as a linear function of vegetated fraction 
"""
fAPAR
