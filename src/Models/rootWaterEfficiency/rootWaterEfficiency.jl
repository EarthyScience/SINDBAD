export rootWaterEfficiency

abstract type rootWaterEfficiency <: LandEcosystem end

purpose(::Type{rootWaterEfficiency}) = "Distribution of water uptake fraction/efficiency by root per soil layer"

includeApproaches(rootWaterEfficiency, @__DIR__)

@doc """ 
	$(getBaseDocString(rootWaterEfficiency))
"""
rootWaterEfficiency
