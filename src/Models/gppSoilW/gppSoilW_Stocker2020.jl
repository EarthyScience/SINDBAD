export gppSoilW_Stocker2020

#! format: off
@bounds @describe @units @with_kw struct gppSoilW_Stocker2020{T1,T2} <: gppSoilW
    q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | ""
    θstar::T2 = 0.6 | (0.1, 1.0) | "" | ""
end
#! format: on

function define(p_struct::gppSoilW_Stocker2020, forcing, land, helpers)
    gpp_f_soilW = helpers.numbers.𝟙
    ttwo = helpers.numbers.sNT(2.0)

    ## pack land variables
    @pack_land (ttwo, gpp_f_soilW) => land.gppSoilW
    return land
end

function compute(p_struct::gppSoilW_Stocker2020, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Stocker2020 p_struct

    ## unpack land variables
    @unpack_land begin
        (s_wFC, s_wWP) ∈ land.soilWBase
        soilW ∈ land.pools
        (𝟙, 𝟘) ∈ helpers.numbers
        ttwo ∈ land.gppSoilW
    end

    ## calculate variables
    SM = sum(soilW)
    maxAWC = max_0(s_wFC - s_wWP)
    actAWC = max_0(SM - s_wWP)
    SM_nor = min_1(actAWC / maxAWC)
    tfW = -q * (SM_nor - θstar)^ttwo + 𝟙
    c_allocation_f_soilW = SM_nor <= θstar ? tfW : one(tfW)
    gpp_f_soilW = clamp_01(c_allocation_f_soilW)

    ## pack land variables
    @pack_land gpp_f_soilW => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gpp_potential based on Stocker2020

# Parameters
$(PARAMFIELDS)

---

# compute:
Gpp as a function of soilW; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.s_wWP: sum of wilting point
 - land.soilWBase.s_wFC: sum of field capacity

*Outputs*
 - land.gppSoilW.gpp_f_soilW: soil moisture stress on gpp_potential (0-1)

---

# Extended help

*References*
 - Stocker, B. D., Wang, H., Smith, N. G., Harrison, S. P., Keenan, T. F., Sandoval, D., & Prentice, I. C. (2020). P-model v1. 0: an optimality-based light use efficiency model for simulating ecosystem gross primary production. Geoscientific Model Development, 13(3), 1545-1581.

*Versions*

*Created by:*
 - ncarval & Shanning Bao [sbao]

*Notes*
"""
gppSoilW_Stocker2020
