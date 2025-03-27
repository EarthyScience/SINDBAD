export WUE_VPDDayCo2

@bounds @describe @units @with_kw struct WUE_VPDDayCo2{T1, T2, T3} <: WUE
	WUEatOnehPa::T1 = 9.2 | (4.0, 17.0) | "WUE at 1 hpa VPD" | "gC/mmH2O"
	Ca0::T2 = 380.0 | (300.0, 500.0) | "" | "ppm"
	Cm::T3 = 500.0 | (100.0, 2000.0) | "" | "ppm"
end

function compute(o::WUE_VPDDayCo2, forcing, land::NamedTuple, helpers::NamedTuple)
	## unpack parameters and forcing
	@unpack_WUE_VPDDayCo2 o
	@unpack_forcing VPDDay ∈ forcing


	## unpack land variables
	@unpack_land begin
		ambCO2 ∈ land.states
		(𝟘, 𝟙, tolerance, sNT) ∈ helpers.numbers
	end

	## calculate variables
	# "WUEat1hPa"
	kpa_to_hpa = sNT(10) * 𝟙
	AoENoCO2 = WUEatOnehPa * 𝟙 / sqrt(kpa_to_hpa * (VPDDay + tolerance))
	fCO2_CO2 = 𝟙 + (ambCO2 - Ca0) / (ambCO2 - Ca0 + Cm)
	AoE = AoENoCO2 * fCO2_CO2

	## pack land variables
	@pack_land (AoE, AoENoCO2) => land.WUE
	return land
end

@doc """
calculates the WUE/AOE as a function of WUE at 1hpa daily mean VPD

# Parameters
$(PARAMFIELDS)

---

# compute:
Estimate wue using WUE_VPDDayCo2

*Inputs*
 - WUEat1hPa: the VPD at 1 hpa
 - forcing.VPDDay: daytime mean VPD [kPa]

*Outputs*
 - land.WUE.AoENoCO2: water use efficiency - ratio of assimilation &  transpiration fluxes [gC/mmH2O] without co2 effect

---

# Extended help

*References*

*Versions*
 - 1.0 on 11.11.2019 [skoirala]

*Created by:*
 - Jake Nelson [jnelson]: for the typical values & ranges of WUEat1hPa  across fluxNet sites
 - skoirala
"""
WUE_VPDDayCo2