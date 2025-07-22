export cFireCombustionCompleteness

abstract type cFireCombustionCompleteness <: LandEcosystem end

include("cFireCombustionCompleteness_vanDerWerf2006.jl")
include("cFireCombustionCompleteness_none.jl")


@doc """
Accounts for carbon emissions due to fire, combustion completeness.

# Approaches:
- none: no fire forcing, no emissions
- vanDerWerf2006: uses the van der Werf et al. (2006) method to calculate combustion completeness.

*Created by*
    - Nuno | nunocarvalhais

"""
cFireCombustionCompleteness