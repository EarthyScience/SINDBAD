export cVegetationDieOff

abstract type cVegetationDieOff <: LandEcosystem end

purpose(::Type{cVegetationDieOff}) = "Disturb the carbon cycle pools"

includeApproaches(cVegetationDieOff, @__DIR__)

@doc """ 
	$(getModelDocString(cVegetationDieOff))
"""
cVegetationDieOff
