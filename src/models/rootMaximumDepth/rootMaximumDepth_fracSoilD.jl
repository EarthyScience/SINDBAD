export rootMaximumDepth_fracSoilD, rootMaximumDepth_fracSoilD_h
"""
sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct rootMaximumDepth_fracSoilD{T1} <: rootMaximumDepth
	fracRootD2SoilD::T1 = 0.5 | (0.1, 0.8) | "root depth as a fraction of soil depth" | ""
end

function precompute(o::rootMaximumDepth_fracSoilD, forcing, land, infotem)
	# @unpack_rootMaximumDepth_fracSoilD o
	return land
end

function compute(o::rootMaximumDepth_fracSoilD, forcing, land, infotem)
	@unpack_rootMaximumDepth_fracSoilD o

	## unpack variables

	## calculate variables
	#--> get the soil thickness & root distribution information from input
	maxRootD = sum(infotem.pools.water.layerThickness.soilW) * fracRootD2SoilD
	# disp(["the maxRootD scalar: " fracRootD2SoilD])

	## pack variables
	@pack_land begin
		maxRootD ∋ land.states
	end
	return land
end

function update(o::rootMaximumDepth_fracSoilD, forcing, land, infotem)
	# @unpack_rootMaximumDepth_fracSoilD o
	return land
end

"""
sets the maximum rooting depth as a fraction of total soil depth. rootMaximumDepth_fracSoilD

# precompute:
precompute/instantiate time-invariant variables for rootMaximumDepth_fracSoilD

# compute:
Maximum rooting depth using rootMaximumDepth_fracSoilD

*Inputs:*
 - infotem.pools.water.layerThickness.soilW

*Outputs:*
 - land.states.maxRootD: The maximum rooting depth as a fraction of total soil depth

# update
update pools and states in rootMaximumDepth_fracSoilD
 - None

# Extended help

*References:*
 -

*Versions:*
 - 1.0 on 21.11.2019  

*Created by:*
 - Sujan Koirala [skoirala]
"""
function rootMaximumDepth_fracSoilD_h end