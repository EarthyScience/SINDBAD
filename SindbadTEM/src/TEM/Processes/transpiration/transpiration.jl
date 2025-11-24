export transpiration

abstract type transpiration <: LandEcosystem end

purpose(::Type{transpiration}) = "Transpiration."

includeApproaches(transpiration, @__DIR__)

@doc """ 
	$(getProcessDocstring(transpiration))
"""
transpiration
