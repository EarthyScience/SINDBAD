export gppDiffRadiation

abstract type gppDiffRadiation <: LandEcosystem end

purpose(::Type{gppDiffRadiation}) = "Effect of diffuse radiation"

includeApproaches(gppDiffRadiation, @__DIR__)

@doc """ 
	$(getBaseDocString(gppDiffRadiation))
"""
gppDiffRadiation
