export drainage

abstract type drainage <: LandEcosystem end

include("drainage_dos.jl")
include("drainage_kUnsat.jl")
include("drainage_wFC.jl")

@doc """
Recharge the soil

# Approaches:
 - dos: computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity
 - kUnsat: computes the downward flow of moisture [drainage] in soil layers based on unsaturated hydraulic conductivity
 - wFC: computes the downward flow of moisture [drainage] in soil layers based on overflow from the upper layers
"""
drainage