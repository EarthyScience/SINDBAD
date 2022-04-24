export wCycle

abstract type wCycle <: LandEcosystem end

include("wCycle_components.jl")
include("wCycle_combined.jl")

@doc """
Apply the delta storage changes to storage variables

# Approaches:
 - components: computes the algebraic sum of storage and delta storage using each component separately
 - combined: computes the algebraic sum of storage and delta storage of combined pool

"""
wCycle