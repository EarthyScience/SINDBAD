export cTauVegProperties
"""
Effect of vegetation properties on soil decomposition rates

# Approaches:
 - CASA: Compute effect of vegetation type on turnover rates [k]
 - none: set the outputs to ones
"""
abstract type cTauVegProperties <: LandEcosystem end
include("cTauVegProperties_CASA.jl")
include("cTauVegProperties_none.jl")
