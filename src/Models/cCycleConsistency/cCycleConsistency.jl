export cCycleConsistency

abstract type cCycleConsistency <: LandEcosystem end

purpose(::Type{cCycleConsistency}) = "Consistency checks on the c allocation and transfers between pools"

includeApproaches(cCycleConsistency, @__DIR__)

@doc """ 
	$(getBaseDocString(cCycleConsistency))
"""
cCycleConsistency
