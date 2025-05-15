export treeFraction

abstract type treeFraction <: LandEcosystem end

purpose(::Type{treeFraction}) = "Fractional coverage of trees"

includeApproaches(treeFraction, @__DIR__)

@doc """ 
	$(getModelDocString(treeFraction))
"""
treeFraction
