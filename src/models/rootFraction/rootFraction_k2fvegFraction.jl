export rootFraction_k2fvegFraction

@bounds @describe @units @with_kw struct rootFraction_k2fvegFraction{T1, T2} <: rootFraction
	k2_scale::T1 = 0.02 | (0.001, 10.0) | "scales vegFrac to define fraction of 2nd soil layer available for transpiration" | ""
	k1_scale::T2 = 0.5 | (0.001, 10.0) | "scales vegFrac to fraction of 1st soil layer available for transpiration" | ""
end

function precompute(o::rootFraction_k2fvegFraction, forcing, land, helpers)
	@unpack_rootFraction_k2fvegFraction o

	## precomputations/check

	# check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
	if length(land.pools.soilW) != 2 
		error("rootFraction_k2fvegFraction approach works for 2 soil layers only.")
	end
	# create the arrays to fill in the soil properties 
	p_fracRoot2SoilD = ones(helpers.numbers.numType, length(land.pools.soilW));

	## pack land variables
	@pack_land (p_fracRoot2SoilD) => land.rootFraction
	return land
end

function compute(o::rootFraction_k2fvegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_rootFraction_k2fvegFraction o

	## unpack land variables
	@unpack_land (p_fracRoot2SoilD) ∈ land.rootFraction

	## unpack land variables
	@unpack_land vegFraction ∈ land.states


	## calculate variables
	# check if the number of soil layers & number of elements in soil
	# the scaling parameters can be > 1 but k1RootFrac needs to be <= 1
	k1RootFrac = min(helpers.numbers.𝟙, vegFraction * k1_scale); # the fraction of water that a root can uptake from the 1st soil layer
	k2RootFrac = min(helpers.numbers.𝟙, vegFraction * k2_scale); # the fraction of water that a root can uptake from the 1st soil layer
	# set the properties
	# 1st Layer
	p_fracRoot2SoilD[1] = p_fracRoot2SoilD[1] * k1RootFrac
	# 2nd Layer
	p_fracRoot2SoilD[2] = p_fracRoot2SoilD[2] * k2RootFrac

	## pack land variables
	@pack_land p_fracRoot2SoilD => land.rootFraction
	return land
end

@doc """
sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_k2fvegFraction

*Inputs*
 - helpers.pools.water.: soil layers & depths
 - land.states.vegFraction : vegetation fraction

*Outputs*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

# precompute:
precompute/instantiate time-invariant variables for rootFraction_k2fvegFraction


---

# Extended help

*References*

*Versions*
 - 1.0 on 10.02.2020  

*Created by:*
 - ttraut
"""
rootFraction_k2fvegFraction