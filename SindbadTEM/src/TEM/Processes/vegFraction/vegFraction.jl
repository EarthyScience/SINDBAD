export vegFraction

abstract type vegFraction <: LandEcosystem end

purpose(::Type{vegFraction}) = "Vegetation cover fraction."

includeApproaches(vegFraction, @__DIR__)

@doc """ 
	$(getProcessDocstring(vegFraction))
"""
vegFraction
