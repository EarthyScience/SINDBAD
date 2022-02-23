export transpirationSupply

abstract type transpirationSupply <: LandEcosystem end

include("transpirationSupply_CASA.jl")
include("transpirationSupply_Federer1982.jl")
include("transpirationSupply_wAWC.jl")
include("transpirationSupply_wAWCvegFraction.jl")

@doc """
Supply-limited transpiration

# Approaches:
 - CASA: calculate the supply limited transpiration as function of volumetric soil content & soil properties; as in the CASA model
 - Federer1982: calculate the supply limited transpiration as a function of max rate parameter & avaialable water
 - wAWC: calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture
 - wAWCvegFraction: calculate the supply limited transpiration as the minimum of fraction of total AWC & the actual available moisture; scaled by vegetated fractions
"""
transpirationSupply