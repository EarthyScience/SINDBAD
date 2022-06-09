export cCycleDisturbance

abstract type cCycleDisturbance <: LandEcosystem end

include("cCycleDisturbance_constant.jl")

@doc """
Disturb the carbon cycle pools

# Approaches:
 - constant: placeholder for scaling the carbon pools with a constant to emulate steady state jump. Actual scaling is done at the end of spinup; but the parameters are written here to bypass setupcode checks & use them in optimization In dyna; the disturbance of cVeg parameters is implemented based on forcing. the disturbance of cVeg parameters is implemented based on forcing
"""
cCycleDisturbance