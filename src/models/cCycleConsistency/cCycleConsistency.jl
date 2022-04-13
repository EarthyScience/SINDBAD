export cCycleConsistency
"""
Consistency checks on the c allocation and transfers between pools

# Approaches:
 - simple: check consistency in cCycle matrix: cAlloc; cFlow
"""
abstract type cCycleConsistency <: LandEcosystem end
include("cCycleConsistency_simple.jl")
