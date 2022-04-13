export gppAirT
"""
Effect of temperature

# Approaches:
 - CASA: calculate the temperature stress for gppPot based on CASA & Potter
 - GSI: calculate the light stress on gpp based on GSI implementation of LPJ
 - Maekelae2008: calculate the temperature stress on gppPot based on Maekelae2008 [eqn 3 & 4]
 - MOD17: calculate the temperature stress on gppPot based on GPP - MOD17 model
 - none: set the temperature stress on gppPot to ones (no stress)
 - TEM: calculate the temperature stress for gppPot based on TEM
 - Wang2014: calculate the temperature stress on gppPot based on Wang2014
"""
abstract type gppAirT <: LandEcosystem end
include("gppAirT_CASA.jl")
include("gppAirT_GSI.jl")
include("gppAirT_Maekelae2008.jl")
include("gppAirT_MOD17.jl")
include("gppAirT_none.jl")
include("gppAirT_TEM.jl")
include("gppAirT_Wang2014.jl")
