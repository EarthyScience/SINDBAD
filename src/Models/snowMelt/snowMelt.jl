export snowMelt

abstract type snowMelt <: LandEcosystem end

purpose(::Type{snowMelt}) = "Calculate snowmelt and update s.w.wsnow"

includeApproaches(snowMelt, @__DIR__)

@doc """ 
	$(getBaseDocString(snowMelt))
"""
snowMelt
