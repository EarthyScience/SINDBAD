export wCycleBase

abstract type wCycleBase <: LandEcosystem end

purpose(::Type{wCycleBase}) = "Sets the basic structure of the water cycle storages."

includeApproaches(wCycleBase, @__DIR__)

@doc """ 
	$(getModelDocString(wCycleBase))
"""
wCycleBase
