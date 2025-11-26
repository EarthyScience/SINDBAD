export vegAvailableWater

abstract type vegAvailableWater <: LandEcosystem end

purpose(::Type{vegAvailableWater}) = "Plant available water (PAW), i.e., the amount of water available for transpiration."

includeApproaches(vegAvailableWater, @__DIR__)

@doc """ 
	$(getModelDocString(vegAvailableWater))
"""
vegAvailableWater
