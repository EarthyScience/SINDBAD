export runoffInterflow

abstract type runoffInterflow <: LandEcosystem end

include("runoffInterflow_none.jl")
include("runoffInterflow_residual.jl")

@doc """
Interflow

# Approaches:
 - none: sets interflow runoff to zero
 - residual: calculates interflow as a fraction of the available water
"""
runoffInterflow