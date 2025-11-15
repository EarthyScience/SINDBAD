export constants

abstract type constants <: LandEcosystem end

purpose(::Type{constants}) = "Defines constants and variables that are independent of model structure."

includeApproaches(constants, @__DIR__)

@doc """ 
	$(getModelDocString(constants))
"""
constants

