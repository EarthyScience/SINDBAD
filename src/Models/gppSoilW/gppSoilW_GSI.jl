export gppSoilW_GSI

@bounds @describe @units @with_kw struct gppSoilW_GSI{T1, T2, T3, T4} <: gppSoilW
	fW_τ::T1 = 0.8 | (0.01, 1.0) | "contribution factor for current stressor" | "fraction"
	fW_slope::T2 = 5.24 | (1.0, 10.0) | "slope of sigmoid" | "fraction"
	fW_slope_mult::T3 = 100.0 | (nothing, nothing) | "multiplier for the slope of sigmoid" | "fraction"
	fW_base::T4 = 0.2096 | (0.1, 0.8) | "base of sigmoid" | "fraction"
end

function instantiate(o::gppSoilW_GSI, forcing, land, helpers)
	## unpack parameters
	@unpack_gppSoilW_GSI o

	## unpack land variables
	@unpack_land (𝟙, sNT) ∈ helpers.numbers
	SMScGPP_prev = 𝟙

	## pack land variables
	@pack_land (SMScGPP_prev) => land.gppSoilW
	return land
end

function compute(o::gppSoilW_GSI, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_GSI o

    ## unpack land variables
    @unpack_land begin
        (s_wAWC, s_wWP) ∈ land.soilWBase
        soilW ∈ land.pools
        (SMScGPP_prev) ∈ land.gppSoilW
        (𝟘, 𝟙) ∈ helpers.numbers
    end

	actAWC = max(addS(soilW) - s_wWP, 𝟘)
    SM_nor = min(actAWC / s_wAWC, 𝟙)
    fW = (𝟙 - fW_τ) * SMScGPP_prev + fW_τ * (𝟙 / (𝟙 + exp(-fW_slope * (SM_nor - fW_base))))
    SMScGPP = clamp(fW, 𝟘, 𝟙)
    SMScGPP_prev = SMScGPP

    ## pack land variables
    @pack_land (SMScGPP, SMScGPP_prev) => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gppPot based on GSI implementation of LPJ

# Parameters
$(PARAMFIELDS)

---

# compute:

*Inputs*
 - fW_τ: contribution of current time step
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.p_wWP: wilting point

*Outputs*
 - land.gppSoilW.SMScGPP: soil moisture stress on gppPot (0-1)

---

# Extended help

*References*
 - Forkel; M.; Carvalhais; N.; Schaphoff; S.; v. Bloh; W.; Migliavacca; M.  Thurner; M.; & Thonicke; K.: Identifying environmental controls on  vegetation greenness phenology through model–data integration  Biogeosciences; 11; 7025–7050; https://doi.org/10.5194/bg-11-7025-2014;2014.

*Versions*
 - 1.1 on 22.01.2021 [skoirala]

*Created by:*
 - skoirala

*Notes*
"""
gppSoilW_GSI