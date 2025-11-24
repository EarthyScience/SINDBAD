export gpp

abstract type gpp <: LandEcosystem end

purpose(::Type{gpp}) = "Gross Primary Productivity (GPP)."

includeApproaches(gpp, @__DIR__)

@doc """ 
	$(getProcessDocstring(gpp))
"""
gpp
