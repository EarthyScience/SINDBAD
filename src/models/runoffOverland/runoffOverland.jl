export runoffOverland

abstract type runoffOverland <: LandEcosystem end

include("runoffOverland_Inf.jl")
include("runoffOverland_InfIntSat.jl")
include("runoffOverland_none.jl")
include("runoffOverland_Sat.jl")

@doc """
Land over flow (sum of saturation and infiltration excess runoff)

# Approaches:
 - Inf: calculates total overland runoff that passes to the surface storage
 - InfIntSat: calculates total overland runoff that passes to the surface storage
 - none: sets overland runoff to zero
 - Sat: calculates total overland runoff that passes to the surface storage
"""
runoffOverland