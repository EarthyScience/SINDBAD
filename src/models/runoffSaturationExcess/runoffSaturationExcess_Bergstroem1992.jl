export runoffSaturationExcess_Bergstroem1992

@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992{T1} <: runoffSaturationExcess
	β::T1 = 1.1 | (0.1, 5) | "berg exponential parameter" | ""
end

function compute(o::runoffSaturationExcess_Bergstroem1992, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSaturationExcess_Bergstroem1992 o

	## unpack land variables
	@unpack_land begin
		WBP ∈ land.states
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
	end
	# @show WBP
	tmp_smaxVeg = sum(p_wSat)
	tmp_SoilTotal = sum(soilW)
	# calculate land runoff from incoming water & current soil moisture
	tmp_SatExFrac = min((tmp_SoilTotal / tmp_smaxVeg) ^ β, helpers.numbers.one)

	runoffSaturation = WBP * tmp_SatExFrac
	# update water balance pool
	WBP = WBP - runoffSaturation

	## pack land variables
	@pack_land begin
		runoffSaturation => land.fluxes
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
Saturation runoff using runoffSaturationExcess_Bergstroem1992

*Inputs*
 - land.states. : vegetation fraction
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
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  
 - 1.1 on 27.11.2019 [skoirala]: changed to handle any number of soil layers
 - 1.2 on 10.02.2020 [ttraut]: modyfying variable names to match the new SINDBAD version

*Created by:*
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992