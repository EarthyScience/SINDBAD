export gppAirT

abstract type gppAirT <: LandEcosystem end

include("gppAirT_CASA.jl")
include("gppAirT_GSI.jl")
include("gppAirT_Maekelae2008.jl")
include("gppAirT_MOD17.jl")
include("gppAirT_none.jl")
include("gppAirT_TEM.jl")
include("gppAirT_Wang2014.jl")

@doc """
Effect of temperature

# Approaches:
 - CASA: temperature stress for gpp_potential based on CASA & Potter
 - GSI: temperature stress on gpp_potential based on GSI implementation of LPJ
 - Maekelae2008: temperature stress on gpp_potential based on Maekelae2008 [eqn 3 & 4]
 - MOD17: temperature stress on gpp_potential based on GPP - MOD17 model
 - none: sets the temperature stress on gpp_potential to one (no stress)
 - TEM: temperature stress for gpp_potential based on TEM
 - Wang2014: temperature stress on gpp_potential based on Wang2014
"""
gppAirT
