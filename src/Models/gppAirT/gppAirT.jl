export gppAirT

abstract type gppAirT <: LandEcosystem end

purpose(::Type{gppAirT}) = "Quantifies the effect of temperature on GPP: 1 indicates no temperature stress, while 0 indicates complete stress."

includeApproaches(gppAirT, @__DIR__)

@doc """ 
	$(getModelDocString(gppAirT))
"""
gppAirT
