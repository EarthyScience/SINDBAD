export soilWBase_smax2fPFT, soilWBase_smax2fPFT_h
"""
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is defined as PFT specific parameters from forcing

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct soilWBase_smax2fPFT{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13} <: soilWBase
	smax1::T1 = 1.0 | (0.001, 1.0) | "maximum soil water holding capacity of 1st soil layer, as % of defined soil depth" | ""
	smaxPFT0::T2 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 0, as % of defined soil depth" | "fraction"
	smaxPFT1::T3 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 1, as % of defined soil depth" | "fraction"
	smaxPFT2::T4 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 2, as % of defined soil depth" | "fraction"
	smaxPFT3::T5 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 3, as % of defined soil depth" | "fraction"
	smaxPFT4::T6 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 4, as % of defined soil depth" | "fraction"
	smaxPFT5::T7 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 5, as % of defined soil depth" | "fraction"
	smaxPFT6::T8 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 6, as % of defined soil depth" | "fraction"
	smaxPFT7::T9 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 7, as % of defined soil depth" | "fraction"
	smaxPFT8::T10 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 8, as % of defined soil depth" | "fraction"
	smaxPFT9::T11 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 9, as % of defined soil depth" | "fraction"
	smaxPFT10::T12 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 10, as % of defined soil depth" | "fraction"
	smaxPFT11::T13 = 0.05 | (0.0, 2.0) | "maximum soil water holding capacity of 2nd soil layer of PFT class 11, as % of defined soil depth" | "fraction"
end

function precompute(o::soilWBase_smax2fPFT, forcing, land, infotem)
	@unpack_soilWBase_smax2fPFT o

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

function compute(o::soilWBase_smax2fPFT, forcing, land, infotem)
	@unpack_soilWBase_smax2fPFT o

	## unpack variables
	@unpack_land begin
		(soilDepths, p_soilDepths, p_nsoilLayers, p_wSat, p_wFC, p_wWP) ∈ land.soilWBase
		PFT ∈ forcing
	end
	#--> get the PFT data & assign parameters
	tmp_classes = unique(PFT)
	p_smaxPFT = 1.0
	for nC in 1:length(tmp_classes)
		nPFT = tmp_classes[nC]
		p_tmp = eval(char(["smaxPFT" num2str(nPFT)]))
		p_smaxPFT[PFT == nPFT, 1] = soilDepths[2]* p_tmp; #
	end
	#--> create the arrays to fill in the soil properties
	# storages
	#--> set the properties for each soil layer
	# 1st layer
	p_wSat[1] = smax1 * soilDepths[1]
	p_wFC[1] = smax1 * soilDepths[1]
	# 2nd layer - fill in by linaer combination of the RD data
	p_wSat[2] = p_smaxPFT
	p_wFC[2] = p_smaxPFT
	#--> get the plant available water available
	# (all the water is plant available)
	p_wAWC = p_wSat

	## pack variables
	@pack_land begin
		(p_nsoilLayers, p_smaxPFT, p_soilDepths, p_wAWC, p_wFC, p_wSat, p_wWP) ∋ land.soilWBase
	end
	return land
end

function update(o::soilWBase_smax2fPFT, forcing, land, infotem)
	# @unpack_soilWBase_smax2fPFT o
	return land
end

"""
defines the maximum soil water content of 2 soil layers the first layer is a fraction [i.e. 1] of the soil depth the second layer is defined as PFT specific parameters from forcing

# precompute:
precompute/instantiate time-invariant variables for soilWBase_smax2fPFT

# compute:
Distribution of soil hydraulic properties over depth using soilWBase_smax2fPFT

*Inputs:*
 - forcing.PFT: PFT classes
 - infotem.pools.water.: soil layers & depths

*Outputs:*
 - land.soilWBase.p_nsoilLayers
 - land.soilWBase.p_smaxPFT: the combined parameters [pix, 1]
 - land.soilWBase.p_soilDepths
 - land.soilWBase.p_wAWC: = land.soilWBase.p_wSat
 - land.soilWBase.p_wFC : = land.soilWBase.p_wSat
 - land.soilWBase.p_wSat: wSat = smax for 2 soil layers
 - land.soilWBase.p_wWP: wilting point set to zero for all layers

# update
update pools and states in soilWBase_smax2fPFT
 -

# Extended help

*References:*

*Versions:*
 - 1.0 on 10.09.2021 [ttraut]:  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function soilWBase_smax2fPFT_h end