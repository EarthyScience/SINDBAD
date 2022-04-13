export gppDiffRadiation_GSI, gppDiffRadiation_GSI_h
"""
calculate the light stress on gpp based on GSI implementation of LPJ

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppDiffRadiation_GSI{T1, T2, T3} <: gppDiffRadiation
	fR_τ::T1 = 0.2 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
	fR_slope::T2 = 58.0 | (1.0, 100.0) | "slope of sigmoid" | "fraction"
	fR_base::T3 = 59.78 | (1.0, 120.0) | "base of sigmoid" | "fraction"
end

function precompute(o::gppDiffRadiation_GSI, forcing, land, infotem)
	# @unpack_gppDiffRadiation_GSI o
	return land
end

function compute(o::gppDiffRadiation_GSI, forcing, land, infotem)
	@unpack_gppDiffRadiation_GSI o

	## unpack variables
	@unpack_land begin
		Rg ∈ forcing
		CloudScGPP_prev ∈ land.gppDiffRadiation
	end
	f_smooth = (f_p, f_n, τ, slope, base) -> (1.0 - τ) * f_p + τ * (1.0 / (1.0 + exp(-slope * (f_n - base))))
	f_prev = CloudScGPP_prev
	Rg = Rg * 11.57407; # multiplied by a scalar to covert MJ/m2/day to W/m2
	fR = f_smooth[f_prev, Rg, fR_τ, fR_slope, fR_base]
	CloudScGPP = max(0.0, min(1.0, fR))

	## pack variables
	@pack_land begin
		CloudScGPP ∋ land.gppDiffRadiation
	end
	return land
end

function update(o::gppDiffRadiation_GSI, forcing, land, infotem)
	# @unpack_gppDiffRadiation_GSI o
	return land
end

"""
calculate the light stress on gpp based on GSI implementation of LPJ

# precompute:
precompute/instantiate time-invariant variables for gppDiffRadiation_GSI

# compute:
Effect of diffuse radiation using gppDiffRadiation_GSI

*Inputs:*
 - Rg: shortwave radiation incoming for the current time step
 - fR_τ: contribution of current time step

*Outputs:*
 - land.gppDiffRadiation.CloudScGPP: light effect on GPP between 0-1

# update
update pools and states in gppDiffRadiation_GSI
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
function gppDiffRadiation_GSI_h end