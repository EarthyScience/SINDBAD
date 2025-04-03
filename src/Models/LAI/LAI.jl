export LAI

abstract type LAI <: LandEcosystem end

purpose(::Type{LAI}) = "Leaf area index"

includeApproaches(LAI, @__DIR__)

@doc """ 
	$(getBaseDocString(LAI))
"""
LAI
