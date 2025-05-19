export PET

abstract type PET <: LandEcosystem end

purpose(::Type{PET}) = "Set/get potential evapotranspiration"

includeApproaches(PET, @__DIR__)
@doc """ 
	$(getModelDocString(PET))
"""
PET
