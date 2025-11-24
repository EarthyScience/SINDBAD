export PET

abstract type PET <: LandEcosystem end

purpose(::Type{PET}) = "Potential evapotranspiration."

includeApproaches(PET, @__DIR__)
@doc """ 
	$(getProcessDocstring(PET))
"""
PET
