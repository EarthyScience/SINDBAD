export percolation
"""
Calculate the soil percolation = wbp at this point

# Approaches:
 - WBP: computes the percolation into the soil after the surface runoff & evaporation processes are complete
"""
abstract type percolation <: LandEcosystem end
include("percolation_WBP.jl")
