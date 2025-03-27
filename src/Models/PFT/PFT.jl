export PFT

abstract type PFT <: LandEcosystem end

include("PFT_constant.jl")

@doc """
Vegetation PFT

# Approaches:
 - constant: sets a uniform PFT class
"""
PFT
