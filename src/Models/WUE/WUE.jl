export WUE

abstract type WUE <: LandEcosystem end

purpose(::Type{WUE}) = "Estimate wue"

includeApproaches(WUE, @__DIR__)

@doc """ 
	$(getModelDocString(WUE))
"""
WUE
