export cFireMortality

abstract type cFireMortality <: LandEcosystem end

include("cFireMortality_none.jl")
include("cFireMortality_vanDerWerf2004.jl")


@doc """
Accounts for carbon emissions due to fire

# Approaches:
- none
- vanDerWerf2004: uses the van der Werf et al. (2004) method to calculate fire mortality.

*Created by*
    - Nuno | nunocarvalhais
"""
cFireMortality