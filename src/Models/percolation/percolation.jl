export percolation

abstract type percolation <: LandEcosystem end

purpose(::Type{percolation}) = "Calculate the soil percolation = wbp at this point"

includeApproaches(percolation, @__DIR__)

@doc """ 
	$(getBaseDocString(percolation))
"""
percolation
