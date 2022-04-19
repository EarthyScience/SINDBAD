export rainIntensity

abstract type rainIntensity <: LandEcosystem end

include("rainIntensity_forcing.jl")
include("rainIntensity_simple.jl")

@doc """
Set rainfall intensity

# Approaches:
 - forcing: stores the time series of rainfall & snowfall from forcing
 - simple: stores the time series of rainfall intensity
"""
rainIntensity