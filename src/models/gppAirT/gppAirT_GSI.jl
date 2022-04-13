export gppAirT_GSI, gppAirT_GSI_h
"""
calculate the light stress on gpp based on GSI implementation of LPJ

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppAirT_GSI{T1, T2, T3, T4, T5, T6} <: gppAirT
	fT_c_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for cold stress" | "fraction"
	fT_c_slope::T2 = 0.25 | (0.0, 100.0) | "slope of sigmoid for cold stress" | "fraction"
	fT_c_base::T3 = 7.0 | (1.0, 15.0) | "base of sigmoid for cold stress" | "fraction"
	fT_h_τ::T4 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor for heat stress" | "fraction"
	fT_h_slope::T5 = 1.74 | (0.0, 100.0) | "slope of sigmoid for heat stress" | "fraction"
	fT_h_base::T6 = 41.51 | (25.0, 65.0) | "base of sigmoid for heat stress" | "fraction"
end

function precompute(o::gppAirT_GSI, forcing, land, infotem)
	# @unpack_gppAirT_GSI o
	return land
end

function compute(o::gppAirT_GSI, forcing, land, infotem)
	@unpack_gppAirT_GSI o

	## unpack variables
	@unpack_land begin
		Tair ∈ forcing
		(cScGPP_prev, hScGPP_prev) ∈ land.gppAirT
	end
	f_smooth = (f_p, f_n, τ, slope, base) -> (1.0 - τ) * f_p + τ * (1.0 / (1.0 + exp(-slope * (f_n - base))))
	f_c_prev = cScGPP_prev
	fT_c = f_smooth[f_c_prev, Tair, fT_c_τ, fT_c_slope, fT_c_base]
	cScGPP = max(0.0, min(1.0, fT_c))
	f_h_prev = hScGPP_prev
	fT_h = f_smooth[f_h_prev, Tair, fT_h_τ, -fT_h_slope, fT_h_base]
	hScGPP = max(0.0, min(1.0, fT_h))
	TempScGPP = min(cScGPP, hScGPP)

	## pack variables
	@pack_land begin
		(TempScGPP, cScGPP, hScGPP) ∋ land.gppAirT
	end
	return land
end

function update(o::gppAirT_GSI, forcing, land, infotem)
	# @unpack_gppAirT_GSI o
	return land
end

"""
calculate the light stress on gpp based on GSI implementation of LPJ

# precompute:
precompute/instantiate time-invariant variables for gppAirT_GSI

# compute:
Effect of temperature using gppAirT_GSI

*Inputs:*
 - Rg: shortwave radiation incoming for the current time step
 - fT_c_τ: contribution of current time step

*Outputs:*
 - land.gppAirT.TempScGPP: light effect on GPP between 0-1

# update
update pools and states in gppAirT_GSI
 -

# Extended help

*References:*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions:*
 - 1.1 on 22.01.2021 (skoirala:  

*Created by:*
 - Sujan Koirala

*Notes:*
"""
function gppAirT_GSI_h end