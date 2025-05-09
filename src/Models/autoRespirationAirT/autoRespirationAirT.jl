export autoRespirationAirT

abstract type autoRespirationAirT <: LandEcosystem end

purpose(::Type{autoRespirationAirT}) = "Temperature effect on autotrophic maintenance respiration."

includeApproaches(autoRespirationAirT, @__DIR__)

@doc """ 
	$(getModelDocString(autoRespirationAirT))
"""
autoRespirationAirT
