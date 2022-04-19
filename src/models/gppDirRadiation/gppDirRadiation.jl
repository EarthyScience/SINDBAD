export gppDirRadiation

abstract type gppDirRadiation <: LandEcosystem end

include("gppDirRadiation_Maekelae2008.jl")
include("gppDirRadiation_none.jl")

@doc """
Effect of direct radiation

# Approaches:
 - Maekelae2008: calculate the light saturation scalar [light effect] on gppPot
 - none: set the light saturation scalar [light effect] on gppPot to ones
"""
gppDirRadiation