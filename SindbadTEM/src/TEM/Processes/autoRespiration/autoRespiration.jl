export autoRespiration

abstract type autoRespiration <: LandEcosystem end

purpose(::Type{autoRespiration}) = "Autotrophic respiration for growth and maintenance."

includeApproaches(autoRespiration, @__DIR__)

@doc """ 
	$(getProcessDocstring(autoRespiration))
"""
autoRespiration
