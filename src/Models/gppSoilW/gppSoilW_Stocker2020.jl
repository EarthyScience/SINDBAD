export gppSoilW_Stocker2020

#! format: off
@bounds @describe @units @with_kw struct gppSoilW_Stocker2020{T1,T2} <: gppSoilW
    q::T1 = 1.0 | (0.01, 4.0) | "sensitivity of GPP to soil moisture " | ""
    θstar::T2 = 0.6 | (0.1, 1.0) | "" | ""
end
#! format: on

function define(p_struct::gppSoilW_Stocker2020, forcing, land, helpers)
    @unpack_gppSoilW_Stocker2020 p_struct
    t_two = oftype(q, 2.0)
    gpp_f_soilW = oftype(q, 1.0)

    ## pack land variables
    @pack_land (t_two, gpp_f_soilW) => land.gppSoilW
    return land
end

function compute(p_struct::gppSoilW_Stocker2020, forcing, land, helpers)
    ## unpack parameters
    @unpack_gppSoilW_Stocker2020 p_struct

    ## unpack land variables
    @unpack_land begin
        (sum_wFC, sum_WP) ∈ land.soilWBase
        soilW ∈ land.pools
        t_two ∈ land.gppSoilW
        (z_zero, o_one) ∈ land.wCycleBase
    end
    ## calculate variables
    SM = sum(soilW)
    max_AWC = maxZero(sum_wFC - sum_WP)
    actAWC = maxZero(SM - sum_WP)
    SM_nor = minOne(actAWC / max_AWC)
    tf_soilW = -q * (SM_nor - θstar)^t_two + o_one
    c_allocation_f_soilW = SM_nor <= θstar ? tf_soilW : one(tf_soilW)
    gpp_f_soilW = clampZeroOne(c_allocation_f_soilW)

    ## pack land variables
    @pack_land gpp_f_soilW => land.gppSoilW
    return land
end

@doc """
soil moisture stress on gpp_potential based on Stocker2020

# Parameters
$(SindbadParameters)

---

# compute:
Gpp as a function of soilW; should be set to none if coupled with transpiration using gppSoilW_Stocker2020

*Inputs*
 - land.pools.soilW: values of soil moisture current time step
 - land.soilWBase.sum_WP: sum of wilting point
 - land.soilWBase.sum_wFC: sum of field capacity

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
