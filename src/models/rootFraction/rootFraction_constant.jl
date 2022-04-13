export rootFraction_constant, rootFraction_constant_h
"""
sets the maximum fraction of water that root can uptake from soil layers as constant

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rootFraction_constant{T1} <: rootFraction
	constantRootFrac::T1 = 1.0 | (0.05, 1.0) | "root fraction" | ""
end

function precompute(o::rootFraction_constant, forcing, land, infotem)
	@unpack_rootFraction_constant o
	@unpack_land begin
		maxRootD ∈ land.states
	end

	## calculate variables
	##p_fracRoot2SoilD = ones(size(infotem.pools.water.initValues.soilW))
	soilDepths = infotem.pools.water.layerThickness.soilW
	totalSoilDepth = sum(soilDepths)
	maxRootDepth = min(maxRootD, totalSoilDepth); # maximum rootingdepth 
	rootStop = ones(size(infotem.pools.water.initValues.soilW))
	for sl in 1:infotem.pools.water.nZix.soilW
		soilD = sum(soilDepths[1:sl-1]);
		rootOver = maxRootDepth - soilD;
		rootOverID = (rootOver <= 0.0);
		rootStop[rootOverID, sl] = 0.0;
	end
	#--> create the arrays to fill in the soil properties
	p_fracRoot2SoilD = ones(size(infotem.pools.water.initValues.soilW)) * constantRootFrac * rootStop;

	## pack variables
	@pack_land begin
		p_fracRoot2SoilD ∋ land.rootFraction
	end
	return land
end

function compute(o::rootFraction_constant, forcing, land, infotem)
	# @unpack_rootFraction_constant o
	return land
end

function update(o::rootFraction_constant, forcing, land, infotem)
	# @unpack_rootFraction_constant o
	return land
end

"""
sets the maximum fraction of water that root can uptake from soil layers as constant

# precompute:
precompute/instantiate time-invariant variables for rootFraction_constant

# compute:
Distribution of water uptake fraction/efficiency by root per soil layer using rootFraction_constant

*Inputs:*
 - land.states.maxRootD

*Outputs:*
 - land.rootFraction.p_fracRoot2SoilD as nPix;nZix for soilW

# update
update pools and states in rootFraction_constant
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function rootFraction_constant_h end