export cAllocationNutrients
"""
(pseudo)effect of nutrients on carbon allocation

# Approaches:
 - Friedlingstein1999: pseudo-nutrient limitation [NL] calculation: "There is no explicit estimate of soil mineral nitrogen in the version of CASA used for these simulations. As a surrogate; we assume that spatial variability in nitrogen mineralization & soil organic matter decomposition are identical [Townsend et al. 1995]. Nitrogen availability; N; is calculated as the product of the temperature & moisture abiotic factors used in CASA for the calculation of microbial respiration [Potter et al. 1993]." in Friedlingstein et al., 1999.#
 - none: set the pseudo-nutrient limitation to 1
"""
abstract type cAllocationNutrients <: LandEcosystem end
include("cAllocationNutrients_Friedlingstein1999.jl")
include("cAllocationNutrients_none.jl")
