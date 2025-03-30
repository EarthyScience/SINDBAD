export gppAirT

abstract type gppAirT <: LandEcosystem end

purpose(::Type{gppAirT}) = "Effect of temperature"

includeApproaches(gppAirT, @__DIR__)

@doc """ 
	$(getBaseDocString(gppAirT))
"""
gppAirT
