export cAllocationTreeFraction
"""
Adjustment of carbon allocation according to tree cover

# Approaches:
 - Friedlingstein1999: adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning. adjust the allocation coefficients according to the fraction of trees to herbaceous & fine to coarse root partitioning
"""
abstract type cAllocationTreeFraction <: LandEcosystem end
include("cAllocationTreeFraction_Friedlingstein1999.jl")
