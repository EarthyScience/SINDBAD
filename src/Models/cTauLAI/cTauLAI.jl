export cTauLAI

abstract type cTauLAI <: LandEcosystem end

purpose(::Type{cTauLAI}) = "Calculate litterfall scalars (that affect the changes in the vegetation k)"

includeApproaches(cTauLAI, @__DIR__)

@doc """ 
	$(getModelDocString(cTauLAI))
"""
cTauLAI
