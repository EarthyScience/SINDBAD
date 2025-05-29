export gppSoilW

abstract type gppSoilW <: LandEcosystem end

purpose(::Type{gppSoilW}) = "Quantifies the effect of soil water on GPP: 1 indicates no soil water stress, while 0 indicates complete stress."

includeApproaches(gppSoilW, @__DIR__)

@doc """ 
	$(getModelDocString(gppSoilW))
"""
gppSoilW
