export autoRespiration

abstract type autoRespiration <: LandEcosystem end

purpose(::Type{autoRespiration}) = "Determine autotrophic respiration (RA) based on the growth and maintenance respiration components."

includeAllApproaches(autoRespiration, @__DIR__)

@doc """
$(getDocStringForModel(autoRespiration))
"""
autoRespiration
