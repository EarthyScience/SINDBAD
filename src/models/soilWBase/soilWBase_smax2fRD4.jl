export soilWBase_smax2fRD4, soilWBase_smax2fRD4_h
"""
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct soilWBase_smax2fRD4{T1, T2, T3, T4, T5, T6} <: soilWBase
	smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
	scaleFan::T2 = 0.05 | (0.0, 5.0) | "scaling for rooting depth data to obtain smax2" | "fraction"
	scaleYang::T3 = 0.05 | (0.0, 5.0) | "scaling for rooting depth data to obtain smax2" | "fraction"
	scaleWang::T4 = 0.05 | (0.0, 5.0) | "scaling for root zone storage capacity data to obtain smax2" | "fraction"
	scaleTian::T5 = 0.05 | (0.0, 5.0) | "scaling for plant avaiable water capacity data to obtain smax2" | "fraction"
	smaxTian::T6 = 50.0 | (0.0, 1000.0) | "value for plant avaiable water capacity data where this is NaN" | "mm"
end

function precompute(o::soilWBase_smax2fRD4, forcing, land, infotem)
	@unpack_soilWBase_smax2fRD4 o

	## precomputations/check
	#--> get the soil thickness & root distribution information from input
	soilDepths = infotem.pools.water.layerThickness.soilW;
	p_soilDepths = soilDepths;
	p_nsoilLayers = infotem.pools.water.nZix.soilW;
	#--> check if the number of soil layers and number of elements in soil thickness arrays are the same & are equal to 2 
	if length(soilDepths) != infotem.pools.water.nZix.soilW && length(soilDepths) != 2 
		error(["soilWBase_smax2Layer: the number of soil layers in modelStructure.json does not match with soil depths specified. This approach needs 2 soil layers."]) 
	end 

	## instantiate variables
	p_wSat = ones(size(infotem.pools.water.initValues.soilW))
	p_wFC = ones(size(infotem.pools.water.initValues.soilW))
	p_wWP = zeros(size(infotem.pools.water.initValues.soilW))

	## pack variables
	@pack_land begin
		(soilDepths, p_soilDepths, p_nsoilLayers, p_wSat, p_wFC, p_wWP) ∋ land.soilWBase
	end
	return land
end

function compute(o::soilWBase_smax2fRD4, forcing, land, infotem)
	@unpack_soilWBase_smax2fRD4 o

	## unpack variables
	@unpack_land begin
		(soilDepths, p_soilDepths, p_nsoilLayers, p_wSat, p_wFC, p_wWP) ∈ land.soilWBase
		(AWC, RDeff, RDmax, SWCmax) ∈ forcing
	end
	#--> get the rooting depth data & scale them
	p_RD[1] = RDmax[1] * scaleFan
	p_RD[2] = RDeff[1] * scaleYang
	p_RD[3] = SWCmax[1] * scaleWang
	# for the Tian data; fill the NaN gaps with smaxTian
	AWC[isnan(AWC)] = smaxTian
	p_RD[4] = AWC[1] * scaleTian
	#--> create the arrays to fill in the soil properties
	# storages
	#--> set the properties for each soil layer
	# 1st layer
	p_wSat[1] = smax1 * soilDepths[1]
	p_wFC[1] = smax1 * soilDepths[1]
	# 2nd layer - fill in by linaer combination of the RD data
	p_wSat[2] = sum(p_RD)
	p_wFC[2] = sum(p_RD)
	#--> get the plant available water available
	# (all the water is plant available)
	p_wAWC = p_wSat

	## pack variables
	@pack_land begin
		(AWC, p_RD, p_nsoilLayers, p_soilDepths, p_wAWC, p_wFC, p_wSat, p_wWP) ∋ land.soilWBase
	end
	return land
end

function update(o::soilWBase_smax2fRD4, forcing, land, infotem)
	# @unpack_soilWBase_smax2fRD4 o
	return land
end

"""
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is a linear combination of scaled rooting depth data from forcing

# precompute:
precompute/instantiate time-invariant variables for soilWBase_smax2fRD4

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2fRD4

*Inputs:*
 - forcing.AWC: (plant) available water capacity from Tian et al. 2019
 - forcing.RDeff: effective rooting depth from Yang et al. 2016
 - forcing.RDmax: maximum rooting depth from Fan et al. 2017
 - forcing.SWCmax: maximum soil water capacity from Wang-Erlandsson et al. 2016
 - infotem.pools.water.: soil layers & depths

*Outputs:*
 - land.soilWBase.p_RD: the 4 scaled RD datas [pix, zix]
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.p_soilDepths
 - land.soilWBase.p_wAWC: = land.soilWBase.p_wSat
 - land.soilWBase.p_wFC : = land.soilWBase.p_wSat
 - land.soilWBase.p_wSat: wSat = smax for 2 soil layers
 - land.soilWBase.p_wWP: wilting point set to zero for all layers

# update
update pools and states in soilWBase_smax2fRD4
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 10.02.2020 [ttraut]:  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function soilWBase_smax2fRD4_h end