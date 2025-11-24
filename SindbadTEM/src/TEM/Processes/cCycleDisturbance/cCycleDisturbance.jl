export cCycleDisturbance

abstract type cCycleDisturbance <: LandEcosystem end

purpose(::Type{cCycleDisturbance}) = "Disturbance of the carbon cycle pools."

includeApproaches(cCycleDisturbance, @__DIR__)

@doc """ 
	$(getProcessDocstring(cCycleDisturbance))
"""
cCycleDisturbance
