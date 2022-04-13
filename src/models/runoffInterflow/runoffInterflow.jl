export runoffInterflow
"""
Interflow

# Approaches:
 - none: sets interflow runoff to zeros
 - residual: calculates interflow as a fraction of the available water
"""
abstract type runoffInterflow <: LandEcosystem end
include("runoffInterflow_none.jl")
include("runoffInterflow_residual.jl")
