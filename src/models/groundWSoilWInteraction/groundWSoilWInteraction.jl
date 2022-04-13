export groundWSoilWInteraction
"""
Groundwater soil moisture interactions (e.g. capilary flux, water

# Approaches:
 - gradient: calculates a buffer storage that gives water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low; the buffer is only recharged by soil moisture. calculates groundW[1] storage that gives water to the soil when the soil dries up; while the soil gives water to the groundW[1] when the soil is wet but the groundW[1] low; the groundW[1] is only recharged by soil moisture
 - gradientNeg: calculates a buffer storage that doesn"t give water to the soil when the soil dries up; while the soil gives water to the buffer when the soil is wet but the buffer low; the buffer is only recharged by soil moisture. calculates a buffer storage that doesn"t give water to the soil when the soil dries up; while the soil gives water to the groundW[1] when the soil is wet but the groundW[1] low; the groundW[1] is only recharged by soil moisture
 - none: sets the groundwater capillary flux to zeros
 - VanDijk2010: calculates the upward flow of water from groundwater to lowermost soil layer
"""
abstract type groundWSoilWInteraction <: LandEcosystem end
include("groundWSoilWInteraction_gradient.jl")
include("groundWSoilWInteraction_gradientNeg.jl")
include("groundWSoilWInteraction_none.jl")
include("groundWSoilWInteraction_VanDijk2010.jl")
