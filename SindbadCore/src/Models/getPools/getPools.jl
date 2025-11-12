export getPools

abstract type getPools <: LandEcosystem end

purpose(::Type{getPools}) = "Retrieves the amount of water at the beginning of the time step."

includeApproaches(getPools, @__DIR__)

@doc """ 
	$(getModelDocString(getPools))
"""
getPools
