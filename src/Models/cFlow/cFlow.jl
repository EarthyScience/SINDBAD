export cFlow

abstract type cFlow <: LandEcosystem end

purpose(::Type{cFlow}) = "Actual transfers of c between pools (of diagonal components)"

includeApproaches(cFlow, @__DIR__)

@doc """ 
	$(getModelDocString(cFlow))
"""
cFlow
