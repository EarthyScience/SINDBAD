export gppPotential

abstract type gppPotential <: LandEcosystem end

purpose(::Type{gppPotential}) = "Potential GPP based on maximum instantaneous radiation use efficiency."

includeApproaches(gppPotential, @__DIR__)

@doc """ 
	$(getModelDocString(gppPotential))
"""
gppPotential
