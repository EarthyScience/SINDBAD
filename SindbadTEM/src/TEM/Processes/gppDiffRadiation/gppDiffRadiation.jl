export gppDiffRadiation

abstract type gppDiffRadiation <: LandEcosystem end

purpose(::Type{gppDiffRadiation}) = "Effect of diffuse radiation (Cloudiness scalar) on GPP: 1 indicates no diffuse radiation effect, 0 indicates complete effect."

includeApproaches(gppDiffRadiation, @__DIR__)

@doc """ 
	$(getProcessDocstring(gppDiffRadiation))
"""
gppDiffRadiation
