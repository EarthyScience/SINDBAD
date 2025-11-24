export cAllocationTreeFraction

abstract type cAllocationTreeFraction <: LandEcosystem end

purpose(::Type{cAllocationTreeFraction}) = "Adjusts carbon allocation according to tree cover."

includeApproaches(cAllocationTreeFraction, @__DIR__)

@doc """ 
	$(getProcessDocstring(cAllocationTreeFraction))
"""
cAllocationTreeFraction
