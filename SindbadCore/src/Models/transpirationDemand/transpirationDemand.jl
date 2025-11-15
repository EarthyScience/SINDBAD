export transpirationDemand

abstract type transpirationDemand <: LandEcosystem end

purpose(::Type{transpirationDemand}) = "Demand-limited transpiration."

includeApproaches(transpirationDemand, @__DIR__)

@doc """ 
	$(getModelDocString(transpirationDemand))
"""
transpirationDemand
