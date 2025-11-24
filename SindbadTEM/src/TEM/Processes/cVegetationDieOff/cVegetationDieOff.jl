export cVegetationDieOff

abstract type cVegetationDieOff <: LandEcosystem end

purpose(::Type{cVegetationDieOff}) = "Fraction of vegetation pools that die off."

includeApproaches(cVegetationDieOff, @__DIR__)

@doc """ 
	$(getProcessDocstring(cVegetationDieOff))
"""
cVegetationDieOff
