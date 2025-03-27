export runoff

abstract type runoff <: LandEcosystem end

include("runoff_sum.jl")

@doc """
Calculate the total runoff as a sum of components

# Approaches:
 - sum: calculates runoff as a sum of all potential components
"""
runoff
