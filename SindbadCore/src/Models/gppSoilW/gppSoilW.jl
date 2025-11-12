export gppSoilW

abstract type gppSoilW <: LandEcosystem end

purpose(::Type{gppSoilW}) = "Effect of soil moisture on GPP: 1 indicates no soil water stress, 0 indicates complete stress."

includeApproaches(gppSoilW, @__DIR__)

@doc """ 
	$(getModelDocString(gppSoilW))
"""
gppSoilW
