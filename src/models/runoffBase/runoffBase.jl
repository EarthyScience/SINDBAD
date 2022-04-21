export runoffBase

abstract type runoffBase <: LandEcosystem end

include("runoffBase_none.jl")
include("runoffBase_Zhang2008.jl")

@doc """
Baseflow

# Approaches:
 - none: sets the base runoff to zero
 - Zhang2008: computes baseflow from a linear ground water storage
"""
runoffBase