export treeFraction

abstract type treeFraction <: LandEcosystem end

purpose(::Type{treeFraction}) = "Fractional coverage of trees"

includeApproaches(treeFraction, @__DIR__)

@doc """ 
	$(getBaseDocString(treeFraction))
"""
treeFraction
