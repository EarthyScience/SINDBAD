export getPools

abstract type getPools <: LandEcosystem end

purpose(::Type{getPools}) = "Get the amount of water at the beginning of timestep"

includeApproaches(getPools, @__DIR__)

@doc """ 
	$(getModelDocString(getPools))
"""
getPools
