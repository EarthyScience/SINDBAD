export drainage

abstract type drainage <: LandEcosystem end

purpose(::Type{drainage}) = "Recharge the soil"

includeApproaches(drainage, @__DIR__)

@doc """ 
	$(getBaseDocString(drainage))
"""
drainage
