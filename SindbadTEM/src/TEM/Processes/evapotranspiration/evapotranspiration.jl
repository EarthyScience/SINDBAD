export evapotranspiration

abstract type evapotranspiration <: LandEcosystem end

purpose(::Type{evapotranspiration}) = "Evapotranspiration."

includeApproaches(evapotranspiration, @__DIR__)

@doc """ 
	$(getProcessDocstring(evapotranspiration))
"""
evapotranspiration
