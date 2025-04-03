export cCycleDisturbance

abstract type cCycleDisturbance <: LandEcosystem end

purpose(::Type{cCycleDisturbance}) = "Disturb the carbon cycle pools"

includeApproaches(cCycleDisturbance, @__DIR__)

@doc """ 
	$(getBaseDocString(cCycleDisturbance))
"""
cCycleDisturbance
