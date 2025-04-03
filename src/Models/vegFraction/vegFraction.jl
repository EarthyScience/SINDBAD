export vegFraction

abstract type vegFraction <: LandEcosystem end

purpose(::Type{vegFraction}) = "Fractional coverage of vegetation"

includeApproaches(vegFraction, @__DIR__)

@doc """ 
	$(getBaseDocString(vegFraction))
"""
vegFraction
