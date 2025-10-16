export rainIntensity

abstract type rainIntensity <: LandEcosystem end

purpose(::Type{rainIntensity}) = "Rainfall intensity."

includeApproaches(rainIntensity, @__DIR__)

@doc """ 
	$(getModelDocString(rainIntensity))
"""
rainIntensity
