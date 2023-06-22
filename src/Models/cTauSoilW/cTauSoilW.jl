export cTauSoilW

abstract type cTauSoilW <: LandEcosystem end

include("cTauSoilW_CASA.jl")
include("cTauSoilW_GSI.jl")
include("cTauSoilW_none.jl")

@doc """
Effect of soil moisture on decomposition rates

# Approaches:
 - CASA: Compute effect of soil moisture on soil decomposition as modelled in CASA [BGME - below grounf moisture effect]. The below ground moisture effect; taken directly from the century model; uses soil moisture from the previous month to determine a scalar that is then used to determine the moisture effect on below ground carbon fluxes. BGME is dependent on PET; Rainfall. This approach is designed to work for Rainfall & PET values at the monthly time step & it is necessary to scale it to meet that criterion.
 - GSI: calculate the moisture stress for cTau based on temperature stressor function of CASA & Potter
 - none: set the moisture stress for all carbon pools to ones
"""
cTauSoilW
