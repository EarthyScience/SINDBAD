export gppSoilW_Keenan2009, gppSoilW_Keenan2009_h
"""
calculate the soil moisture stress on gpp

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppSoilW_Keenan2009{T1, T2, T3} <: gppSoilW
	q::T1 = 0.6 | (0.0, 15.0) | "sensitivity of GPP to soil moisture " | ""
	sSmax::T2 = 0.7 | (0.2, 1.0) | "" | ""
	sSmin::T3 = 0.5 | (0.01, 0.95) | "" | ""
end

function precompute(o::gppSoilW_Keenan2009, forcing, land, infotem)
	# @unpack_gppSoilW_Keenan2009 o
	return land
end

function compute(o::gppSoilW_Keenan2009, forcing, land, infotem)
	@unpack_gppSoilW_Keenan2009 o

	## unpack variables
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
	SMScGPP = min(max(((maximum(SM, Smin) - Smin) / (Smax-Smin)) ^ q, 0.0), 1)

	## pack variables
	@pack_land begin
		SMScGPP ∋ land.gppSoilW
	end
	return land
end

function update(o::gppSoilW_Keenan2009, forcing, land, infotem)
	# @unpack_gppSoilW_Keenan2009 o
	return land
end

"""
calculate the soil moisture stress on gpp

# precompute:
precompute/instantiate time-invariant variables for gppSoilW_Keenan2009

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_Keenan2009

*Inputs:*
 - Smax
 - Smin
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point

*Outputs:*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP between 0-1

# update
update pools and states in gppSoilW_Keenan2009
 -

# Extended help

*References:*
 - Keenan; T.; García; R.; Friend; A. D.; Zaehle; S.; Gracia  C.; & Sabate; S.: Improved understanding of drought  controls on seasonal variation in Mediterranean forest  canopy CO2 & water fluxes through combined in situ  measurements & ecosystem modelling; Biogeosciences; 6; 1423–1444

*Versions:*
 - 1.0 on 10.03.2020 [sbesnard]  

*Created by:*
 - Nuno Carvalhais [ncarval] & Simon Besnard [sbesnard]

*Notes:*
"""
function gppSoilW_Keenan2009_h end