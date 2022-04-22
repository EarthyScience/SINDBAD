export wCycle

abstract type wCycle <: LandEcosystem end

include("wCycle_simple.jl")

@doc """
Apply the delta storage changes to storage variables

# Approaches:
 - simple: an algebraic sum of storage and delta storage
"""
wCycle