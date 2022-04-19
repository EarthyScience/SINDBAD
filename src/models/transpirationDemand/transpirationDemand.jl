export transpirationDemand

abstract type transpirationDemand <: LandEcosystem end

include("transpirationDemand_CASA.jl")
include("transpirationDemand_PET.jl")
include("transpirationDemand_PETfAPAR.jl")
include("transpirationDemand_PETvegFraction.jl")

@doc """
Demand-driven transpiration

# Approaches:
 - CASA: calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model
 - PET: calculate the climate driven demand for transpiration as a function of PET & α for vegetation
 - PETfAPAR: calculate the climate driven demand for transpiration as a function of PET & fAPAR
 - PETvegFraction: calculate the climate driven demand for transpiration as a function of PET & α for vegetation; & vegetation fraction
"""
transpirationDemand