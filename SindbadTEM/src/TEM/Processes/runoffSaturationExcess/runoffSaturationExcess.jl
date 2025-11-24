export runoffSaturationExcess

abstract type runoffSaturationExcess <: LandEcosystem end

purpose(::Type{runoffSaturationExcess}) = "Saturation excess runoff."

includeApproaches(runoffSaturationExcess, @__DIR__)

@doc """ 
	$(getProcessDocstring(runoffSaturationExcess))
"""
runoffSaturationExcess
