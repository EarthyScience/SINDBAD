export transpirationDemand

abstract type transpirationDemand <: LandEcosystem end

purpose(::Type{transpirationDemand}) = "Demand-limited transpiration."

includeApproaches(transpirationDemand, @__DIR__)

@doc """ 
	$(getProcessDocstring(transpirationDemand))
"""
transpirationDemand
