export waterBalance

abstract type waterBalance <: LandEcosystem end

purpose(::Type{waterBalance}) = "Water balance"

includeApproaches(waterBalance, @__DIR__)

@doc """ 
	$(getProcessDocstring(waterBalance))
"""
waterBalance
