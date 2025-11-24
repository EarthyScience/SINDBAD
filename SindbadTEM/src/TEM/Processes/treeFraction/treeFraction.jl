export treeFraction

abstract type treeFraction <: LandEcosystem end

purpose(::Type{treeFraction}) = "Tree cover fraction."

includeApproaches(treeFraction, @__DIR__)

@doc """ 
	$(getProcessDocstring(treeFraction))
"""
treeFraction
