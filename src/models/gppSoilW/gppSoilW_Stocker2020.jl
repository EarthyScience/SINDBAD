export gppSoilW_Stocker2020, gppSoilW_Stocker2020_h
"""
calculate the soil moisture stress on gpp

# Parameters:
$(PARAMFIELDS)
"""
@bounds @describe @units @with_kw struct gppSoilW_Stocker2020{T1, T2} <: gppSoilW
	q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | ""
	θStar::T2 = 0.6 | (0.1, 1.0) | "" | ""
end

function precompute(o::gppSoilW_Stocker2020, forcing, land, infotem)
	# @unpack_gppSoilW_Stocker2020 o
	return land
end

function compute(o::gppSoilW_Stocker2020, forcing, land, infotem)
	@unpack_gppSoilW_Stocker2020 o

	## unpack variables
	@unpack_land begin
		(p_wFC, p_wWP) ∈ land.soilWBase
		soilW ∈ land.pools
	end
	SM = sum(soilW)
	WP = sum(p_wWP)
	WFC = sum(p_wFC)
	maxAWC = max(WFC - WP, 0)
	actAWC = max(SM - WP, 0)
	SM_nor = min(actAWC / maxAWC, 1)
	fW = (-q * (SM_nor - θStar) ^ 2.0 + 1) * (SM_nor <= θStar) + 1 * (SM_nor > θStar)
	SMScGPP = max(0.0, min(1.0, fW))
	# SM_nor = SM_nor

	## pack variables
	@pack_land begin
		SMScGPP ∋ land.gppSoilW
	end
	return land
end

function update(o::gppSoilW_Stocker2020, forcing, land, infotem)
	# @unpack_gppSoilW_Stocker2020 o
	return land
end

"""
calculate the soil moisture stress on gpp

# precompute:
precompute/instantiate time-invariant variables for gppSoilW_Stocker2020

# compute:
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs:*
 - Smin
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point
 - θStar

*Outputs:*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP between 0-1

# update
update pools and states in gppSoilW_Stocker2020
 -

# Extended help

*References:*
 - Stocker B D; Wang H; Smith N G; et al. P-model v1. 0: An  optimality-based light use efficiency model for simulating ecosystem  gross primary production[J]. Geos

*Versions:*

*Created by:*
 - Nuno Carvalhais [ncarval] & Shanning Bao [sbao]

*Notes:*
"""
function gppSoilW_Stocker2020_h end