export rootWaterEfficiency

abstract type rootWaterEfficiency <: LandEcosystem end

purpose(::Type{rootWaterEfficiency}) = "Water uptake efficiency by roots for each soil layer."

includeApproaches(rootWaterEfficiency, @__DIR__)

@doc """ 
	$(getProcessDocstring(rootWaterEfficiency))
"""
rootWaterEfficiency
