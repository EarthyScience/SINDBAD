export gppDemand

abstract type gppDemand <: LandEcosystem end

purpose(::Type{gppDemand}) = "Quantifies the combined effect of environmental demand on GPP."

includeApproaches(gppDemand, @__DIR__)

@doc """ 
	$(getModelDocString(gppDemand))
"""
gppDemand
