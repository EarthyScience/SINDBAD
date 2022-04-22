export runoffSaturationExcess_Bergstroem1992MixedVegFraction

@bounds @describe @units @with_kw struct runoffSaturationExcess_Bergstroem1992MixedVegFraction{T1, T2} <: runoffSaturationExcess
	βV::T1 = 5.0 | (0.1, 20.0) | "linear scaling parameter for berg for vegetated fraction" | ""
	βS::T2 = 2.0 | (0.1, 20.0) | "linear scaling parameter for berg for non vegetated fraction" | ""
end

function compute(o::runoffSaturationExcess_Bergstroem1992MixedVegFraction, forcing, land, helpers)
	## unpack parameters
	@unpack_runoffSaturationExcess_Bergstroem1992MixedVegFraction o

	## unpack land variables
	@unpack_land begin
		(WBP, vegFraction) ∈ land.states
		p_wSat ∈ land.soilWBase
		soilW ∈ land.pools
		ΔsoilW ∈ land.states
		(zero, one, sNT) ∈ helpers.numbers
	end
	tmp_smaxVeg = sum(p_wSat)
	tmp_SoilTotal = sum(soilW + ΔsoilW)

	# get the berg parameters according the vegetation fraction
	p_berg = βV * vegFraction + βS * (one - vegFraction)
	p_berg = max(0.1, berg); # do this?

	# calculate land runoff from incoming water & current soil moisture
	tmp_SatExFrac = min((tmp_SoilTotal / tmp_smaxVeg ^ p_berg), one)
	runoffSatExc = WBP * tmp_SatExFrac

	# update water balance
	WBP = WBP - runoffSatExc

	## pack land variables
	@pack_land begin
		runoffSatExc => land.fluxes
		WBP => land.states
	end
	return land
end

@doc """
saturation excess runoff using Bergström method with separate berg parameters for vegetated and non-vegetated fractions

# Parameters
$(PARAMFIELDS)

---

# compute:
Saturation runoff using runoffSaturationExcess_Bergstroem1992MixedVegFraction

*Inputs*
 - berg : shape parameter of runoff-infiltration curve []

*Outputs*
 - land.fluxes.runoffSatExc : runoff from land [mm/time]
 - land.states.WBP : water balance pool [mm]

---

# Extended help

*References*
 - Bergström, S. (1992). The HBV model–its structure & applications. SMHI.

*Versions*
 - 1.0 on 18.11.2019 [ttraut]: cleaned up the code  

*Created by:*
 - 1.1 on 27.11.2019: skoirala: changed to handle any number of soil layers
 - ttraut
"""
runoffSaturationExcess_Bergstroem1992MixedVegFraction