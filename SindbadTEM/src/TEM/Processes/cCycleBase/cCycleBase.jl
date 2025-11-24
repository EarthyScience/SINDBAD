export cCycleBase

abstract type cCycleBase <: LandEcosystem end

purpose(::Type{cCycleBase}) = "Defines the base properties of the carbon cycle components. For example, components of carbon pools, their turnover rates, and flow matrix."

includeApproaches(cCycleBase, @__DIR__)

@doc """ 
	$(getProcessDocstring(cCycleBase))
"""
cCycleBase
