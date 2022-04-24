export rootFraction_expCvegRoot

@bounds @describe @units @with_kw struct rootFraction_expCvegRoot{T1, T2, T3} <: rootFraction
	k_cVegRoot::T1 = 0.02 | (0.001, 0.3) | "rate constant of exponential relationship" | "m2/kgC (inverse of carbon storage)"
	fracRoot2SoilD_max::T2 = 0.95 | (0.7, 0.98) | "maximum root water uptake capacity" | ""
	fracRoot2SoilD_min::T3 = 0.1 | (0.05, 0.3) | "minimum root water uptake threshold" | ""
end

function precompute(o::rootFraction_expCvegRoot, forcing, land, helpers)
	@unpack_rootFraction_expCvegRoot o

	## instantiate variables
	p_fracRoot2SoilD = ones(helpers.numbers.numType, length(land.pools.soilW))
	rootStop = ones(helpers.numbers.numType, length(land.pools.soilW))

	## pack land variables
	@pack_land (p_fracRoot2SoilD, rootStop) => land.rootFraction
	return land
end

function compute(o::rootFraction_expCvegRoot, forcing, land, helpers)
	## unpack parameters
	@unpack_rootFraction_expCvegRoot o

	## unpack land variables
	@unpack_land (p_fracRoot2SoilD, rootStop) ∈ land.rootFraction

	## unpack land variables
	@unpack_land begin
		maxRootD ∈ land.states
		cEco ∈ land.pools
	end
	##p_fracRoot2SoilD = ones(helpers.numbers.numType, length(land.pools.soilW))
	soilDepths = helpers.pools.water.layerThickness.soilW
	totalSoilDepth = sum(soilDepths)
	maxRootDepth = min(maxRootD, totalSoilDepth); # maximum rootingdepth
	# create the arrays to fill in the soil properties
	for sl in 1:length(land.pools.soilW)
		soilD = sum(soilDepths[1:sl-1])
		rootOver = maxRootDepth - soilD
		rootOverID = (rootOver <= 0.0)
		rootStop[rootOverID, sl] = 0.0
	end
	cVegRootZix = helpers.pools.carbon.zix.cVegRoot
	cVegRoot = sum(cEco[cVegRootZix])
	p_fracRoot2SoilD = (fracRoot2SoilD_max - (fracRoot2SoilD_max - fracRoot2SoilD_min) * (exp(-k_cVegRoot * cVegRoot))) * rootStop

	## pack land variables
	@pack_land p_fracRoot2SoilD => land.rootFraction
	return land
end

@doc """
Precomputation for maximum root water fraction that plants can uptake from soil layers according to total carbon in root [cVegRoot]. sets the maximum fraction of water that root can uptake from soil layers according to total carbon in root [cVegRoot]

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_expCvegRoot

*Inputs*
 - helpers.pools.water.layerThickness.soilW
 - land.pools.cEco
 - land.states.maxRootD [from rootFraction_expCvegRoot]
 - maxRootDepth [from rootFraction_expCvegRoot]

*Outputs*
 - initiates land.rootFraction.p_fracRoot2SoilD as ones
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW
 - land.rootFraction.p_fracRoot2SoilD

# precompute:
precompute/instantiate time-invariant variables for rootFraction_expCvegRoot


---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 28.04.2020  

*Created by:*
 - skoirala
"""
rootFraction_expCvegRoot