export plantForm

abstract type plantForm <: LandEcosystem end

purpose(::Type{plantForm}) = "define the plant form of the ecosystem"

includeApproaches(plantForm, @__DIR__)

@doc """ 
	$(getBaseDocString(plantForm))
"""
plantForm

