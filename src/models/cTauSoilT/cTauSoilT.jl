export cTauSoilT
"""
Effect of soil temperature on decomposition rates

# Approaches:
 - none: set the outputs to ones
 - Q10: Compute effect of temperature on psoil carbon fluxes
"""
abstract type cTauSoilT <: LandEcosystem end
include("cTauSoilT_none.jl")
include("cTauSoilT_Q10.jl")
