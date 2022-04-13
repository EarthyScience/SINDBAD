export groundWRecharge
"""
Recharge the groundwater

# Approaches:
 - dos: calculates GW recharge as a fraction of soil moisture of the lowermost layer
 - fraction: calculates GW recharge as a fraction of soil moisture of the lowermost layer
 - kUnsat: calculates GW recharge as the unsaturated hydraulic conductivity of lowermost soil layer
 - none: set the GW recharge to zeros
"""
abstract type groundWRecharge <: LandEcosystem end
include("groundWRecharge_dos.jl")
include("groundWRecharge_fraction.jl")
include("groundWRecharge_kUnsat.jl")
include("groundWRecharge_none.jl")
