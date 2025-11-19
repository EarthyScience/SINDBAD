export gppDirRadiation

abstract type gppDirRadiation <: LandEcosystem end

purpose(::Type{gppDirRadiation}) = "Effect of direct radiation (light effect) on GPP: 1 indicates no direct radiation effect, 0 indicates complete effect."

includeApproaches(gppDirRadiation, @__DIR__)

@doc """ 
	$(getModelDocString(gppDirRadiation))
"""
gppDirRadiation
