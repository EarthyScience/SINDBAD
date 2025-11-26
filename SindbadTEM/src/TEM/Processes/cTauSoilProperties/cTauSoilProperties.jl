export cTauSoilProperties

abstract type cTauSoilProperties <: LandEcosystem end

purpose(::Type{cTauSoilProperties}) = "Effect of soil texture on soil decomposition rates"

includeApproaches(cTauSoilProperties, @__DIR__)

@doc """ 
	$(getModelDocString(cTauSoilProperties))
"""
cTauSoilProperties
