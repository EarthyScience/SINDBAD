export aRespirationAirT

abstract type aRespirationAirT <: LandEcosystem end

include("aRespirationAirT_none.jl")
include("aRespirationAirT_Q10.jl")

@doc """
Temperature effect on autotrophic maintenance respiration

# Approaches:
 - none: sets the effect of temperature on RA to none [ones = no effect]
 - Q10: estimate the effect of temperature in autotrophic maintenance respiration - q10 model
"""
aRespirationAirT