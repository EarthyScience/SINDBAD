export cFlowSoilProperties

abstract type cFlowSoilProperties <: LandEcosystem end

include("cFlowSoilProperties_CASA.jl")
include("cFlowSoilProperties_none.jl")

@doc """
Effect of soil properties on the c transfers between pools

# Approaches:
 - CASA: effects of soil that change the transfers between carbon pools
 - none: set transfer between pools to 0 [i.e. nothing is transfered]
"""
cFlowSoilProperties
