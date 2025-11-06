export runoffInterflow

abstract type runoffInterflow <: LandEcosystem end

purpose(::Type{runoffInterflow}) = "Interflow runoff."

includeApproaches(runoffInterflow, @__DIR__)

@doc """ 
	$(getModelDocString(runoffInterflow))
"""
runoffInterflow
