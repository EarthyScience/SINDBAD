export groundWSoilWInteraction

abstract type groundWSoilWInteraction <: LandEcosystem end

include("groundWSoilWInteraction_gradient.jl")
include("groundWSoilWInteraction_gradientNeg.jl")
include("groundWSoilWInteraction_none.jl")
include("groundWSoilWInteraction_VanDijk2010.jl")

@doc """
Groundwater soil moisture interactions (e.g. capilary flux, water

# Approaches:
 - gradient: calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low
 - gradientNeg: calculates a buffer storage that doesn't give water to the soil when the soil dries up; while the soil gives water to the groundW when the soil is wet but the groundW low; the groundW is only recharged by soil moisture
 - none: sets the groundwater capillary flux to zero
 - VanDijk2010: calculates the upward flow of water from groundwater to lowermost soil layer using VanDijk method
"""
groundWSoilWInteraction
