export transpirationDemand
"""
Demand-driven transpiration

# Approaches:
 - CASA: calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model
 - fPET: calculate the climate driven demand for transpiration as a function of PET & α for vegetation
 - fPETfAPAR: calculate the climate driven demand for transpiration as a function of PET & fAPAR
 - fPETvegFraction: calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction
 - PET: set the climate driven demand for transpiration equal to PET
"""
abstract type transpirationDemand <: LandEcosystem end
include("transpirationDemand_CASA.jl")
include("transpirationDemand_fPET.jl")
include("transpirationDemand_fPETfAPAR.jl")
include("transpirationDemand_fPETvegFraction.jl")
include("transpirationDemand_PET.jl")
