export cTau

abstract type cTau <: LandEcosystem end

purpose(::Type{cTau}) = "Combine effects of different factors on decomposition rates"

includeApproaches(cTau, @__DIR__)

@doc """ 
	$(getModelDocString(cTau))
"""
cTau
