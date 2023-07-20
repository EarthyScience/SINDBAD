export rootWaterEfficiency

abstract type rootWaterEfficiency <: LandEcosystem end

include("rootWaterEfficiency_constant.jl")
include("rootWaterEfficiency_expCvegRoot.jl")
include("rootWaterEfficiency_k2fRD.jl")
include("rootWaterEfficiency_k2fvegFraction.jl")
include("rootWaterEfficiency_k2Layer.jl")

@doc """
Distribution of water uptake fraction/efficiency by root per soil layer

# Approaches:
 - constant: sets the maximum fraction of water that root can uptake from soil layers as constant
 - expCvegRoot: Precomputation for maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]
 - k2fRD: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction; & for the second soil layer additional as function of RD
 - k2fvegFraction: sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction
 - k2Layer: sets the maximum fraction of water that root can uptake from soil layers as calibration parameter; hard coded for 2 soil layers
"""
rootWaterEfficiency
