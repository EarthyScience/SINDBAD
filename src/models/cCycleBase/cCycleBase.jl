export cCycleBase

abstract type cCycleBase <: LandEcosystem end

include("cCycleBase_CASA.jl")
include("cCycleBase_GSI.jl")
include("cCycleBase_simple.jl")

@doc """
Pool structure of the carbon cycle

# Approaches:
 - CASA: Compute carbon to nitrogen ratio & annual turnover rates
 - GSI: Compute carbon to nitrogen ratio & annual turnover rates
 - simple: Compute carbon to nitrogen ratio & annual turnover rates
"""
cCycleBase