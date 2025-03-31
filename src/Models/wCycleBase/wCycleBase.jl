export wCycleBase

abstract type wCycleBase <: LandEcosystem end

purpose(::Type{wCycleBase}) = "set the basics of the water cycle pools"

includeApproaches(wCycleBase, @__DIR__)

@doc """ 
	$(getBaseDocString(wCycleBase))
"""
wCycleBase
