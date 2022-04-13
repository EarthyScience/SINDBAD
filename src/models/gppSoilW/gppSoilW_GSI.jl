export gppSoilW_GSI, gppSoilW_GSI_h
"""
calculate the soil moisture stress on gpp based on GSI implementation of LPJ

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppSoilW_GSI{T1, T2, T3} <: gppSoilW
	fW_τ::T1 = 0.8 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
	fW_slope::T2 = 5.24 | (1.0, 10.0) | "slope of sigmoid" | "fraction"
	fW_base::T3 = 20.96 | (10.0, 80.0) | "base of sigmoid" | "fraction"
end

function precompute(o::gppSoilW_GSI, forcing, land, infotem)
	# @unpack_gppSoilW_GSI o
	return land
end

function compute(o::gppSoilW_GSI, forcing, land, infotem)
	@unpack_gppSoilW_GSI o

	## unpack variables
	@unpack_land begin
		(p_wFC, p_wWP) ∈ land.soilWBase
		soilW ∈ land.pools
		SMScGPP_prev ∈ land.gppSoilW
	end
	f_smooth = (f_p, f_n, τ, slope, base) -> (1.0 - τ) * f_p + τ * (1.0 / (1.0 + exp(-slope * (f_n - base))))
	f_prev = SMScGPP_prev
	SM = sum(soilW)
	WP = sum(p_wWP)
	WFC = sum(p_wFC)
	maxAWC = max(WFC - WP, 0)
	actAWC = max(SM - WP, 0)
	SM_nor = min(actAWC / maxAWC, 1) * 100
	fW = f_smooth[f_prev, SM_nor, fW_τ, fW_slope, fW_base]
	SMScGPP = max(0.0, min(1.0, fW))
	# SM_nor = SM_nor

	## pack variables
	@pack_land begin
		SMScGPP ∋ land.gppSoilW
	end
	return land
end

function update(o::gppSoilW_GSI, forcing, land, infotem)
	# @unpack_gppSoilW_GSI o
	return land
end

"""
calculate the soil moisture stress on gpp based on GSI implementation of LPJ

# precompute:
precompute/instantiate time-invariant variables for gppSoilW_GSI

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_GSI

*Inputs:*
 - fW_τ: contribution of current time step
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point

*Outputs:*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP between 0-1

# update
update pools and states in gppSoilW_GSI
 -

# Extended help

*References:*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions:*
 - 1.1 on 22.01.2021 [skoirala]:  

*Created by:*
 - Sujan Koirala

*Notes:*
"""
function gppSoilW_GSI_h end