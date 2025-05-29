export gppDirRadiation

abstract type gppDirRadiation <: LandEcosystem end

purpose(::Type{gppDirRadiation}) = "Quantifies the effect of direct radiation on GPP: 1 indicates no direct radiation effect, while 0 indicates complete effect."

includeApproaches(gppDirRadiation, @__DIR__)

@doc """ 
	$(getModelDocString(gppDirRadiation))
"""
gppDirRadiation
