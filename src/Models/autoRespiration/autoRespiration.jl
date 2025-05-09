export autoRespiration

abstract type autoRespiration <: LandEcosystem end

purpose(::Type{autoRespiration}) = "estimates autotrophic respiration for growth and maintenance"

includeApproaches(autoRespiration, @__DIR__)

@doc """ 
	$(getModelDocString(autoRespiration))
"""
autoRespiration
