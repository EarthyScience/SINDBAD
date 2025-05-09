export waterBalance

abstract type waterBalance <: LandEcosystem end

purpose(::Type{waterBalance}) = "Calculate the water balance"

includeApproaches(waterBalance, @__DIR__)

@doc """ 
	$(getModelDocString(waterBalance))
"""
waterBalance
