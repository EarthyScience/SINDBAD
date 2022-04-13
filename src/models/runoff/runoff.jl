export runoff
"""
Calculate the total runoff as a sum of components

# Approaches:
 - sum: calculates runoff as a sum of all potential components
"""
abstract type runoff <: LandEcosystem end
include("runoff_sum.jl")
