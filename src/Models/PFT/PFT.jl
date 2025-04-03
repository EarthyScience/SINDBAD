export PFT

abstract type PFT <: LandEcosystem end

purpose(::Type{PFT}) = "Vegetation PFT"

includeApproaches(PFT, @__DIR__)

@doc """ 
	$(getBaseDocString(PFT))
"""
PFT
