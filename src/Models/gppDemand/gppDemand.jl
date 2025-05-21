export gppDemand

abstract type gppDemand <: LandEcosystem end

purpose(::Type{gppDemand}) = "Combine effects as multiplicative or minimum"

includeApproaches(gppDemand, @__DIR__)

@doc """ 
	$(getModelDocString(gppDemand))
"""
gppDemand
