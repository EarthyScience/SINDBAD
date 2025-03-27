export runoffOverland

abstract type runoffOverland <: LandEcosystem end

include("runoffOverland_Inf.jl")
include("runoffOverland_InfIntSat.jl")
include("runoffOverland_none.jl")
include("runoffOverland_Sat.jl")

@doc """
calculates total overland runoff that passes to the surface storage

# Approaches:
 - Inf: assumes overland flow to be infiltration excess runoff
 - InfIntSat: assumes overland flow to be sum of infiltration excess, interflow, and saturation excess runoffs
 - none: sets overland runoff to zero
 - Sat: assumes overland flow to be saturation excess runoff
"""
runoffOverland
