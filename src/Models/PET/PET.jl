export PET

abstract type PET <: LandEcosystem end

purpose(::Type{PET}) = "Set potential evapotranspiration"

includeApproaches(PET, @__DIR__)
@doc """ 
	$(getBaseDocString(PET))
"""
PET
