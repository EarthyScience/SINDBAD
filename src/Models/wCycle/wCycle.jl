export wCycle

abstract type wCycle <: LandEcosystem end

purpose(::Type{wCycle}) = "Apply the delta storage changes to storage variables"

includeApproaches(wCycle, @__DIR__)

@doc """ 
	$(getBaseDocString(wCycle))
"""
wCycle
