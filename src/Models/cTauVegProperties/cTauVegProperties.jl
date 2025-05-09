export cTauVegProperties

abstract type cTauVegProperties <: LandEcosystem end

purpose(::Type{cTauVegProperties}) = "Effect of vegetation properties on soil decomposition rates"

includeApproaches(cTauVegProperties, @__DIR__)

@doc """ 
	$(getModelDocString(cTauVegProperties))
"""
cTauVegProperties
