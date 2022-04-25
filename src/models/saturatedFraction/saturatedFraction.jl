export saturatedFraction

abstract type saturatedFraction <: LandEcosystem end

include("saturatedFraction_none.jl")

@doc """
Saturated fraction of a grid cell

# Approaches:
 - none: sets the land.states.soilWSatFrac [saturated soil fraction] to 𝟘  (pix, 1)
"""
saturatedFraction