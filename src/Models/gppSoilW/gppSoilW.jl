export gppSoilW

abstract type gppSoilW <: LandEcosystem end

purpose(::Type{gppSoilW}) = "Gpp as a function of soilW; should be set to none if coupled with transpiration"

includeApproaches(gppSoilW, @__DIR__)

@doc """ 
	$(getModelDocString(gppSoilW))
"""
gppSoilW
