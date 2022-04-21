export groundWRecharge

abstract type groundWRecharge <: LandEcosystem end

include("groundWRecharge_dos.jl")
include("groundWRecharge_fraction.jl")
include("groundWRecharge_kUnsat.jl")
include("groundWRecharge_none.jl")

@doc """
Recharge to the groundwater storage

# Approaches:
 - dos: GW recharge as a exponential functions of the degree of saturation of the lowermost soil layer
 - fraction: GW recharge as a fraction of moisture of the lowermost soil layer
 - kUnsat: GW recharge as the unsaturated hydraulic conductivity of the lowermost soil layer
 - none: sets the GW recharge to zero
"""
groundWRecharge