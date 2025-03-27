export cCycleConsistency

abstract type cCycleConsistency <: LandEcosystem end

include("cCycleConsistency_simple.jl")

@doc """
Consistency checks on the c allocation and transfers between pools

# Approaches:
 - simple: check consistency in cCycle matrix: c_allocation; cFlow
"""
cCycleConsistency
