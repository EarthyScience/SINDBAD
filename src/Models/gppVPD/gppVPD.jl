export gppVPD

abstract type gppVPD <: LandEcosystem end

purpose(::Type{gppVPD}) = "Vpd effect"

includeApproaches(gppVPD, @__DIR__)

@doc """ 
	$(getBaseDocString(gppVPD))
"""
gppVPD
