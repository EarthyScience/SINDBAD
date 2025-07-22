export cFireBurnedArea

abstract type cFireBurnedArea <: LandEcosystem end

include("cFireBurnedArea_none.jl")
include("cFireBurnedArea_forcing.jl")

@doc """
Accounts for carbon emissions due to fire

# Approaches:
- none: no fire forcing, no emissions
- forcing: uses fire forcing data to calculate emissions

*Created by*
    - Nuno | nunocarvalhais

"""
cFireBurnedArea