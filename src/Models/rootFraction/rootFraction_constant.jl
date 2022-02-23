export rootFraction_constant

@bounds @describe @units @with_kw struct rootFraction_constant{T1} <: rootFraction
	constantRootFrac::T1 = 0.5 | (0.05, 1.0) | "root fraction" | ""
end

function precompute(o::rootFraction_constant, forcing, land::NamedTuple, helpers::NamedTuple)
	@unpack_rootFraction_constant o
	## instantiate
	p_fracRoot2SoilD = ones(helpers.numbers.numType, length(land.pools.soilW))

	## pack land variables
	@pack_land p_fracRoot2SoilD => land.rootFraction

	return land
end

function compute(o::rootFraction_constant, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters
	@unpack_rootFraction_constant o

	## unpack land variables
	@unpack_land begin
        soilLayerThickness ∈ land.soilWBase
		p_fracRoot2SoilD ∈ land.rootFraction
		maxRootDepth ∈ land.states
		𝟘 ∈ helpers.numbers
	end

	## calculate variables
	cumulativeDepths = cumsum(soilLayerThickness)
	# maxRootDepth = min(maxRootDepth, sum(soilDepths)); # maximum rootingdepth
	for sl in 1:length(land.pools.soilW)
		soilcumuD = cumulativeDepths[sl]
		rootOver = maxRootDepth - soilcumuD
		rootFrac = rootOver > 𝟘 ? constantRootFrac : 𝟘
		p_fracRoot2SoilD[sl] = rootFrac
	end

	## pack land variables
	@pack_land p_fracRoot2SoilD => land.rootFraction
	return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as constant

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_constant

*Inputs*
 - land.states.maxRootD

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD

# precompute:
precompute/instantiate time-invariant variables for rootFraction_constant


---

# Extended help

*References*

*Versions*
 - 1.0 on 21.11.2019  

*Created by:*
 - skoirala
"""
rootFraction_constant