export cCycle

abstract type cCycle <: LandEcosystem end

purpose(::Type{cCycle}) = "Compute fluxes and changes (cycling) of carbon pools."

includeApproaches(cCycle, @__DIR__)

@doc """ 
	$(getProcessDocstring(cCycle))
"""
cCycle
