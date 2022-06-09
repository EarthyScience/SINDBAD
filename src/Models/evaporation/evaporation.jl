export evaporation

abstract type evaporation <: LandEcosystem end

include("evaporation_bareFraction.jl")
include("evaporation_demandSupply.jl")
include("evaporation_fAPAR.jl")
include("evaporation_none.jl")
include("evaporation_Snyder2000.jl")
include("evaporation_vegFraction.jl")

@doc """
Soil evaporation

# Approaches:
 - bareFraction: calculates the bare soil evaporation from 1-vegFraction of the grid & PETsoil
 - demandSupply: calculates the bare soil evaporation from demand-supply limited approach. calculates the bare soil evaporation from the grid using PET & supply limit
 - fAPAR: calculates the bare soil evaporation from 1-fAPAR & PET soil
 - none: sets the soil evaporation to zero
 - Snyder2000: calculates the bare soil evaporation using relative drying rate of soil
 - vegFraction: calculates the bare soil evaporation from 1-vegFraction & PET soil
"""
evaporation