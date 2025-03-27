export cAllocationRadiation

abstract type cAllocationRadiation <: LandEcosystem end

include("cAllocationRadiation_gpp.jl")
include("cAllocationRadiation_GSI.jl")
include("cAllocationRadiation_none.jl")

@doc """
Effect of radiation on carbon allocation

# Approaches:
 - gpp: radiation effect on decomposition/mineralization = the same for GPP
 - GSI: radiation effect on decomposition/mineralization using GSI method
 - none: sets the radiation effect on allocation to one (no effect)
"""
cAllocationRadiation
