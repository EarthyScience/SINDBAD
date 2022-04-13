export cTauSoilProperties
"""
Effect of soil texture on soil decomposition rates

# Approaches:
 - CASA: Compute soil texture effects on turnover rates [k] of cMicSoil
 - none: Set soil texture effects to ones (ineficient, should be pix zix_mic)
"""
abstract type cTauSoilProperties <: LandEcosystem end
include("cTauSoilProperties_CASA.jl")
include("cTauSoilProperties_none.jl")
