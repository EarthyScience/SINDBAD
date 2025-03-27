export drainage

abstract type drainage <: LandEcosystem end

include("drainage_dos.jl")
include("drainage_kUnsat.jl")
include("drainage_wFC.jl")

@doc """
Recharge the soil

# Approaches:
 - dos: downward flow of moisture [drainage] in soil layers based on exponential function of soil moisture degree of saturation
 - kUnsat: downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity
 - wFC: downward flow of moisture [drainage] in soil layers based on overflow over field capacity
"""
drainage
