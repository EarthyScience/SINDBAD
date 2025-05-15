export cFlowVegProperties

abstract type cFlowVegProperties <: LandEcosystem end

purpose(::Type{cFlowVegProperties}) = "Effect of vegetation properties on the c transfers between pools"

includeApproaches(cFlowVegProperties, @__DIR__)

@doc """ 
	$(getModelDocString(cFlowVegProperties))
"""
cFlowVegProperties
