export cCycle

abstract type cCycle <: LandEcosystem end

purpose(::Type{cCycle}) = "Allocate carbon to vegetation components"

includeApproaches(cCycle, @__DIR__)

@doc """ 
	$(getBaseDocString(cCycle))
"""
cCycle
