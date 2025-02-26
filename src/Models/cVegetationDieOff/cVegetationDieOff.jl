export cVegetationDieOff

abstract type cVegetationDieOff <: LandEcosystem end

include("cVegetationDieOff_forcing.jl")

@doc """
Disturb the carbon cycle pools

# Approaches:
 - forcing: reads and packs the fraction of vegetation that dies off (c transferred to litter pools)
 """
cVegetationDieOff
