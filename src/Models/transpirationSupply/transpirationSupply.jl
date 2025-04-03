export transpirationSupply

abstract type transpirationSupply <: LandEcosystem end

purpose(::Type{transpirationSupply}) = "Supply-limited transpiration"

includeApproaches(transpirationSupply, @__DIR__)

@doc """ 
	$(getBaseDocString(transpirationSupply))
"""
transpirationSupply
