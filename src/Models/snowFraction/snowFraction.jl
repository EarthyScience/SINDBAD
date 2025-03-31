export snowFraction

abstract type snowFraction <: LandEcosystem end

purpose(::Type{snowFraction}) = "Calculate snow cover fraction"

includeApproaches(snowFraction, @__DIR__)

@doc """ 
	$(getBaseDocString(snowFraction))
"""
snowFraction
