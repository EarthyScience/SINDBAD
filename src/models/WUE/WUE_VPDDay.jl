export WUE_VPDDay

@bounds @describe @units @with_kw struct WUE_VPDDay{T1} <: WUE
	WUEatOnehPa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
end

function compute(o::WUE_VPDDay, forcing, land, helpers)
	## unpack parameters and forcing
	@unpack_WUE_VPDDay o
	@unpack_forcing VPDDay ∈ forcing
	@unpack_land (zero, one) ∈ helpers.numbers


	## calculate variables
	# "WUEat1hPa"
	kpa_to_hpa = 10 * one
	AoE = WUEatOnehPa * one / sqrt(kpa_to_hpa * (VPDDay +0.005))

	## pack land variables
	@pack_land AoE => land.WUE
	return land
end

@doc """
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters
$(PARAMFIELDS)

---

# compute:
Estimate wue using WUE_VPDDay

*Inputs*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs*
 - land.WUE.AoE: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O]

---

# Extended help

*References*
 -

*Versions*
 - 1.0 on 11.11.2019 [skoirala]:  

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - skoirala
"""
WUE_VPDDay