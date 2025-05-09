export runoffOverland

abstract type runoffOverland <: LandEcosystem end

purpose(::Type{runoffOverland}) = "calculates total overland runoff that passes to the surface storage"

includeApproaches(runoffOverland, @__DIR__)

@doc """ 
	$(getModelDocString(runoffOverland))
"""
runoffOverland
