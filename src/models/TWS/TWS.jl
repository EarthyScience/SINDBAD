export TWS
"""
Calculate the total water storage as a sum of components

# Approaches:
 - sum: calculates total water storage as a sum of all potential components
"""
abstract type TWS <: LandEcosystem end
include("TWS_sum.jl")
