export interception

abstract type interception <: LandEcosystem end

purpose(::Type{interception}) = "Interception loss."

includeApproaches(interception, @__DIR__)

@doc """ 
	$(getProcessDocstring(interception))
"""
interception
