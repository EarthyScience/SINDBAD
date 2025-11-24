export deriveVariables

abstract type deriveVariables <: LandEcosystem end

purpose(::Type{deriveVariables}) = "Derives additional variables based on other SINDBAD models and saves them into land.deriveVariables."

includeApproaches(deriveVariables, @__DIR__)

@doc """ 
	$(getProcessDocstring(deriveVariables))
"""
deriveVariables
