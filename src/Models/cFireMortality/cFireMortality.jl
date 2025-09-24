export cFireMortality

abstract type cFireMortality <: LandEcosystem end
purpose(::Type{cFireMortality}) = "Disturbance of the carbon cycle pools due to fire."
includeApproaches(cFireMortality, @__DIR__)

@doc """
Accounts for carbon emissions due to fire

# Approaches:
- none
- vanDerWerf2004: uses the van der Werf et al. (2004) method to calculate fire mortality.

*Created by*
    - Nuno | nunocarvalhais
"""
cFireMortality