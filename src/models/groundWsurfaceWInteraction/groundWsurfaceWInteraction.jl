export groundWsurfaceWInteraction

abstract type groundWsurfaceWInteraction <: LandEcosystem end

include("groundWsurfaceWInteraction_fracGradient.jl")
include("groundWsurfaceWInteraction_fracWgw.jl")

@doc """
Water exchange between surface and groundwater

# Approaches:
 - fracGradient: calculates the moisture exchange between groundwater & surface water as a fraction of difference between the storages
 - fracWgw: calculates the depletion of groundwater to the surface water
"""
groundWsurfaceWInteraction