export cAllocationRadiation
"""
Effect of radiation on carbon allocation

# Approaches:
 - gpp: computation for the radiation effect on decomposition/mineralization as the same for GPP
 - GSI: computation for the radiation effect on decomposition/mineralization using a GSI method
 - none: 
"""
abstract type cAllocationRadiation <: LandEcosystem end
include("cAllocationRadiation_gpp.jl")
include("cAllocationRadiation_GSI.jl")
include("cAllocationRadiation_none.jl")
