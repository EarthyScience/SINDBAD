export WUE

abstract type WUE <: LandEcosystem end

purpose(::Type{WUE}) = "Water Use Efficiency (WUE)."

includeApproaches(WUE, @__DIR__)

@doc """ 
	$(getModelDocString(WUE))
"""
WUE
