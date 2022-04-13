export rootMaximumDepth
"""
Maximum rooting depth

# Approaches:
 - fracSoilD: sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD
"""
abstract type rootMaximumDepth <: LandEcosystem end
include("rootMaximumDepth_fracSoilD.jl")
