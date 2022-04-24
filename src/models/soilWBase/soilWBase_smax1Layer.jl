export soilWBase_smax1Layer

@bounds @describe @units @with_kw struct soilWBase_smax1Layer{T1} <: soilWBase
	smax::T1 = 1.0 | (0.001, 10.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
end

function precompute(o::soilWBase_smax1Layer, forcing, land, helpers)
	@unpack_soilWBase_smax1Layer o

	@unpack_land begin
		n_soilW = soilW ∈ helpers.pools.water.nZix
		numType ∈ helpers.numbers
	end
	## precomputations/check
	# get the soil thickness & root distribution information from input
	p_soilDepths = helpers.pools.water.layerThickness.soilW;
	# check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 1 
	if length(p_soilDepths) != 1 
		error(["soilWBase_smax1Layer needs eactly 1 soil layer in modelStructure.json."]) 
	end

	## instantiate variables
	p_wSat = ones(numType, n_soilW)
	p_wFC = ones(numType, n_soilW)
	p_wWP = zeros(numType, n_soilW)

	## pack land variables
	@pack_land (p_soilDepths, p_wSat, p_wFC, p_wWP) => land.soilWBase
	return land
end

function compute(o::soilWBase_smax1Layer, forcing, land, helpers)
	## unpack parameters
	@unpack_soilWBase_smax1Layer o

	## unpack land variables
	@unpack_land (p_soilDepths, p_wSat, p_wFC, p_wWP) ∈ land.soilWBase

	## calculate variables
	
	# set the properties for each soil layer
	# 1st layer
	p_wSat[1] = smax * p_soilDepths[1]
	p_wFC[1] = smax * p_soilDepths[1]

	# get the plant available water available (all the water is plant available)
	p_wAWC = p_wSat

	## pack land variables
	@pack_land (p_wAWC, p_wFC, p_wSat, p_wWP) => land.soilWBase
	return land
end

@doc """
defines the maximum soil water content of 1 soil layer as fraction of the soil depth defined in the ModelStructure.json based on the TWS model for the Northern Hemisphere

# Parameters
$(PARAMFIELDS)

---

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax1Layer

*Inputs*
 - helpers.pools.water.: soil layers & depths

*Outputs*
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.p_soilDepths
 - land.soilWBase.p_wAWC: = land.soilWBase.p_wSat
 - land.soilWBase.p_wFC : = land.soilWBase.p_wSat
 - land.soilWBase.p_wWP: wilting point set to zero for all layers

# precompute:
precompute/instantiate time-invariant variables for soilWBase_smax1Layer


---

# Extended help

*References*
 - Trautmann et al. 2018

*Versions*
 - 1.0 on 09.01.2020 [ttraut]: clean up & consistency  

*Created by:*
 - ttraut
"""
soilWBase_smax1Layer