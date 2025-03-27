export cFlow

abstract type cFlow <: LandEcosystem end

include("cFlow_CASA.jl")
include("cFlow_GSI.jl")
include("cFlow_none.jl")
include("cFlow_simple.jl")

@doc """
Actual transfers of c between pools (of diagonal components)

# Approaches:
 - CASA: combine all the effects that change the transfers between carbon pools
 - GSI: Precomputations for the transfers between carbon pools based on GSI method. combine all the effects that change the transfers between carbon pools based on GSI method
 - none: set transfer between pools to 0 [i.e. nothing is transfered] set c_giver & c_taker matrices to [] get the transfer matrix transfers
 - simple: combine all the effects that change the transfers between carbon pools
"""
cFlow
