export fAPAR

abstract type fAPAR <: LandEcosystem end

purpose(::Type{fAPAR}) = "Fraction of absorbed photosynthetically active radiation."

includeApproaches(fAPAR, @__DIR__)

@doc """ 
	$(getModelDocString(fAPAR))
"""
fAPAR
