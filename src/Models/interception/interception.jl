export interception

abstract type interception <: LandEcosystem end

purpose(::Type{interception}) = "Interception evaporation"

includeApproaches(interception, @__DIR__)

@doc """ 
	$(getBaseDocString(interception))
"""
interception
