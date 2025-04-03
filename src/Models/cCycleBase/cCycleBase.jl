export cCycleBase

abstract type cCycleBase <: LandEcosystem end

purpose(::Type{cCycleBase}) = "Pool structure of the carbon cycle"

includeApproaches(cCycleBase, @__DIR__)

@doc """ 
	$(getBaseDocString(cCycleBase))
"""
cCycleBase
