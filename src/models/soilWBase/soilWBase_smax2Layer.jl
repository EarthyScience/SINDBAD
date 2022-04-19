export soilWBase_smax2Layer

@bounds @describe @units @with_kw struct soilWBase_smax2Layer{T1, T2} <: soilWBase
	smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
	smax2::T2 = 0.3 | (0.01, 1.0) | "maximum plant available water in 2nd soil layer, as % of defined soil depth" | ""
end

function precompute(o::soilWBase_smax2Layer, forcing, land, infotem)
	@unpack_soilWBase_smax2Layer o

	## precomputations/check
	# get the soil thickness & root distribution information from input
	soilDepths = infotem.pools.water.layerThickness.soilW;
	p_soilDepths = soilDepths;
	p_nsoilLayers = infotem.pools.water.nZix.soilW;
	# check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
	if length(soilDepths) != infotem.pools.water.nZix.soilW && length(soilDepths) != 2 
		error(["soilWBase_smax2Layer: the number of soil layers in modelStructure.json does not match with soil depths specified. This approach needs 2 soil layers."]) 
	end

	## instantiate variables
	p_wSat = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_wFC = repeat(infotem.helpers.aone, infotem.pools.water.nZix.soilW)
	p_wWP = repeat(infotem.helpers.azero, infotem.pools.water.nZix.soilW)

	## pack land variables
	@pack_land (soilDepths, p_soilDepths, p_nsoilLayers, p_wSat, p_wFC, p_wWP) => land.soilWBase
	return land
end

function compute(o::soilWBase_smax2Layer, forcing, land, infotem)
	## unpack parameters
	@unpack_soilWBase_smax2Layer o

	## unpack land variables
	@unpack_land (soilDepths, p_soilDepths, p_nsoilLayers, p_wSat, p_wFC, p_wWP) ∈ land.soilWBase

	## calculate variables
	# create the arrays to fill in the soil properties
	# storages
	# set the properties for each soil layer
	# 1st layer
	p_wSat[1] = smax1 * soilDepths[1]
	p_wFC[1] = smax1 * soilDepths[1]
	# 2nd layer
	p_wSat[2] = smax2 * soilDepths[2]
	p_wFC[2] = smax2 * soilDepths[2]
	# get the plant available water available
	# (all the water is plant available)
	p_wAWC = p_wSat

	## pack land variables
	@pack_land (p_nsoilLayers, p_soilDepths, p_wAWC, p_wFC, p_wSat, p_wWP) => land.soilWBase
	return land
end

@doc """
defines the maximum soil water content of 2 soil layers as fraction of the soil depth defined in the ModelStructure.json based on the older version of the Pre-Tokyo Model

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2Layer

*Inputs*
 - infotem.pools.water.: soil layers & depths

*Outputs*
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.p_soilDepths
 - land.soilWBase.p_wAWC: = land.soilWBase.p_wSat
 - land.soilWBase.p_wFC : = land.soilWBase.p_wSat
 - land.soilWBase.p_wSat: wSat = smax for 2 soil layers
 - land.soilWBase.p_wWP: wilting point set to zero for all layers
 -

# precompute:
precompute/instantiate time-invariant variables for soilWBase_smax2Layer


---

# Extended help

*References*

*Versions*
 - 1.0 on 09.01.2020 [ttraut]: clean up & consistency  

*Created by:*
 - ttraut
"""
soilWBase_smax2Layer