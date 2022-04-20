export runoffSaturationExcess_Bergstroem1992VegFractionPFT

@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFractionPFT{T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12} <: runoffSaturationExcess
	berg_scale_PFT0::T1 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 0 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT1::T2 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 1 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT2::T3 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 2 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT3::T4 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 3 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT4::T5 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 4 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT5::T6 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 5 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT6::T7 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 6 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT7::T8 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 7 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT8::T9 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 8 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT9::T10 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 9 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT10::T11 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 10 to get the berg parameter from vegFrac" | ""
	berg_scale_PFT11::T12 = 3.0 | (0.1, 5.0) | "linear scaling parameter of PFT class 11 to get the berg parameter from vegFrac" | ""
end

function compute(o::runoffSaturationExcess_Bergstroem1992VegFractionPFT, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_runoffSaturationExcess_Bergstroem1992VegFractionPFT o
	@unpack_forcing PFT ∈ forcing


	## unpack land variables
	@unpack_land begin
		(WBP, vegFraction) ∈ land.states
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
	end
	# get the PFT data & assign parameters
	tmp_classes = unique(PFT)
	p_berg_scale = 1.0
	for nC in 1:length(tmp_classes)
		nPFT = tmp_classes[nC]
		p_berg_scale[PFT == nPFT, 1] = eval(char(["berg_scale_PFT" num2str(nPFT)]))
	end
	tmp_smaxVeg = sum(p_wSat)
	tmp_SoilTotal = sum(soilW)
	# get the berg parameters according the vegetation fraction
	p_berg = max(0.1, p_berg_scale * vegFraction); # do this?
	# calculate land runoff from incoming water & current soil moisture
	tmp_SatExFrac = min(exp(p_berg * log(tmp_SoilTotal / tmp_smaxVeg)), 1)
	runoffSaturation = WBP * tmp_SatExFrac
	# update water balance pool
	WBP = WBP - runoffSaturation

	## pack land variables
	@pack_land begin
		runoffSaturation => land.fluxes
		(p_berg, p_berg_scale) => land.runoffSaturationExcess
		WBP => land.states
	end
	return land
end

@doc """
calculates land surface runoff & infiltration to different soil layers using

# Parameters
$(PARAMFIELDS)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992VegFractionPFT

*Inputs*
 - forcing.PFT : PFT classes
 - land.runoffSaturationExcess.p_berg_scale : scalar for land.states.vegFraction to define shape parameter of runoff-infiltration curve []
 - land.states.vegFraction : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs*
 - land.fluxes.runoffSaturation : runoff from land [mm/time]
 - land.runoffSaturationExcess.p_berg : scaled berg parameter
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 10.09.2021 [ttraut]: based on runoffSaturation_BergstroemLinVegFr  
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
 - 1.1 on 27.11.2019 [skoirala]: changed to handle any number of soil layers
 - 1.2 on 10.02.2020 [ttraut]: modyfying variable names to match the new SINDBAD version

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992VegFractionPFT