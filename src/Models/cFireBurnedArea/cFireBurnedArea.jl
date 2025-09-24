export cFireBurnedArea

abstract type cFireBurnedArea <: LandEcosystem end
purpose(::Type{cFireBurnedArea}) = "Disturbance of the carbon cycle pools due to fire."
includeApproaches(cFireBurnedArea, @__DIR__)

@doc """
Accounts for carbon emissions due to fire

# Approaches:
- none: no fire forcing, no emissions
- forcing: uses fire forcing data to calculate emissions

*Created by*
    - Nuno | nunocarvalhais

"""
cFireBurnedArea