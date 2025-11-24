export runoff

abstract type runoff <: LandEcosystem end

purpose(::Type{runoff}) = "Total runoff."

includeApproaches(runoff, @__DIR__)

@doc """ 
	$(getProcessDocstring(runoff))
"""
runoff
