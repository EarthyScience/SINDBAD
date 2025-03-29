export evapotranspiration

abstract type evapotranspiration <: LandEcosystem end

purpose(::Type{evapotranspiration}) = "Calculate the evapotranspiration as a sum of components"

includeApproaches(evapotranspiration, @__DIR__)

@doc """ 
	$(getBaseDocString(evapotranspiration))
"""
evapotranspiration
