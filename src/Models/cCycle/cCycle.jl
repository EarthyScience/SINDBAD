export cCycle

abstract type cCycle <: LandEcosystem end

include("cCycle_CASA.jl")
include("cCycle_simple.jl")
include("cCycle_GSI.jl")

@doc """
Allocate carbon to vegetation components

# Approaches:
 - CASA: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools
 - simple: Calculate decay rates for the ecosystem C pools at appropriate time steps. Perform carbon cycle between pools
"""
cCycle
