export runoffSaturationExcess_Bergstroem1992VegFractionFroSoil, runoffSaturationExcess_Bergstroem1992VegFractionFroSoil_h
"""
calculates land surface runoff & infiltration to different soil layers using. calculates land surface runoff & infiltration to different soil layers using

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFractionFroSoil{T1, T2} <: runoffSaturationExcess
	berg_scale::T1 = 3.0 | (0.1, 10.0) | "linear scaling parameter to get the berg parameter from vegFrac" | ""
	scaleFro::T2 = 1.0 | (0.1, 3.0) | "linear scaling parameter for rozen Soil fraction" | ""
end

function precompute(o::runoffSaturationExcess_Bergstroem1992VegFractionFroSoil, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_Bergstroem1992VegFractionFroSoil o
	return land
end

function compute(o::runoffSaturationExcess_Bergstroem1992VegFractionFroSoil, forcing, land, infotem)
	@unpack_runoffSaturationExcess_Bergstroem1992VegFractionFroSoil o

	## unpack variables
	@unpack_land begin
		frozenFrac ∈ forcing
		(WBP, vegFraction) ∈ land.states
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
	end
	# scale the input frozen soil fraction; maximum is 1
	fracFrozen = min(frozenFrac * scaleFro, 1)
	tmp_smaxVeg = sum(p_wSat) * (1.0 - fracFrozen+0.0000001)
	tmp_SoilTotal = sum(soilW)
	#--> get the berg parameters according the vegetation fraction
	p_berg = max(0.1, berg_scale * vegFraction); # do this?
	#--> calculate land runoff from incoming water & current soil moisture
	tmp_SatExFrac = min(exp(p_berg * log(tmp_SoilTotal / tmp_smaxVeg)), 1)
	roSat = WBP * tmp_SatExFrac
	#--> update water balance pool
	WBP = WBP - roSat

	## pack variables
	@pack_land begin
		roSat ∋ land.fluxes
		(fracFrozen, p_berg) ∋ land.runoffSaturationExcess
		WBP ∋ land.states
	end
	return land
end

function update(o::runoffSaturationExcess_Bergstroem1992VegFractionFroSoil, forcing, land, infotem)
	# @unpack_runoffSaturationExcess_Bergstroem1992VegFractionFroSoil o
	return land
end

"""
calculates land surface runoff & infiltration to different soil layers using. calculates land surface runoff & infiltration to different soil layers using

# precompute:
precompute/instantiate time-invariant variables for runoffSaturationExcess_Bergstroem1992VegFractionFroSoil

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992VegFractionFroSoil

*Inputs:*
 - forcing.fracFrozen : daily frozen soil fraction [0-1]
 - land.fracFrozen.scale : scaling parameter for frozen soil fraction
 - land.runoffSaturationExcess.fracFrozen : scaled frozen soil fraction
 - land.states.vegFraction : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs:*
 - land.fluxes.roSat : runoff from land [mm/time]
 - land.runoffSaturationExcess.p_berg : scaled berg parameter

# update
update pools and states in runoffSaturationExcess_Bergstroem1992VegFractionFroSoil
 - land.states.WBP : water balance pool [mm]

# Extended help

*References:*
 - Bergstroem, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions:*
 - 1.0 on 18.11.2019 [ttraut]  

*Created by:*
 - Tina Trautmann [ttraut]
"""
function runoffSaturationExcess_Bergstroem1992VegFractionFroSoil_h end