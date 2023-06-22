export runoffInfiltrationExcess

abstract type runoffInfiltrationExcess <: LandEcosystem end

include("runoffInfiltrationExcess_Jung.jl")
include("runoffInfiltrationExcess_kUnsat.jl")
include("runoffInfiltrationExcess_none.jl")

@doc """
Infiltration excess runoff

# Approaches:
 - Jung: infiltration excess runoff as a function of rainintensity and vegetated fraction
 - kUnsat: infiltration excess runoff based on unsτrated hydraulic conductivity hydraulic conductivity
 - none: sets infiltration excess runoff to zero
"""
runoffInfiltrationExcess
