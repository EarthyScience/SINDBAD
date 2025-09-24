export cFireCombustionCompleteness

abstract type cFireCombustionCompleteness <: LandEcosystem end
purpose(::Type{cFireCombustionCompleteness}) = "Disturbance of the carbon cycle pools due to fire, combustion completeness."
includeApproaches(cFireCombustionCompleteness, @__DIR__)

@doc """
Accounts for carbon emissions due to fire, combustion completeness.

# Approaches:
- none: no fire forcing, no emissions
- vanDerWerf2006: uses the van der Werf et al. (2006) method to calculate combustion completeness.

*Created by*
    - Nuno | nunocarvalhais

"""
cFireCombustionCompleteness