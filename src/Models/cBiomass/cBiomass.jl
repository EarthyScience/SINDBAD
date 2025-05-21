export cBiomass

abstract type cBiomass <: LandEcosystem end

purpose(::Type{cBiomass}) = "Compute aboveground_biomass"

includeApproaches(cBiomass, @__DIR__)

@doc """ 
        $(getModelDocString(cBiomass))
"""
cBiomass