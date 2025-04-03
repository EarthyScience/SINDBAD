export saturatedFraction

abstract type saturatedFraction <: LandEcosystem end

purpose(::Type{saturatedFraction}) = "Saturated fraction of a grid cell"

includeApproaches(saturatedFraction, @__DIR__)

@doc """ 
	$(getBaseDocString(saturatedFraction))
"""
saturatedFraction
