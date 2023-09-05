export groundWSurfaceWInteraction

abstract type groundWSurfaceWInteraction <: LandEcosystem end

include("groundWSurfaceWInteraction_fracGradient.jl")
include("groundWSurfaceWInteraction_fracGroundW.jl")

@doc """
Water exchange between surface and groundwater

# Approaches:
 - fracGradient: calculates the moisture exchange between groundwater & surface water as a fraction of difference between the storages
 - fracGroundW: calculates the depletion of groundwater to the surface water as a fraction of groundwater storage
"""
groundWSurfaceWInteraction
