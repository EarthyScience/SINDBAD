export gppDiffRadiation

abstract type gppDiffRadiation <: LandEcosystem end

include("gppDiffRadiation_GSI.jl")
include("gppDiffRadiation_none.jl")
include("gppDiffRadiation_Turner2006.jl")
include("gppDiffRadiation_Wang2015.jl")

@doc """
Effect of diffuse radiation

# Approaches:
 - GSI: cloudiness scalar [radiation diffusion] on gpp_potential based on GSI implementation of LPJ
 - none: sets the cloudiness scalar [radiation diffusion] for gpp_potential to one
 - Turner2006: cloudiness scalar [radiation diffusion] on gpp_potential based on Turner2006
 - Wang2015: cloudiness scalar [radiation diffusion] on gpp_potential based on Wang2015
"""
gppDiffRadiation
