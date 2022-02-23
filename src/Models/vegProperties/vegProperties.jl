export vegProperties

abstract type vegProperties <: LandEcosystem end

include("vegProperties_PFT.jl")

@doc """
Vegetation/structural properties

# Approaches:
 - PFT: sets a uniform PFT class
"""
vegProperties