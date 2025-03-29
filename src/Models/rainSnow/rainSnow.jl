export rainSnow

abstract type rainSnow <: LandEcosystem end

purpose(::Type{rainSnow}) = "Set rain and snow to fe.rainsnow."

includeApproaches(rainSnow, @__DIR__)

@doc """ 
	$(getBaseDocString(rainSnow))
"""
rainSnow
