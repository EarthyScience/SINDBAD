export rootMaximumDepth

abstract type rootMaximumDepth <: LandEcosystem end

include("rootMaximumDepth_fracSoilD.jl")

@doc """
Maximum rooting depth

# Approaches:
 - fracSoilD: sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD
"""
rootMaximumDepth