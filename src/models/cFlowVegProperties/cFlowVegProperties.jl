export cFlowVegProperties

abstract type cFlowVegProperties <: LandEcosystem end

include("cFlowVegProperties_CASA.jl")
include("cFlowVegProperties_none.jl")

@doc """
Effect of vegetation properties on the c transfers between pools

# Approaches:
 - CASA: effects of vegetation that change the transfers between carbon pools
 - none: set transfer between pools to 0 [i.e. nothing is transfered]
"""
cFlowVegProperties