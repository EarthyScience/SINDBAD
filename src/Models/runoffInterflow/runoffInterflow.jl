export runoffInterflow

abstract type runoffInterflow <: LandEcosystem end

purpose(::Type{runoffInterflow}) = "Interflow"

includeApproaches(runoffInterflow, @__DIR__)

@doc """ 
	$(getBaseDocString(runoffInterflow))
"""
runoffInterflow
