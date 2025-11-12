export ambientCO2

abstract type ambientCO2 <: LandEcosystem end

purpose(::Type{ambientCO2}) = "Ambient CO₂ concentration."

includeApproaches(ambientCO2, @__DIR__)

@doc """ 
    $(getModelDocString(ambientCO2))
"""
ambientCO2
