export gpp

abstract type gpp <: LandEcosystem end

purpose(::Type{gpp}) = "Combine effects as multiplicative or minimum; if coupled, uses transup"

includeApproaches(gpp, @__DIR__)

@doc """ 
	$(getModelDocString(gpp))
"""
gpp
