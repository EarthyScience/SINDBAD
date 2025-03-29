export capillaryFlow

abstract type capillaryFlow <: LandEcosystem end

purpose(::Type{capillaryFlow}) = "Flux of water from lower to upper soil layers (upward soil moisture movement)"

includeApproaches(capillaryFlow, @__DIR__)

@doc """ 
	$(getBaseDocString(capillaryFlow))
"""
capillaryFlow
