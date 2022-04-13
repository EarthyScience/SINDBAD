export rootFraction_k2fvegFraction, rootFraction_k2fvegFraction_h
"""
sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rootFraction_k2fvegFraction{T1, T2} <: rootFraction
	k2_scale::T1 = 0.02 | (0.001, 10.0) | "scales vegFrac to define fraction of 2nd soil layer available for transpiration" | ""
	k1_scale::T2 = 0.5 | (0.001, 10.0) | "scales vegFrac to fraction of 1st soil layer available for transpiration" | ""
end

function precompute(o::rootFraction_k2fvegFraction, forcing, land, infotem)
	@unpack_rootFraction_k2fvegFraction o

	## precomputations/check
	#--> get the soil thickness & root distribution information from input 
	soilDepths = infotem.pools.water.layerThickness.soilW; 
	#thickness arrays are the same & are equal to 2 
	if length(soilDepths) != infotem.pools.water.nZix.soilW && length(soilDepths) != 2 
		error(["rootFraction_k2Layer: the number of soil layers in modelStructure.json does not match with soil depths specified. This approach needs 2 soil layers."]) 
	end 
	#--> create the arrays to fill in the soil properties 
	p_fracRoot2SoilD = ones(size(infotem.pools.water.initValues.soilW)); 

	## pack variables
	@pack_land begin
		(soilDepths, p_fracRoot2SoilD) ∋ land.rootFraction
	end
	return land
end

function compute(o::rootFraction_k2fvegFraction, forcing, land, infotem)
	@unpack_rootFraction_k2fvegFraction o

	## unpack variables
	@unpack_land begin
		(soilDepths, p_fracRoot2SoilD) ∈ land.rootFraction
		vegFraction ∈ land.states
	end
	#--> check if the number of soil layers & number of elements in soil
	# the scaling parameters can be > 1 but k1RootFrac needs to be <= 1
	k1RootFrac = min(1.0, vegFraction * k1_scale); # the fraction of water that a root can uptake from the 1st soil layer
	k2RootFrac = min(1.0, vegFraction * k2_scale); # the fraction of water that a root can uptake from the 1st soil layer
	#--> set the properties
	# 1st Layer
	p_fracRoot2SoilD[1] = p_fracRoot2SoilD[1] * k1RootFrac
	# 2nd Layer
	p_fracRoot2SoilD[2] = p_fracRoot2SoilD[2] * k2RootFrac

	## pack variables
	@pack_land begin
		p_fracRoot2SoilD ∋ land.rootFraction
	end
	return land
end

function update(o::rootFraction_k2fvegFraction, forcing, land, infotem)
	# @unpack_rootFraction_k2fvegFraction o
	return land
end

"""
sets the maximum fraction of water that root can uptake from soil layers as function of vegetation fraction

# precompute:
precompute/instantiate time-invariant variables for rootFraction_k2fvegFraction

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_k2fvegFraction

*Inputs:*
 - infotem.pools.water.: soil layers & depths
 - land.states.vegFraction : vegetation fraction

*Outputs:*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

# update
update pools and states in rootFraction_k2fvegFraction
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 10.02.2020  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function rootFraction_k2fvegFraction_h end