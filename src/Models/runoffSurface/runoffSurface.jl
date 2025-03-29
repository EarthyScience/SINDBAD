export runoffSurface

abstract type runoffSurface <: LandEcosystem end

purpose(::Type{runoffSurface}) = "Surface runoff generation process"

includeApproaches(runoffSurface, @__DIR__)

@doc """ 
	$(getBaseDocString(runoffSurface))
"""
runoffSurface
