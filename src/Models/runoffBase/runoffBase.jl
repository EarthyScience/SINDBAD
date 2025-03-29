export runoffBase

abstract type runoffBase <: LandEcosystem end

purpose(::Type{runoffBase}) = "Baseflow"

includeApproaches(runoffBase, @__DIR__)

@doc """ 
	$(getBaseDocString(runoffBase))
"""
runoffBase
