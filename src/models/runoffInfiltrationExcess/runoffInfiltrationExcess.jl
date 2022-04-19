export runoffInfiltrationExcess

abstract type runoffInfiltrationExcess <: LandEcosystem end

include("runoffInfiltrationExcess_Jung.jl")
include("runoffInfiltrationExcess_kUnsat.jl")
include("runoffInfiltrationExcess_none.jl")

@doc """
Infiltration excess runoff

# Approaches:
 - Jung: compute infiltration excess runoff
 - kUnsat: calculates the infiltration excess runoff based on unsτrated hydraulic conductivity
 - none: sets infiltration excess runoff to zeros
"""
runoffInfiltrationExcess