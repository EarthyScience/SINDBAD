export gppVPD

abstract type gppVPD <: LandEcosystem end

purpose(::Type{gppVPD}) = "Quantifies the effect of vapor pressure deficit (VPD) on GPP: 1 indicates no VPD stress, while 0 indicates complete stress."

includeApproaches(gppVPD, @__DIR__)

@doc """ 
	$(getModelDocString(gppVPD))
"""
gppVPD
