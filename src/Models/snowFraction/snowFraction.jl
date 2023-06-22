export snowFraction

abstract type snowFraction <: LandEcosystem end

include("snowFraction_binary.jl")
include("snowFraction_HTESSEL.jl")
include("snowFraction_none.jl")

@doc """
Calculate snow cover fraction

# Approaches:
 - binary: compute the snow pack & fraction of snow cover.
 - HTESSEL: computes the snow pack & fraction of snow cover following the HTESSEL approach
 - none: sets the snow fraction to zero
"""
snowFraction
