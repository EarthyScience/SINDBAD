export ambientCO2

abstract type ambientCO2 <: LandEcosystem end

purpose(::Type{ambientCO2}) = "set/get ambient CO2 concentration"

includeAllApproaches(ambientCO2, @__DIR__)

@doc """
$(getDocStringForModel(ambientCO2))
"""
ambientCO2
