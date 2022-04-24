export gppDirRadiation

abstract type gppDirRadiation <: LandEcosystem end

include("gppDirRadiation_Maekelae2008.jl")
include("gppDirRadiation_none.jl")

@doc """
Effect of direct radiation

# Approaches:
 - Maekelae2008: light saturation scalar [light effect] on gppPot based on Maekelae2008
 - none: sets the light saturation scalar [light effect] on gppPot to one
"""
gppDirRadiation