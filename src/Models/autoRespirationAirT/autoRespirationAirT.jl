export autoRespirationAirT

abstract type autoRespirationAirT <: LandEcosystem end

purpose(::Type{autoRespirationAirT}) = "temperature effect on autotrophic respiration"

includeApproaches(autoRespirationAirT, @__DIR__)

@doc """ 
	$(getModelDocString(autoRespirationAirT))
"""
autoRespirationAirT
