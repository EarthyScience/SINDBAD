export gppSoilW_Keenan2009

@bounds @describe @units @with_kw struct gppSoilW_Keenan2009{T1, T2, T3} <: gppSoilW
	q::T1 = 0.6 | (0.0, 15.0) | "sensitivity of GPP to soil moisture " | ""
	sSmax::T2 = 0.7 | (0.2, 1.0) | "" | ""
	sSmin::T3 = 0.5 | (0.01, 0.95) | "" | ""
end

function compute(o::gppSoilW_Keenan2009, forcing, land, helpers)
	## unpack parameters
	@unpack_gppSoilW_Keenan2009 o

	## unpack land variables
	@unpack_land begin
		(p_wSat, p_wWP) ∈ land.soilWBase
		soilW ∈ land.pools
	end
	SM = sum(soilW)
	WP = sum(p_wWP)
	Wsat = sum(p_wSat)
	maxAWC = max(Wsat - WP, 0)
	Smax = sSmax * maxAWC
	Smin = sSmin * Smax
	SMScGPP = min(max(((maximum(SM, Smin) - Smin) / (Smax-Smin)) ^ q, helpers.numbers.zero), 1)

	## pack land variables
	@pack_land SMScGPP => land.gppSoilW
	return land
end

@doc """
calculate the soil moisture stress on gpp

# Parameters
$(PARAMFIELDS)

---

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_Keenan2009

*Inputs*
 - Smax
 - Smin
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP between 0-1
 -

---

# Extended help

*References*
 - Keenan; T.; García; R.; Friend; A. D.; Zaehle; S.; Gracia  C.; & Sabate; S.: Improved understanding of drought  controls on seasonal variation in Mediterranean forest  canopy CO2 & water fluxes through combined in situ  measurements & ecosystem modelling; Biogeosciences; 6; 1423–1444

*Versions*
 - 1.0 on 10.03.2020 [sbesnard]  

*Created by:*
 - ncarval & sbesnard

*Notes*
"""
gppSoilW_Keenan2009