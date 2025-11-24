export cTau

abstract type cTau <: LandEcosystem end

purpose(::Type{cTau}) = "Actual decomposition/turnover rates of all carbon pools considering the effect of stressors."

includeApproaches(cTau, @__DIR__)

@doc """ 
	$(getModelDocString(cTau))
"""
cTau
