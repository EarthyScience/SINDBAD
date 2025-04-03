export cAllocationTreeFraction

abstract type cAllocationTreeFraction <: LandEcosystem end

purpose(::Type{cAllocationTreeFraction}) = "Adjustment of carbon allocation according to tree cover"

includeApproaches(cAllocationTreeFraction, @__DIR__)

@doc """ 
	$(getBaseDocString(cAllocationTreeFraction))
"""
cAllocationTreeFraction
