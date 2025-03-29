export rootWaterUptake

abstract type rootWaterUptake <: LandEcosystem end

purpose(::Type{rootWaterUptake}) = "Root water uptake (extract water from soil)"

includeApproaches(rootWaterUptake, @__DIR__)

@doc """ 
	$(getBaseDocString(rootWaterUptake))
"""
rootWaterUptake
