export gppSoilW

abstract type gppSoilW <: LandEcosystem end

purpose(::Type{gppSoilW}) = "soil moisture stress on GPP"

includeApproaches(gppSoilW, @__DIR__)

@doc """ 
	$(getModelDocString(gppSoilW))
"""
gppSoilW
