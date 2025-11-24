export cTauSoilW

abstract type cTauSoilW <: LandEcosystem end

purpose(::Type{cTauSoilW}) = "Effect of soil moisture on decomposition rates."

includeApproaches(cTauSoilW, @__DIR__)

@doc """ 
	$(getProcessDocstring(cTauSoilW))
"""
cTauSoilW
