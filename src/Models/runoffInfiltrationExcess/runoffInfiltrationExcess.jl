export runoffInfiltrationExcess

abstract type runoffInfiltrationExcess <: LandEcosystem end

purpose(::Type{runoffInfiltrationExcess}) = "Infiltration excess runoff"

includeApproaches(runoffInfiltrationExcess, @__DIR__)

@doc """ 
	$(getModelDocString(runoffInfiltrationExcess))
"""
runoffInfiltrationExcess
