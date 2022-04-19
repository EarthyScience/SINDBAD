export TWS

abstract type TWS <: LandEcosystem end

include("TWS_sum.jl")

@doc """
Calculate the total water storage

# Approaches:
 - sum: calculates total water storage as a sum of all potential components
"""
TWS