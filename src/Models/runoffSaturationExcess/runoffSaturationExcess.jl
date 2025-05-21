export runoffSaturationExcess

abstract type runoffSaturationExcess <: LandEcosystem end

purpose(::Type{runoffSaturationExcess}) = "Saturation runoff"

includeApproaches(runoffSaturationExcess, @__DIR__)

@doc """ 
	$(getModelDocString(runoffSaturationExcess))
"""
runoffSaturationExcess
