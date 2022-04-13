export saturatedFraction
"""
Saturated fraction of a grid cell

# Approaches:
 - none: sets the land.states.soilWSatFrac [saturated soil fraction] to zeros (pix, 1)
"""
abstract type saturatedFraction <: LandEcosystem end
include("saturatedFraction_none.jl")
