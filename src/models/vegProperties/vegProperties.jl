export vegProperties
"""
Vegetation/structural properties

# Approaches:
 - PFT: sets a uniform PFT class. all calculations are done in prec
"""
abstract type vegProperties <: LandEcosystem end
include("vegProperties_PFT.jl")
