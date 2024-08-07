export wCycleBase

abstract type wCycleBase <: LandEcosystem end

include("wCycleBase_simple.jl")

@doc """
set the basics of the water cycle pools

# Approaches:
 - simple: a simple method that just counts the number of layers in each pool

"""
wCycleBase