export runoffOverland

abstract type runoffOverland <: LandEcosystem end

purpose(::Type{runoffOverland}) = "Total overland runoff that passes to surface storage."

includeApproaches(runoffOverland, @__DIR__)

@doc """ 
	$(getProcessDocstring(runoffOverland))
"""
runoffOverland
