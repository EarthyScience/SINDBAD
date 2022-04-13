export gppDiffRadiation
"""
Effect of diffuse radiation

# Approaches:
 - GSI: calculate the light stress on gpp based on GSI implementation of LPJ
 - none: set the cloudiness scalar [radiation diffusion] for gppPot to ones
 - Turner2006: calculate the cloudiness scalar [radiation diffusion] on gppPot
 - Wang2015: calculate the cloudiness scalar [radiation diffusion] on gppPot
"""
abstract type gppDiffRadiation <: LandEcosystem end
include("gppDiffRadiation_GSI.jl")
include("gppDiffRadiation_none.jl")
include("gppDiffRadiation_Turner2006.jl")
include("gppDiffRadiation_Wang2015.jl")
