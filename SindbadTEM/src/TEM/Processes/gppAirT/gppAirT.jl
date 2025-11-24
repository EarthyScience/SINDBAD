export gppAirT

abstract type gppAirT <: LandEcosystem end

purpose(::Type{gppAirT}) = "Effect of temperature on GPP: 1 indicates no temperature stress, 0 indicates complete stress."

includeApproaches(gppAirT, @__DIR__)

@doc """ 
	$(getProcessDocstring(gppAirT))
"""
gppAirT
