export groundWRecharge

abstract type groundWRecharge <: LandEcosystem end

purpose(::Type{groundWRecharge}) = "Recharge to the groundwater storage"

includeApproaches(groundWRecharge, @__DIR__)

@doc """ 
	$(getBaseDocString(groundWRecharge))
"""
groundWRecharge
