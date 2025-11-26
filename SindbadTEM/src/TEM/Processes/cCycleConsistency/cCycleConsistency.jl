export cCycleConsistency

abstract type cCycleConsistency <: LandEcosystem end

purpose(::Type{cCycleConsistency}) = "Consistency and sanity checks in carbon allocation and transfers."

includeApproaches(cCycleConsistency, @__DIR__)

@doc """ 
	$(getModelDocString(cCycleConsistency))
"""
cCycleConsistency
