export runoffSaturationExcess_Bergstroem1992VegFraction

@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992VegFraction{T1} <: runoffSaturationExcess
	β::T1 = 3.0 | (0.1, 10.0) | "linear scaling parameter to get the berg parameter from vegFrac" | ""
end

function compute(o::runoffSaturationExcess_Bergstroem1992VegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSaturationExcess_Bergstroem1992VegFraction o

	## unpack land variables
	@unpack_land begin
		(WBP, vegFraction) ∈ land.states
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(𝟘, 𝟙, sNT) ∈ helpers.numbers
	end
	tmp_smaxVeg = sum(p_wSat)
	tmp_SoilTotal = sum(soilW + ΔsoilW)
	# get the berg parameters according the vegetation fraction
	p_berg = max(0.1, β * vegFraction); # do this?
	# calculate land runoff from incoming water & current soil moisture
	tmp_SatExFrac = min(exp(p_berg * log(tmp_SoilTotal / tmp_smaxVeg)), 1)
	runoffSatExc = WBP * tmp_SatExFrac
	# update water balance pool
	WBP = WBP - runoffSatExc

	## pack land variables
	@pack_land begin
		runoffSatExc => land.fluxes
		p_berg => land.runoffSaturationExcess
		WBP => land.states
	end
	return land
end

@doc """
saturation excess runoff using Bergström method with parameter scaled by vegetation fraction

# Parameters
$(PARAMFIELDS)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992VegFraction

*Inputs*
 - land.states.vegFraction : vegetation fraction
 - smax1 : maximum water capacity of first soil layer [mm]
 - smax2 : maximum water capacity of second soil layer [mm]

*Outputs*
 - land.fluxes.runoffSatExc : runoff from land [mm/time]
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
runoffSaturationExcess_Bergstroem1992VegFraction