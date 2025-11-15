export PFT

abstract type PFT <: LandEcosystem end

purpose(::Type{PFT}) = "Plant Functional Type (PFT) classification."

includeApproaches(PFT, @__DIR__)

@doc """ 
	$(getModelDocString(PFT))
"""
PFT
