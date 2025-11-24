export gppDemand

abstract type gppDemand <: LandEcosystem end

purpose(::Type{gppDemand}) = "Combined effect of environmental demand on GPP."

includeApproaches(gppDemand, @__DIR__)

@doc """ 
	$(getProcessDocstring(gppDemand))
"""
gppDemand
