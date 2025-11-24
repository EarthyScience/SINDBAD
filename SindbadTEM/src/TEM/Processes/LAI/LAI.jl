export LAI

abstract type LAI <: LandEcosystem end

purpose(::Type{LAI}) = "Leaf Area Index"

includeApproaches(LAI, @__DIR__)

@doc """ 
	$(getProcessDocstring(LAI))
"""
LAI
