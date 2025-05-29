export gppDiffRadiation

abstract type gppDiffRadiation <: LandEcosystem end

purpose(::Type{gppDiffRadiation}) = "Quantifies the effect of diffuse radiation on GPP: 1 indicates no diffuse radiation effect, while 0 indicates complete effect."

includeApproaches(gppDiffRadiation, @__DIR__)

@doc """ 
	$(getModelDocString(gppDiffRadiation))
"""
gppDiffRadiation
