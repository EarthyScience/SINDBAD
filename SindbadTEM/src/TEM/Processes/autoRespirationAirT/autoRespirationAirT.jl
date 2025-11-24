export autoRespirationAirT

abstract type autoRespirationAirT <: LandEcosystem end

purpose(::Type{autoRespirationAirT}) = "Effect of air temperature on autotrophic respiration."

includeApproaches(autoRespirationAirT, @__DIR__)

@doc """ 
	$(getProcessDocstring(autoRespirationAirT))
"""
autoRespirationAirT
