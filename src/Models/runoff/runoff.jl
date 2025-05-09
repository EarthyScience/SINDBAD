export runoff

abstract type runoff <: LandEcosystem end

purpose(::Type{runoff}) = "Calculate the total runoff as a sum of components"

includeApproaches(runoff, @__DIR__)

@doc """ 
	$(getModelDocString(runoff))
"""
runoff
