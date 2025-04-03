export rainIntensity

abstract type rainIntensity <: LandEcosystem end

purpose(::Type{rainIntensity}) = "Set rainfall intensity"

includeApproaches(rainIntensity, @__DIR__)

@doc """ 
	$(getBaseDocString(rainIntensity))
"""
rainIntensity
