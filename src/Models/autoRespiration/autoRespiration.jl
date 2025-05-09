export autoRespiration

abstract type autoRespiration <: LandEcosystem end

purpose(::Type{autoRespiration}) = "Determine autotrophic respiration (RA) based on the growth and maintenance respiration components."

includeApproaches(autoRespiration, @__DIR__)

@doc """ 
	$(getModelDocString(autoRespiration))
"""
autoRespiration
