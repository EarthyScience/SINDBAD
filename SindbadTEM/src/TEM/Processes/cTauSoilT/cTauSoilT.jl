export cTauSoilT

abstract type cTauSoilT <: LandEcosystem end

purpose(::Type{cTauSoilT}) = "Effect of soil temperature on decomposition rates."

includeApproaches(cTauSoilT, @__DIR__)

@doc """ 
	$(getProcessDocstring(cTauSoilT))
"""
cTauSoilT
