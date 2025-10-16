export snowFraction

abstract type snowFraction <: LandEcosystem end

purpose(::Type{snowFraction}) = "Snow cover fraction."

includeApproaches(snowFraction, @__DIR__)

@doc """ 
	$(getModelDocString(snowFraction))
"""
snowFraction
