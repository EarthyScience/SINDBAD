export gpp

abstract type gpp <: LandEcosystem end

include("gpp_coupled.jl")
include("gpp_min.jl")
include("gpp_mult.jl")
include("gpp_none.jl")
include("gpp_transpirationWUE.jl")

@doc """
Combine effects as multiplicative or minimum; if coupled, uses transup

# Approaches:
 - coupled: calculate GPP based on transpiration supply & water use efficiency [coupled]
 - min: compute the actual GPP with potential scaled by minimum stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]
 - mult: compute the actual GPP with potential scaled by multiplicative stress scalar of demand & supply for uncoupled model structure [no coupling with transpiration]
 - none: sets the actual GPP to zero
 - transpirationWUE: calculate GPP based on transpiration & water use efficiency
"""
gpp
