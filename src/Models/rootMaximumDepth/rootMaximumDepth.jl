export rootMaximumDepth

abstract type rootMaximumDepth <: LandEcosystem end

purpose(::Type{rootMaximumDepth}) = "Maximum rooting depth"

includeApproaches(rootMaximumDepth, @__DIR__)

@doc """ 
	$(getBaseDocString(rootMaximumDepth))
"""
rootMaximumDepth
