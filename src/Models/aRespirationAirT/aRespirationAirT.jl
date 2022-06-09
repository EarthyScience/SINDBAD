export aRespirationAirT

abstract type aRespirationAirT <: LandEcosystem end

include("aRespirationAirT_none.jl")
include("aRespirationAirT_Q10.jl")

@doc """
Temperature effect on autotrophic maintenance respiration

# Approaches:
 - none: sets the effect of temperature on RA to one [no effect]
 - Q10: temperature effect on autotrophic maintenance respiration - Q10 model
"""
aRespirationAirT