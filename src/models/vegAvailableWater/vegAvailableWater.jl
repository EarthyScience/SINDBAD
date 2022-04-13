export vegAvailableWater
"""
Plant available water

# Approaches:
 - rootFraction: sets the maximum fraction of water that root can uptake from soil layers as constant. calculate the actual amount of water that is available for plants
 - sigmoid: calculate the actual amount of water that is available for plants
"""
abstract type vegAvailableWater <: LandEcosystem end
include("vegAvailableWater_rootFraction.jl")
include("vegAvailableWater_sigmoid.jl")
