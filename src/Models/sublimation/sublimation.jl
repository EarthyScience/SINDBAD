export sublimation

abstract type sublimation <: LandEcosystem end

purpose(::Type{sublimation}) = "Calculate sublimation and update snow water equivalent"

includeApproaches(sublimation, @__DIR__)

@doc """ 
	$(getBaseDocString(sublimation))
"""
sublimation
