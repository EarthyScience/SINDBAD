export cAllocationNutrients

abstract type cAllocationNutrients <: LandEcosystem end

include("cAllocationNutrients_Friedlingstein1999.jl")
include("cAllocationNutrients_none.jl")

@doc """
(pseudo)effect of nutrients on carbon allocation

# Approaches:
 - Friedlingstein1999: pseudo-nutrient limitation calculation based on Friedlingstein1999
 - none: sets the pseudo-nutrient limitation to one (no effect)
"""
cAllocationNutrients
