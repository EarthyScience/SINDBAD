export transpiration

abstract type transpiration <: LandEcosystem end

purpose(::Type{transpiration}) = "calclulate the actual transpiration"

includeApproaches(transpiration, @__DIR__)

@doc """ 
	$(getBaseDocString(transpiration))
"""
transpiration
