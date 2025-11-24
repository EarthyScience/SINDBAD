export cBiomass

abstract type cBiomass <: LandEcosystem end

purpose(::Type{cBiomass}) = "Computes aboveground biomass (AGB)."

includeApproaches(cBiomass, @__DIR__)

@doc """ 
        $(getProcessDocstring(cBiomass))
"""
cBiomass