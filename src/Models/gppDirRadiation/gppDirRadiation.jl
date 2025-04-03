export gppDirRadiation

abstract type gppDirRadiation <: LandEcosystem end

purpose(::Type{gppDirRadiation}) = "Effect of direct radiation"

includeApproaches(gppDirRadiation, @__DIR__)

@doc """ 
	$(getBaseDocString(gppDirRadiation))
"""
gppDirRadiation
