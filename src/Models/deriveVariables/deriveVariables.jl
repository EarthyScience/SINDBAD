export deriveVariables

abstract type deriveVariables <: LandEcosystem end

purpose(::Type{deriveVariables}) = "Derive extra variables"

includeApproaches(deriveVariables, @__DIR__)

@doc """ 
	$(getBaseDocString(deriveVariables))
"""
deriveVariables
