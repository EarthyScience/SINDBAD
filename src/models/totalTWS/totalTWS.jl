export totalTWS

abstract type totalTWS <: LandEcosystem end

include("totalTWS_sumComponents.jl")
include("totalTWS_sumCombined.jl")

@doc """
Calculate the total water storage

# Approaches:
 - sumComponents: calculates total water storage as a sum of all potential components
 - sumCombined: calculates total water storage as a sum of combined water storage
"""
totalTWS