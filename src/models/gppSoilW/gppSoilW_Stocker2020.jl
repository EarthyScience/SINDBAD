export gppSoilW_Stocker2020

@bounds @describe @units @with_kw struct gppSoilW_Stocker2020{T1, T2} <: gppSoilW
	q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | ""
	θStar::T2 = 0.6 | (0.1, 1.0) | "" | ""
end

function compute(o::gppSoilW_Stocker2020, forcing, land, helpers)
	## unpack parameters
	@unpack_gppSoilW_Stocker2020 o

	## unpack land variables
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
Gpp as a function of wsoil; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs*
 - Smin
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point
 - θStar

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture effect on GPP between 0-1
 -

---

# Extended help

*References*
 - Stocker B D; Wang H; Smith N G; et al. P-model v1. 0: An  optimality-based light use efficiency model for simulating ecosystem  gross primary production[J]. Geos

*Versions*

*Created by:*
 - ncarval & Shanning Bao [sbao]

*Notes*
"""
gppSoilW_Stocker2020