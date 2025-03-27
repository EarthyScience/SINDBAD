export vegAvailableWater

abstract type vegAvailableWater <: LandEcosystem end

include("vegAvailableWater_rootWaterEfficiency.jl")
include("vegAvailableWater_sigmoid.jl")

@doc """
Plant available water

# Approaches:
 - rootWaterEfficiency: sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants
 - sigmoid: calculate the actual amount of water that is available for plants
"""
vegAvailableWater
