export PET
"""
Set potential evapotranspiration

# Approaches:
 - forcing: sets the value of land.PET.PET from the forcing
 - Lu2005: Calculates the value of land.PET.PET from the forcing variables
 - PriestleyTaylor1972: Calculates the value of land.PET.PET from the forcing variables
"""
abstract type PET <: LandEcosystem end
include("PET_forcing.jl")
include("PET_Lu2005.jl")
include("PET_PriestleyTaylor1972.jl")
