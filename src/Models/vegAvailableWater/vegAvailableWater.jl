export vegAvailableWater

abstract type vegAvailableWater <: LandEcosystem end

purpose(::Type{vegAvailableWater}) = "Plant available water"

includeApproaches(vegAvailableWater, @__DIR__)

@doc """ 
	$(getBaseDocString(vegAvailableWater))
"""
vegAvailableWater
